# 🎬 Media Stack

Stack média auto-hébergée complète : streaming, portail de requêtes, automatisation, reverse proxy, détection d'intrusion, supervision et notifications push.

**Ce dépôt n'est pas une liste de conteneurs.** Des listes de conteneurs, il en existe des centaines. Ce qu'il contient en plus, c'est **la raison de chaque choix** et **les pièges qui coûtent des heures** — ceux qui n'apparaissent dans aucun guide parce qu'on ne les découvre qu'en le faisant réellement.

Si vous ne lisez qu'un seul document, lisez **[docs/hardlinks.md](docs/hardlinks.md)**. C'est l'erreur qui fait consommer le double d'espace disque à 90 % des installations.

---

## Ce qui tourne

| Rôle | Services |
|---|---|
| **Streaming** | Jellyfin, Seerr *(ex-Jellyseerr)* |
| **Automatisation** | Sonarr, Radarr, Prowlarr, Bazarr, Recyclarr, Cleanuparr |
| **Téléchargement** | qBittorrent derrière Gluetun *(VPN, kill-switch)*, Flaresolverr |
| **Accès** | Nginx Proxy Manager, certificats wildcard Let's Encrypt |
| **Sécurité** | CrowdSec + bouncer pare-feu |
| **Supervision** | Gatus, Scrutiny *(SMART)*, ntfy *(push mobile)*, Arcane *(UI Docker)* |

Dix-neuf conteneurs, **tous à version épinglée**, un fichier compose par unité.

---

## Architecture

```
                          Internet
                             │
                    ┌────────┴────────┐
                    │   443  ·  80    │   ← seuls ports redirigés
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │      NPM        │  seul conteneur qui publie des ports
                    │  reverse proxy  │  seul conteneur multi-réseaux
                    └───┬─────────┬───┘
             ┌──────────┘         └──────────┐
        ┌────▼─────┐                   ┌─────▼─────┐
        │  media   │                   │ monitoring│
        ├──────────┤                   ├───────────┤
        │ jellyfin │                   │ gatus     │
        │ seerr    │                   │ scrutiny  │
        │ sonarr   │                   │ arcane    │
        │ radarr   │                   │ crowdsec  │
        │ prowlarr │                   └───────────┘
        │ bazarr   │
        │ gluetun ─┼── qbittorrent (network_mode: service:gluetun)
        └──────────┘
```

**Trois règles structurent tout :**

1. **Seul le reverse proxy publie des ports.** Tous les autres services restent en `expose` et ne sont joignables que par lui, à travers le réseau Docker. Résultat : aucun port à mémoriser, aucun conflit possible, et `ss -tlnp` sur l'hôte reste presque vide.

2. **Un compose par unité, jamais un monolithe.** Une unité = un service + ses dépendances privées. Un compose géant rend impossible l'arrêt d'un seul service depuis une interface — la plupart traitent un projet compose comme un bloc indivisible.

3. **Un montage `/data` unique** pour tout ce qui déplace des fichiers. C'est la condition des hardlinks. Voir [docs/hardlinks.md](docs/hardlinks.md).

---

## Les décisions qui comptent

### Un seul point de montage pour le média

```yaml
# ❌ Deux montages = le conteneur voit DEUX systèmes de fichiers
- /pool/media/movies:/movies
- /pool/torrents:/downloads

# ✅ Un seul montage, la racine du pool
- /pool:/data
```

Avec deux montages, Radarr constate deux périphériques différents, **abandonne le hardlink et copie**. Chaque film occupe alors deux fois la place : une copie seedée, une copie dans la bibliothèque. Sur 300 films, c'est plusieurs téraoctets perdus — et on ne s'en aperçoit qu'à disque plein.

→ **[docs/hardlinks.md](docs/hardlinks.md)** : le détail, et surtout **comment vérifier** qu'un hardlink a réellement fonctionné.

### Le scratch de téléchargement va sur le disque lent, pas sur le SSD

Contre-intuitif, et pourtant :

| | Emplacement | Pourquoi |
|---|---|---|
| `incomplete` *(téléchargement)* | **pool HDD** | À la fin du torrent, le fichier est **déplacé** vers `complete`. Sur un autre système de fichiers, ce déplacement devient une copie intégrale. |
| Cache de transcodage | **SSD** | Jetable, jamais déplacé, écritures aléatoires. |

Le critère n'est pas « gros ou petit », c'est **« sera-t-il déplacé ? »**. Un cache ne l'est jamais, un téléchargement toujours.

### Tags d'image figés, jamais `:latest`

`:latest` transforme chaque `docker compose pull` en loterie. Une montée de version majeure passe inaperçue jusqu'à ce qu'un service refuse de démarrer avec une base migrée dans un sens irréversible — c'est précisément ce qui rend une restauration impossible.

**Ne déployez pas Watchtower en mise à jour automatique.** Utilisez un notificateur (diun, ou les connecteurs `OnApplicationUpdate` de Sonarr/Radarr) : vous êtes prévenu, vous bumpez le tag, vous committez. La mise à jour devient une décision tracée.

### Les secrets ne sont jamais dans un compose

Le compose est versionné. Les secrets vivent dans `.env` *(interpolation)* ou `secrets/` *(fichiers montés)*, tous deux exclus de git. `.env.example` liste les clés attendues avec des valeurs vides : c'est votre documentation de ce qu'il faut fournir pour redéployer.

---

## Prérequis

- Un hôte Linux avec Docker et le plugin Compose
- Un nom de domaine, avec un DNS où vous pouvez créer des enregistrements
- **Un seul système de fichiers** pour `media/` et `torrents/` *(voir hardlinks)*
- Un abonnement VPN compatible [gluetun](https://github.com/qdm12/gluetun-wiki) si vous passez par du torrent
- De la RAM : le cache disque évite l'essentiel des accès aux plateaux. 16 Go confortable, 8 Go suffisant.

Le transcodage matériel *(`/dev/dri`)* est optionnel mais change tout dès deux flux simultanés.

---

## Installation

→ **[QUICKSTART.md](QUICKSTART.md)** — de zéro à Jellyfin en ligne.

---

## Documentation

| Document | Contenu |
|---|---|
| **[hardlinks.md](docs/hardlinks.md)** | Le piège n°1, et la méthode de vérification |
| **[architecture.md](docs/architecture.md)** | Réseaux, nommage, découpage des compose |
| **[reverse-proxy.md](docs/reverse-proxy.md)** | Wildcards, DNS-01, sous-domaines privés, le port 80 |
| **[securite.md](docs/securite.md)** | CrowdSec, `DOCKER-USER`, ce qui bloque réellement |
| **[notifications.md](docs/notifications.md)** | ntfy, push iOS, brancher chaque service |
| **[migration.md](docs/migration.md)** | Reprendre une installation existante sans rien perdre |
| **[pieges.md](docs/pieges.md)** | Tout ce qui a coûté du temps, et pourquoi |

---

## Pour aller plus loin

Non déployés ici, mais pertinents selon votre situation :

**`autobrr`** — écoute les canaux d'annonce IRC des trackers privés et récupère une release **quelques secondes** après sa publication, là où un cycle RSS attend des minutes. Sur un tracker privé, être premier sur un torrent signifie être seeder de référence pour des dizaines de leechers : l'effet sur le ratio n'a aucune commune mesure avec le reste.

**`cross-seed`** — trouve, sur d'autres trackers, les torrents correspondant aux fichiers que vous possédez **déjà**. Vous seedez les mêmes données sur plusieurs sources sans télécharger un octet. Demande au moins deux trackers pour avoir du sens.

**`Wizarr`** — liens d'invitation pour Jellyfin : la personne clique, crée son compte, reçoit les bonnes bibliothèques. Utile dès une dizaine d'utilisateurs.

**`Tdarr`** — transcodage de masse vers H.265. ⚠️ **Il réécrit vos fichiers.** Un profil mal réglé ou un job interrompu, et l'original est perdu. À n'envisager qu'avec une sauvegarde en place, ou en conservant les originaux — ce qui annule le gain d'espace.

---

## Licence

MIT. Faites-en ce que vous voulez.
