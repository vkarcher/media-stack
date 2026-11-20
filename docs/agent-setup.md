# Installation par un agent

Ce document s'adresse à un agent de code qui installe la stack pour un humain. Il donne l'ordre, les commandes, la preuve attendue à chaque étape et les points où il faut s'arrêter. Les raisons de fond sont dans les autres documents : ne les recopiez pas, suivez les liens en cas de doute.

## Règles

1. **Ne démarrez rien avant la phase 3.** `install.sh` ne démarre aucun conteneur, c'est voulu.
2. **Jamais de secret dans un fichier versionné, une ligne de commande ou votre réponse.** Les valeurs vont dans `.env` ou `secrets/`, tous deux exclus de Git. Faites saisir les secrets par l'humain.
3. **Jamais d'image en `:latest`.** Ne modifiez pas les tags sans demande.
4. **Ne publiez aucun port de plus.** Seuls le reverse proxy (80, 443) et le port torrent sont publiés. N'exposez jamais l'administration du proxy (81), la WebUI de qBittorrent (8080) ni une interface `*arr`.
5. **Un point de blocage n'est pas un obstacle à contourner.** Si une vérification échoue, arrêtez-vous, dites laquelle et pourquoi, et demandez.
6. **Ne considérez pas l'installation terminée avant la phase 6.**

## Ce que vous devez demander à l'humain

Ne devinez aucune de ces valeurs.

| Variable | Exemple | Remarque |
|---|---|---|
| `DOMAIN` | `exemple.com` | Domaine dont l'humain gère le DNS |
| `JELLYFIN_SUBDOMAIN`, `SEERR_SUBDOMAIN` | `stream`, `request` | Sous-domaines publics |
| `SERVER_LAN_IP` | `192.168.1.10` | IP privée du serveur |
| `STACK_ROOT` | `/srv/homelab` | Bases et configuration, de préférence SSD |
| `POOL_ROOT` | `/mnt/pool` | Un seul montage contenant `media/` et `torrents/` |
| `PUID`, `PGID` | `1000`, `1000` | Doivent posséder `POOL_ROOT` |
| `TZ` | `Europe/Paris` | |
| `VPN_SERVICE_PROVIDER`, `VPN_TYPE`, `SERVER_COUNTRIES` | `nordvpn`, `wireguard` | Voir le wiki de gluetun |
| `WIREGUARD_PRIVATE_KEY` | | **Secret**, saisi par l'humain |

Demandez aussi : le port 80 de l'hôte est-il libre ? Sinon, `NPM_HTTP_PORT=8180` et la redirection WAN 80 doit viser ce port.

## Phase 0 : contrôles de l'hôte

```bash
docker version --format '{{.Server.Version}}'
docker compose version --short
id -u; id -g
df -h "$POOL_ROOT"
ss -tln | grep -E ':(80|443|81)\b'
```

Arrêtez-vous si Docker ou le plugin Compose manque, ou si le port 80 ou 443 est occupé sans solution convenue.

## Phase 1 : configuration

```bash
cp .env.example .env
```

Remplissez `.env` avec les valeurs de l'humain, sauf `WIREGUARD_PRIVATE_KEY` qu'il saisit lui-même. Puis :

```bash
./install.sh
```

Le script est idempotent. Il vérifie les prérequis, crée l'arborescence, crée les liens `.env` par service, les réseaux `media`, `monitoring` et `web-ntfy`, les gabarits de secrets, valide chaque compose et contrôle les permissions.

**Preuve attendue :** la ligne « media/ et torrents/ sont sur le MÊME système de fichiers » et « tous les compose sont valides ».

**Arrêtez-vous** si le script refuse de continuer sur les hardlinks : `POOL_ROOT` est mal choisi, lisez [hardlinks.md](hardlinks.md) et demandez à l'humain. Ne contournez pas le test.

Remplissez ensuite les gabarits `secrets/*.env` au moment de déployer le service concerné : `recyclarr.env`, `ntfy-publisher.env`, `arcane.env`. Les valeurs de `arcane.env` se génèrent avec `python3 -c "import secrets; print(secrets.token_hex(32))"` sans les afficher.

## Phase 2 : actions de l'humain

Vous ne pouvez pas les faire à sa place. Donnez-lui la liste, attendez sa confirmation.

| Action | Détail |
|---|---|
| DNS | Deux enregistrements A publics (`stream`, `request`) vers l'IP publique, un générique `*.lan` vers `SERVER_LAN_IP` |
| Routeur | WAN 443 vers 443 et WAN 80 vers 80 (ou 8180). Aucune autre redirection |
| Jeton DNS | Un jeton API du fournisseur DNS, pour les certificats wildcard en DNS-01 |

**Preuve attendue :** `dig +short stream.$DOMAIN` renvoie l'IP publique, `dig +short test.lan.$DOMAIN` renvoie `SERVER_LAN_IP`.

## Phase 3 : reverse proxy et certificats

```bash
(cd compose/00-core/npm && docker compose up -d)
```

L'administration est sur `http://<ip-serveur>:81`. Les identifiants par défaut sont dans [QUICKSTART.md](../QUICKSTART.md) : l'humain doit les changer immédiatement.

Deux certificats wildcard en DNS-01, créés dans l'interface avec l'humain :

- `$DOMAIN` et `*.$DOMAIN`
- `*.lan.$DOMAIN` (un wildcard ne couvre qu'un niveau, les deux sont nécessaires)

Puis les deux fichiers nginx personnalisés :

```bash
docker exec npm mkdir -p /data/nginx/custom
docker cp compose/00-core/npm/custom/http_top.conf     npm:/data/nginx/custom/
docker cp compose/00-core/npm/custom/server_proxy.conf npm:/data/nginx/custom/
docker exec npm nginx -t && docker exec npm nginx -s reload
```

**Preuve attendue :** `nginx -t` répond `syntax is ok` et `test is successful`.

## Phase 4 : stack média

N'allez pas plus loin si `WIREGUARD_PRIVATE_KEY` est vide.

```bash
for u in jellyfin seerr download prowlarr sonarr radarr bazarr flaresolverr; do
  (cd compose/10-media/$u && docker compose up -d)
done
```

**Contrôle de fuite VPN, avant tout téléchargement :**

```bash
curl -s https://ifconfig.io
docker exec gluetun wget -qO- https://ifconfig.io
```

Les deux adresses doivent être différentes. Si elles sont identiques, arrêtez qBittorrent (`cd compose/10-media/download && docker compose stop`), signalez-le et ne continuez pas.

## Phase 5 : proxy hosts et câblage

Un proxy host par service dans l'interface de NPM. Le nom du conteneur sert de cible, jamais l'IP de l'hôte.

| Domaine | Cible | Port |
|---|---|---|
| `stream.$DOMAIN` | `jellyfin` | 8096 |
| `request.$DOMAIN` | `seerr` | 5055 |
| `sonarr.lan.$DOMAIN` | `sonarr` | 8989 |
| `radarr.lan.$DOMAIN` | `radarr` | 7878 |
| `prowlarr.lan.$DOMAIN` | `prowlarr` | 9696 |
| `bazarr.lan.$DOMAIN` | `bazarr` | 6767 |

Pour chacun : Websockets activés, Force SSL, HSTS, bon wildcard. Sans websockets, l'interface des `*arr` se fige.

Câblage, dans cet ordre (détail dans [QUICKSTART.md](../QUICKSTART.md), section 9) :

1. Prowlarr : indexeurs, puis applications Sonarr et Radarr.
2. Sonarr et Radarr : client de téléchargement. **L'hôte est `gluetun`, pas `qbittorrent`.**
3. Sonarr et Radarr : dossiers racine `/data/media/movies` et `/data/media/series`.
4. Bazarr : Sonarr, Radarr, un fournisseur de sous-titres (compte requis).
5. Seerr : Jellyfin, puis Sonarr et Radarr, avec les mêmes dossiers racine que Radarr.

Les clés d'API et les comptes sont saisis par l'humain.

## Phase 6 : vérifier les hardlinks

Après le premier import réel :

```bash
docker exec radarr df -h | grep /data
ls -li "$POOL_ROOT/torrents/complete/<fichier>.mkv" "$POOL_ROOT/media/movies/<Film>/<fichier>.mkv"
```

**Preuve attendue :** `/data` apparaît une seule fois, les deux fichiers ont le même numéro d'inode et un compteur de liens de 2. Deux inodes différents veulent dire que la stack copie : arrêtez-vous et lisez [hardlinks.md](hardlinks.md).

## Phase 7 : supervision et sécurité

Seulement une fois le média fonctionnel.

```bash
for u in 90-monitoring/ntfy 90-monitoring/scrutiny 90-monitoring/gatus 00-core/crowdsec 00-core/crowdsec-bouncer; do
  (cd compose/$u && docker compose up -d)
done
```

Chaque unité demande sa propre configuration : [securite.md](securite.md) et [notifications.md](notifications.md). **Avant d'activer CrowdSec en blocage**, vérifiez `real_ip` si un CDN est devant le proxy : sans cela, le premier bannissement viserait le CDN et couperait tous les services.

## Fin de l'installation

L'installation est terminée quand :

- [ ] `docker ps` montre tous les services démarrés, aucun en redémarrage en boucle
- [ ] le contrôle de fuite VPN a donné deux adresses différentes
- [ ] Jellyfin répond en HTTPS sur `stream.$DOMAIN` avec un certificat valide
- [ ] un import réel a produit un hardlink (inode identique, liens à 2)
- [ ] aucun port autre que 80, 443 et le port torrent n'est publié sur l'hôte

Rendez compte à l'humain de ce que vous avez vérifié, de ce que vous n'avez pas pu vérifier, et des étapes qu'il lui reste (indexeurs, comptes de sous-titres, invitations).

## En cas d'échec

Lisez [pieges.md](pieges.md) avant d'essayer autre chose : la plupart des échecs de cette stack y sont décrits, avec la cause.
