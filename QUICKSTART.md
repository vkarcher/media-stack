# 🚀 Quickstart

De zéro à Jellyfin accessible depuis Internet. Comptez une heure la première fois.

L'ordre n'est pas cosmétique : chaque étape fige des chemins que la suivante consomme.

---

## 1. Arborescence

Créez la structure **avant** de démarrer quoi que ce soit. La réorganiser après indexation par les *arr coûte une réindexation complète.

```bash
export STACK_ROOT=/srv/homelab
export POOL_ROOT=/mnt/pool

sudo mkdir -p $STACK_ROOT/{appdata,cache,secrets,backups}
sudo mkdir -p $POOL_ROOT/media/{movies,series,anime}
sudo mkdir -p $POOL_ROOT/torrents/{complete,incomplete}

# UN SEUL utilisateur pour tous les conteneurs.
sudo chown -R $(id -u):$(id -g) $STACK_ROOT $POOL_ROOT
find $POOL_ROOT -type d -exec chmod 775 {} +
```

> ⚠️ **`media/` et `torrents/` doivent être sur le même système de fichiers.** Vérifiez-le maintenant :
> ```bash
> stat -c '%d' $POOL_ROOT/media $POOL_ROOT/torrents   # les deux nombres doivent être identiques
> ```
> S'ils diffèrent, arrêtez-vous et lisez [docs/hardlinks.md](docs/hardlinks.md). Continuer vous fera consommer le double d'espace.

---

## 2. Paramètres

```bash
git clone <ce-depot> $STACK_ROOT/compose
cd $STACK_ROOT/compose

cp .env.example .env
cp common.env.example common.env
$EDITOR .env          # domaine, chemins, PUID/PGID, clé VPN
```

Puis un lien `.env` dans chaque dossier de service :

```bash
for d in compose/*/*/; do (cd "$d" && ln -sfn ../../../.env .env); done
```

> **Pourquoi ces liens ?** Compose ne lit le `.env` que dans le répertoire du compose, **jamais dans un parent**. Sans eux, `${DOMAIN}` et les autres variables ne sont pas résolues — et gluetun démarrerait sans clé VPN, silencieusement.

Sécurisez les fichiers sensibles :

```bash
chmod 600 .env
chmod 700 $STACK_ROOT/secrets
```

---

## 3. Réseaux Docker

```bash
docker network create media
docker network create monitoring
docker network create web-ntfy
```

Séparés volontairement : un service public compromis ne doit avoir **aucune route** vers le reste. Détail dans [docs/architecture.md](docs/architecture.md).

---

## 4. DNS

Deux séries d'enregistrements chez votre fournisseur :

| Enregistrement | Type | Cible | Usage |
|---|---|---|---|
| `stream` | A | votre **IP publique** | Jellyfin |
| `request` | A | votre **IP publique** | Seerr |
| `*.lan` | A | votre **IP privée** *(ex. 192.168.1.10)* | tous les services internes |

Le générique `*.lan` est ce qui vous évite de retoucher au DNS à chaque service ajouté : `sonarr.lan`, `radarr.lan`, `gatus.lan` résolvent automatiquement.

> **Une IP privée dans un DNS public**, c'est volontaire et sans risque : elle est injoignable depuis Internet. Chez vous ou via votre VPN, le nom résout et le proxy répond avec un certificat valide. Certains résolveurs bloquent toutefois ce genre de réponse (protection anti-DNS-rebinding) — testez avec `dig +short A test.lan.votre-domaine` avant de construire dessus.

---

## 5. Redirections de ports

Sur votre routeur, **deux règles, pas plus** :

| WAN | LAN | Commentaire |
|---|---|---|
| 443 | 443 | HTTPS |
| 80 | 80 *(ou 8180)* | redirection HTTP→HTTPS |

Le côté **WAN doit rester 80 et 443** : c'est ce que composent les navigateurs. Seul le port LAN change si le 80 de l'hôte est déjà occupé.

> ⚠️ **N'exposez jamais** l'interface d'administration du proxy (81), la WebUI de qBittorrent (8080), ni aucune interface *arr. Elles passent par le proxy en `.lan`, accessibles depuis chez vous ou par VPN.

---

## 6. Reverse proxy et certificats

```bash
cd compose/00-core/npm && docker compose up -d
```

Administration sur `http://<ip-serveur>:81` — identifiants par défaut `admin@example.com` / `changeme`, à changer immédiatement.

**Émettez deux certificats wildcard**, tous les deux en **DNS-01** :

| Certificat | Couvre |
|---|---|
| `votre-domaine.com` + `*.votre-domaine.com` | les services publics |
| `*.lan.votre-domaine.com` | les services internes |

> ⚠️ **Un wildcard ne couvre qu'UN seul niveau.** `*.votre-domaine.com` matche `stream.votre-domaine.com` mais **pas** `sonarr.lan.votre-domaine.com`. C'est l'erreur classique : on croit avoir tout couvert et la moitié des services servent un certificat invalide.
>
> Le DNS-01 est **obligatoire** pour les hôtes `.lan` : Let's Encrypt ne peut pas atteindre une IP privée pour valider en HTTP-01.

Puis appliquez les deux fichiers de configuration nginx personnalisée :

```bash
docker exec npm mkdir -p /data/nginx/custom
docker cp compose/00-core/npm/custom/http_top.conf     npm:/data/nginx/custom/
docker cp compose/00-core/npm/custom/server_proxy.conf npm:/data/nginx/custom/
docker exec npm nginx -t && docker exec npm nginx -s reload
```

Le rechargement est **à chaud** : aucune connexion coupée. Ces deux fichiers ferment le serveur par défaut du port 80 et ajoutent un journal lisible par CrowdSec. Détail dans [docs/securite.md](docs/securite.md).

---

## 7. La stack média

```bash
cd $STACK_ROOT/compose/compose
for u in 10-media/jellyfin 10-media/seerr 10-media/download \
         10-media/prowlarr 10-media/sonarr 10-media/radarr \
         10-media/bazarr 10-media/flaresolverr; do
  (cd $u && docker compose up -d)
done
```

**Vérifiez immédiatement l'absence de fuite VPN** — avant tout téléchargement :

```bash
curl -s https://ifconfig.io                              # votre IP réelle
docker exec gluetun wget -qO- https://ifconfig.io        # doit être DIFFÉRENTE
```

Si les deux sont identiques, **arrêtez qBittorrent** et corrigez gluetun avant d'aller plus loin.

---

## 8. Proxy hosts

Un par service, dans l'interface du proxy :

| Domaine | Cible | Port |
|---|---|---|
| `stream.votre-domaine` | `jellyfin` | 8096 |
| `request.votre-domaine` | `seerr` | 5055 |
| `sonarr.lan.votre-domaine` | `sonarr` | 8989 |
| `radarr.lan.votre-domaine` | `radarr` | 7878 |
| `prowlarr.lan.votre-domaine` | `prowlarr` | 9696 |
| `bazarr.lan.votre-domaine` | `bazarr` | 6767 |

**Le nom du conteneur suffit** comme cible : le proxy est sur le même réseau Docker. Ne mettez pas l'IP de l'hôte — ces services ne publient aucun port.

Réglages pour chacun : `Block Common Exploits` ✅, **`Websockets Support` ✅** *(les *arr utilisent SignalR : sans websockets, leur interface se figera)*, et dans l'onglet SSL : le bon wildcard, `Force SSL`, `HTTP/2`, **`HSTS`**.

> **Activez HSTS.** Après une première visite en `https://`, le navigateur convertit automatiquement tout `http://` ultérieur. C'est ce qui évite de tomber sur autre chose en tapant l'adresse sans préfixe.

---

## 9. Câbler les services entre eux

Dans cet ordre — chaque étape conditionne la suivante :

1. **Prowlarr** → ajoutez vos indexeurs, puis Settings → Apps → Sonarr et Radarr *(URL : `http://sonarr:8989`)*
2. **Sonarr / Radarr** → Settings → Download Clients → qBittorrent

   > ⚠️ **L'hôte est `gluetun`, pas `qbittorrent`.** qBittorrent tourne en `network_mode: service:gluetun` : il n'a aucune identité réseau propre. `qbittorrent:8080` ne résout pas ; `gluetun:8080` répond.

3. **Sonarr / Radarr** → Root Folders : `/data/media/movies`, `/data/media/series`
4. **Bazarr** → Settings → Sonarr et Radarr, puis **au moins un fournisseur de sous-titres** *(compte requis)* et un profil de langue. Sans ça, il ne télécharge rien.
5. **Seerr** → connectez Jellyfin, puis Sonarr et Radarr

   > ⚠️ **Seerr garde sa PROPRE copie du dossier racine.** Si vous le changez dans Radarr, changez-le aussi ici, sinon les demandes échouent en silence : « requested » côté Seerr, jamais rien dans Radarr.

---

## 10. Vérifier que les hardlinks fonctionnent

**Ne considérez pas l'installation terminée avant ce test.** Après le premier import :

```bash
# Un seul système de fichiers vu par le conteneur ?
docker exec radarr df -h | grep /data      # doit apparaître UNE fois

# Le fichier est-il partagé, ou dupliqué ?
ls -li /mnt/pool/torrents/complete/<fichier>.mkv \
       /mnt/pool/media/movies/<Film>/<fichier>.mkv
```

Même **numéro d'inode** et compteur de liens à **2** = hardlink effectif.

Deux inodes différents = vous copiez sans le savoir, et vous ne le découvrirez qu'à disque plein. → [docs/hardlinks.md](docs/hardlinks.md)

---

## 11. Supervision et sécurité

Une fois le média fonctionnel :

```bash
cd $STACK_ROOT/compose/compose
(cd 90-monitoring/ntfy      && docker compose up -d)   # notifications
(cd 90-monitoring/scrutiny  && docker compose up -d)   # SMART
(cd 90-monitoring/gatus     && docker compose up -d)   # disponibilité
(cd 00-core/crowdsec        && docker compose up -d)   # détection
(cd 00-core/crowdsec-bouncer && docker compose up -d)  # blocage
```

Chacun demande une configuration propre — voir [docs/securite.md](docs/securite.md) et [docs/notifications.md](docs/notifications.md).

> ⚠️ **Vérifiez `real_ip` avant d'activer CrowdSec en blocage** si vous avez un CDN devant votre proxy. Sans ça, le premier bannissement viserait le CDN et couperait tous vos services d'un coup.
