# 🧩 Exemples Modulaires Docker

Ce dossier contient des configurations **prêtes à l'emploi** si vous ne souhaitez pas installer toute la stack "Ultimate".

## Comment les utiliser ?

Chaque sous-dossier contient un `docker-compose.yml` indépendant.
Vous pouvez :
1. Entrer dans le dossier (ex: `cd jellyfin`)
2. Lancer juste cette partie : `docker-compose up -d`

## Les modules disponibles

| Module | Contenu |
|--------|---------|
| **[jellyfin](./jellyfin)** | Jellyfin (Serveur Média) + Jellyseerr (Demandes) |
| **[arr-stack](./arr-stack)** | Sonarr, Radarr, Prowlarr, Bazarr (Automatisation) |
| **[downloads](./downloads)** | qBittorrent + FlareSolverr (Téléchargement) |
| **[dashboard](./dashboard)** | Homarr (Accueil) + Watchtower (Mises à jour) |

> **Note** : Ces fichiers utilisent aussi les variables du fichier `.env` à la racine. Assurez-vous d'avoir configuré le `.env` avant de lancer un module !
