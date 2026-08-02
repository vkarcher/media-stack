#!/bin/sh
# ==============================================================================
#  Notification ntfy unifiée pour Sonarr, Radarr et Prowlarr
# ==============================================================================
#  Appelé par le connecteur « Custom Script » de chaque application.
#
#  Pourquoi un script plutôt que le connecteur Ntfy natif : celui-ci impose un
#  titre du type « Sonarr - Health Check Failure » et des tags statiques. On ne
#  peut donc pas faire varier la pastille selon la gravité.
#
#  Format produit — compact, deux lignes maximum :
#     Titre   : <pastille> <Application>
#     Corps   : le problème en clair
#               ↳ contexte technique
#
#  Pas de ligne vide : l'espace d'affichage d'une notification est court, et
#  la gravité est déjà portée par la pastille — inutile de la répéter en mots.
#
#  Pastilles :  🔴 panne   🟠 avertissement   🟢 résolu   🔵 information
# ==============================================================================

set -u

# --- Identifiants ntfy (fichier monté en lecture seule) ----------------------
NTFY_ENV=/run/secrets/ntfy.env
[ -f "$NTFY_ENV" ] || { echo "notify: $NTFY_ENV introuvable" >&2; exit 1; }
. "$NTFY_ENV"

# --- Quelle application nous appelle ? ---------------------------------------
APP=""
for p in sonarr radarr prowlarr; do
  eval "v=\${${p}_eventtype:-}"
  [ -n "$v" ] && { APP="$p"; EVENT="$v"; break; }
done
[ -n "$APP" ] || { echo "notify: aucune variable d'événement reconnue" >&2; exit 1; }

get() { eval "printf '%s' \"\${${APP}_$1:-}\""; }

case "$APP" in
  sonarr)   LABEL="Sonarr" ;;
  radarr)   LABEL="Radarr" ;;
  prowlarr) LABEL="Prowlarr" ;;
esac

# --- Gravité, pastille, priorité ---------------------------------------------
# La priorité ntfy pilote le comportement du téléphone : 4 perce le mode
# silencieux, 2 arrive sans bruit. Une résolution ne doit pas réveiller.
case "$EVENT" in
  HealthIssue)
    LEVEL=$(get health_issue_level)
    BODY=$(get health_issue_message)
    DETAIL=$(get health_issue_type)
    if [ "$LEVEL" = "Error" ]; then
      BADGE="🔴"; PRIO=4
    else
      BADGE="🟠"; PRIO=3
    fi
    ;;
  HealthRestored)
    BADGE="🟢"; PRIO=2
    BODY="Résolu : $(get health_restored_message)"
    DETAIL=$(get health_restored_type)
    ;;
  ApplicationUpdate)
    BADGE="🔵"; PRIO=3
    BODY="Mise à jour disponible : $(get update_newversion)"
    DETAIL="version actuelle $(get update_previousversion)"
    ;;
  ManualInteractionRequired)
    BADGE="🟠"; PRIO=4
    BODY="Intervention requise : $(get download_client_item_title)"
    DETAIL="téléchargement bloqué"
    ;;
  Test)
    BADGE="🔵"; PRIO=2
    BODY="Canal de notification fonctionnel"
    DETAIL="format unifié"
    ;;
  *)
    BADGE="🔵"; PRIO=3
    BODY="$EVENT"
    DETAIL=""
    ;;
esac

[ -n "$BODY" ] || BODY="(aucun détail fourni par $LABEL)"

# --- Corps du message --------------------------------------------------------
MSG="$BODY"
[ -n "$DETAIL" ] && MSG="$MSG
↳ $DETAIL"

# --- Envoi -------------------------------------------------------------------
curl -s -m 15 -o /dev/null \
  -u "${NTFY_USER}:${NTFY_PASSWORD}" \
  -H "Title: ${BADGE} ${LABEL}" \
  -H "Priority: ${PRIO}" \
  -H "Markdown: no" \
  -d "$MSG" \
  "${NTFY_URL}/${NTFY_TOPIC}"
