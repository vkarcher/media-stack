# 🏠 Configuration de Homarr

**Homarr** est votre tableau de bord. C'est la page d'accueil que vous mettrez en favori sur tous vos appareils.

## 1. Premier Démarrage

Accédez à `http://<IP_NAS>:7575`.

Vous arrivez sur un tableau de bord vide ou par défaut.
Cliquez sur l'icône **"Mode Édition"** (souvent un crayon ou un toggle en haut à droite).

## 2. Ajouter vos Services

Pour chaque application de la stack, ajoutez une "Tuile" (Tile).

Voici les adresses standards (remplacez `<IP>` par l'IP locale de votre NAS, ex: `192.168.1.20`) :

| App | URL Interne |
|-----|-------------|
| **Jellyfin** | `http://<IP>:8096` |
| **Jellyseerr** | `http://<IP>:5055` |
| **qBittorrent** | `http://<IP>:8080` |
| **Sonarr** | `http://<IP>:8989` |
| **Radarr** | `http://<IP>:7878` |
| **Prowlarr** | `http://<IP>:9696` |

> **Astuce** : Homarr peut s'intégrer à ces services pour afficher des infos en direct (vitesse de téléchargement, nombre de films...). Cherchez l'onglet "Intégration" quand vous modifiez une tuile !

## 3. Personnalisation

- **Icônes** : Homarr inclut un moteur de recherche d'icônes. Tapez juste "Jellyfin" pour trouver le logo officiel.
- **Groupes** : Créez des catégories (ex: "Public" pour Jellyfin/Jellyseerr, "Admin" pour les autres).

## 4. Pour aller plus loin

Homarr permet aussi d'ajouter :
- Un widget **Calendrier** (connecté à Sonarr/Radarr pour voir les sorties futures).
- Un widget **Torrent** (connecté à qBittorrent pour voir les DL en cours).

## 5. Sauvegarde

Une fois fini, quittez le mode édition. Votre configuration est sauvegardée dans le dossier `/docker/homarr/configs` sur votre NAS.
