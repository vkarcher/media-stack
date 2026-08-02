#!/usr/bin/env bash
#
# Préparation de l'environnement. Ne démarre RIEN : le déploiement reste
# explicite, service par service (voir QUICKSTART.md).
#
# Idempotent — relançable sans risque.
#
set -euo pipefail

C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_DIM=$'\033[2m'; C_OFF=$'\033[0m'
ok()   { echo "  ${C_OK}✓${C_OFF} $*"; }
warn() { echo "  ${C_WARN}!${C_OFF} $*"; }
die()  { echo "  ${C_ERR}✗${C_OFF} $*" >&2; exit 1; }
step() { echo; echo "${C_DIM}──${C_OFF} $* ${C_DIM}$(printf '─%.0s' $(seq 1 $((60 - ${#1}))))${C_OFF}"; }

cd "$(dirname "$0")"

# ─────────────────────────────────────────────────────────────────────────────
step "Prérequis"

command -v docker >/dev/null || die "docker introuvable"
docker compose version >/dev/null 2>&1 || die "le plugin docker compose est absent"
ok "docker $(docker version --format '{{.Server.Version}}' 2>/dev/null || echo '?')"
ok "compose $(docker compose version --short 2>/dev/null || echo '?')"

docker info >/dev/null 2>&1 || die "docker ne répond pas — êtes-vous dans le groupe docker ?"

# ─────────────────────────────────────────────────────────────────────────────
step "Configuration"

[[ -f .env ]] || die ".env absent — copiez .env.example puis remplissez-le"
[[ -f common.env ]] || { cp common.env.example common.env; ok "common.env créé depuis l'exemple"; }

set -a; source ./.env; set +a

for v in DOMAIN STACK_ROOT POOL_ROOT PUID PGID TZ; do
  [[ -n "${!v:-}" ]] || die "$v n'est pas défini dans .env"
done
[[ "$DOMAIN" != "exemple.com" ]] || die "DOMAIN est resté sur la valeur d'exemple"
ok "domaine   $DOMAIN"
ok "stack     $STACK_ROOT"
ok "pool      $POOL_ROOT"
ok "identité  ${PUID}:${PGID}"

if [[ -z "${WIREGUARD_PRIVATE_KEY:-}" ]]; then
  warn "WIREGUARD_PRIVATE_KEY est vide — gluetun démarrera sans tunnel."
  warn "N'activez pas qBittorrent avant de l'avoir renseignée."
fi

# ─────────────────────────────────────────────────────────────────────────────
step "Arborescence"

mkdir -p "$STACK_ROOT"/{appdata,cache,secrets,backups}
mkdir -p "$POOL_ROOT"/media/{movies,series,anime}
mkdir -p "$POOL_ROOT"/torrents/{complete,incomplete}
chmod 700 "$STACK_ROOT/secrets"
ok "dossiers créés sous $STACK_ROOT et $POOL_ROOT"

# ─── LA vérification qui compte ──────────────────────────────────────────────
# Un hardlink ne peut exister qu'à l'intérieur d'un même système de fichiers.
# Si media/ et torrents/ sont sur deux systèmes différents, les *arr copieront
# au lieu de lier, et chaque fichier occupera deux fois la place. C'est l'erreur
# la plus coûteuse de cette stack, et elle est invisible sans ce test.
dev_media=$(stat -c '%d' "$POOL_ROOT/media")
dev_torr=$(stat -c '%d' "$POOL_ROOT/torrents")

if [[ "$dev_media" == "$dev_torr" ]]; then
  ok "media/ et torrents/ sont sur le MÊME système de fichiers — hardlinks possibles"
else
  echo
  die "media/ et torrents/ sont sur DEUX systèmes de fichiers différents.
      Les hardlinks seront impossibles : chaque fichier occupera le double
      d'espace, sans aucun message d'erreur.
      Corrigez POOL_ROOT avant de continuer — lisez docs/hardlinks.md."
fi

# Vérification effective du droit de créer un lien
tmp_a="$POOL_ROOT/media/.hardlink-test"
tmp_b="$POOL_ROOT/torrents/.hardlink-test"
rm -f "$tmp_a" "$tmp_b"
: > "$tmp_a"
if ln "$tmp_a" "$tmp_b" 2>/dev/null; then
  ok "création de hardlink vérifiée entre les deux dossiers"
else
  warn "le système de fichiers refuse les hardlinks entre ces dossiers"
  warn "certains systèmes (exFAT, certains montages réseau) ne les supportent pas"
fi
rm -f "$tmp_a" "$tmp_b"

# ─────────────────────────────────────────────────────────────────────────────
step "Liens .env par service"

# Compose ne lit le .env que dans le répertoire du compose, jamais dans un
# parent. Sans ces liens, ${DOMAIN} et les autres variables ne sont pas
# résolues — et gluetun démarrerait sans clé VPN, silencieusement.
n=0
for d in compose/*/*/; do
  [[ -f "$d/compose.yml" ]] || continue
  ( cd "$d" && ln -sfn ../../../.env .env )
  n=$((n + 1))
done
ok "$n liens créés"

# ─────────────────────────────────────────────────────────────────────────────
step "Gabarits de secrets"

# Ces fichiers sont référencés par des compose : sans eux, la validation échoue
# et le service refuse de démarrer. On les crée vides, à remplir au moment de
# déployer le service concerné.
mk_secret() {
  local f="$STACK_ROOT/secrets/$1"; shift
  [[ -f "$f" ]] && { ok "$(basename "$f") (déjà présent)"; return; }
  ( umask 077; printf '%s\n' "$@" > "$f" )
  ok "$(basename "$f") créé — À REMPLIR"
}

mk_secret recyclarr.env \
  "# Clés d'API de Sonarr et Radarr (Settings > General dans chacun)" \
  "SONARR_API_KEY=" \
  "RADARR_API_KEY="

mk_secret ntfy-publisher.env \
  "# Compte de publication ntfy, en écriture seule sur un seul sujet." \
  "# Voir docs/notifications.md" \
  "NTFY_URL=https://ntfy.$DOMAIN" \
  "NTFY_TOPIC=homelab" \
  "NTFY_USER=publisher" \
  "NTFY_PASSWORD="

mk_secret arcane.env \
  "# Générer chaque valeur avec :" \
  "#   python3 -c \"import secrets; print(secrets.token_hex(32))\"" \
  "ENCRYPTION_KEY=" \
  "JWT_SECRET="

# ─────────────────────────────────────────────────────────────────────────────
step "Réseaux Docker"

for net in media monitoring web-ntfy; do
  if docker network inspect "$net" >/dev/null 2>&1; then
    ok "$net (déjà présent)"
  else
    docker network create "$net" >/dev/null && ok "$net créé"
  fi
done

# ─────────────────────────────────────────────────────────────────────────────
step "Validation des fichiers compose"

fail=0
for f in compose/*/*/compose.yml; do
  if docker compose -f "$f" config -q >/dev/null 2>&1; then
    :
  else
    warn "$f — erreur de syntaxe ou variable non résolue"
    fail=$((fail + 1))
  fi
done
[[ $fail -eq 0 ]] && ok "tous les compose sont valides" || warn "$fail fichier(s) en erreur"

# ─────────────────────────────────────────────────────────────────────────────
step "Permissions"

owner=$(stat -c '%u:%g' "$POOL_ROOT/media")
if [[ "$owner" == "${PUID}:${PGID}" ]]; then
  ok "le pool appartient à ${PUID}:${PGID}"
else
  warn "le pool appartient à $owner, mais les conteneurs tourneront en ${PUID}:${PGID}"
  warn "les *arr ne pourront ni renommer, ni déplacer, ni créer de hardlink :"
  echo "      sudo chown -R ${PUID}:${PGID} $POOL_ROOT"
  echo "      find $POOL_ROOT -type d -exec chmod 775 {} +"
fi

# ─────────────────────────────────────────────────────────────────────────────
echo
echo "${C_OK}Environnement prêt.${C_OFF} Rien n'a été démarré."
cat <<'NEXT'

  Suite — dans cet ordre (détail dans QUICKSTART.md) :

    1. DNS            deux A publics + un générique *.lan vers l'IP privée
    2. Redirections   WAN 443 → 443 et WAN 80 → 80. Rien d'autre.
    3. Proxy          cd compose/00-core/npm && docker compose up -d
    4. Certificats    deux wildcards en DNS-01 (un pour *.domaine,
                      un pour *.lan.domaine — un wildcard ne couvre
                      qu'un seul niveau)
    5. Média          les unités de compose/10-media/
    6. Vérifier       absence de fuite VPN, puis hardlinks effectifs
    7. Supervision    compose/90-monitoring/ et compose/00-core/crowdsec

  Ne considérez pas l'installation terminée avant l'étape 6.

NEXT
