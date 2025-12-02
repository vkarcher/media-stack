# 📦 Stack Média Automatisée — Synology DS224+ + Freebox + Docker

[![Sonarr](https://img.shields.io/docker/v/linuxserver/sonarr/latest?label=Sonarr&logo=sonarr&color=blue)](https://github.com/Sonarr/Sonarr)
[![Radarr](https://img.shields.io/docker/v/linuxserver/radarr/latest?label=Radarr&logo=radarr&color=blue)](https://github.com/Radarr/Radarr)
[![Prowlarr](https://img.shields.io/docker/v/linuxserver/prowlarr/latest?label=Prowlarr&logo=prowlarr&color=blue)](https://github.com/Prowlarr/Prowlarr)
[![qBittorrent](https://img.shields.io/docker/v/linuxserver/qbittorrent/latest?label=qBittorrent&logo=qbittorrent&color=blue)](https://www.qbittorrent.org/)
[![Overseerr](https://img.shields.io/docker/v/linuxserver/overseerr/latest?label=Overseerr&logo=overseerr&color=blue)](https://overseerr.dev/)
[![Plex](https://img.shields.io/badge/Plex-compatible-orange?logo=plex)](https://www.plex.tv/)
[![Docker](https://img.shields.io/badge/Docker-required-2496ED?logo=docker)](https://www.docker.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

![GitHub stars](https://img.shields.io/github/stars/vkarcher/media-stack?style=social)
![GitHub forks](https://img.shields.io/github/forks/vkarcher/media-stack?style=social)
![GitHub issues](https://img.shields.io/github/issues/vkarcher/media-stack)
![GitHub last commit](https://img.shields.io/github/last-commit/vkarcher/media-stack)

> Guide complet pour déployer une stack média automatisée sur un NAS Synology : **Overseerr → Radarr / Sonarr → Prowlarr → qBittorrent → Plex**

---

## 🎯 Navigation rapide

- **⚡ Installation rapide (5 min)** → [`QUICKSTART.md`](QUICKSTART.md)
- **🌐 Configuration Freebox détaillée** → [`FREEBOX_SETUP.md`](FREEBOX_SETUP.md)
- **🔧 FAQs & Troubleshooting** → [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)
- **📚 Documentation complète** → [`docs/`](docs/README.md)

## 📚 Documentation exhaustive

Ce dépôt contient une **documentation ultra-complète** pour débutants :

### 🔧 Guides par application
- [qBittorrent](docs/apps/01-qbittorrent.md) — Configuration complète du client torrent
- [Prowlarr](docs/apps/02-prowlarr.md) — Gestion des indexers et trackers
- [Radarr](docs/apps/03-radarr.md) — Automatisation des films
- [Sonarr](docs/apps/04-sonarr.md) — Automatisation des séries + animés
- [Overseerr](docs/apps/05-overseerr.md) — Interface de demande utilisateur
- [Plex](docs/apps/06-plex.md) — Serveur média et streaming
- [FlareSolverr](docs/apps/07-flaresolverr.md) — Bypass Cloudflare

### 🎓 Guides thématiques
- **[YGGTorrent Setup](docs/guides/yggtorrent-setup.md)** — Installation complète YGG + FlareSolverr
- **[YGGTorrent Profils](docs/guides/yggtorrent-profiles.md)** — 3 configurations (Légit / Équilibré / Risqué)
- **[Configuration Animés](docs/guides/anime-configuration.md)** — Guide complet pour les animés
- **[VPN Setup](docs/guides/vpn-setup.md)** — WireGuard pour sécuriser qBittorrent

**→ [Index complet de la documentation](docs/README.md)**

---

## 📖 Sommaire

1. [Vue d'ensemble](#-vue-densemble)
2. [Architecture & Flux](#-architecture--flux)
3. [Prérequis](#%EF%B8%8F-prérequis)
4. [Structure des dossiers](#-structure-des-dossiers)
5. [Installation](#-installation)
   - [5.1 Étape 1 : SSH sur le NAS](#étape-1--ssh-sur-le-nas)
   - [5.2 Étape 2 : Lancer le script de setup](#étape-2--lancer-le-script-de-setup)
6. [Configuration des applications](#%EF%B8%8F-configuration-des-applications)
   - [6.1 qBittorrent](#qbittorrent)
   - [6.2 Prowlarr](#prowlarr)
   - [6.3 Radarr](#radarr)
   - [6.4 Sonarr](#sonarr)
   - [6.5 Configuration Sonarr pour les animés](#-configuration-sonarr-pour-les-animés)
   - [6.6 Overseerr](#overseerr)
7. [Configuration réseau (Freebox)](#-configuration-réseau-freebox)
8. [Sécurité & VPN](#-sécurité--vpn)
9. [Maintenance](#-maintenance)
10. [FAQ](#-faq)
11. [Extensions possibles](#-extensions-possibles)
12. [Licence](#-licence)

---

## 🧠 Vue d'ensemble

### Objectif

Mettre en place un système entièrement automatisé où :
- L'utilisateur demande du contenu via **Overseerr**
- **Radarr / Sonarr** traitent automatiquement la demande
- **Prowlarr** trouve les meilleures sources (trackers)
- **qBittorrent** télécharge automatiquement
- Le NAS trie, renomme et classe intelligemment
- **Plex** diffuse instantanément sur tous vos appareils

**✅ Zéro manipulation manuelle après la configuration initiale**

### Services inclus

| Service | Rôle | Port |
|---------|------|------|
| **Plex** | Serveur média (streaming) | 32400 |
| **Overseerr** | Interface de demande pour utilisateurs | 5055 |
| **Radarr** | Gestion automatique des films | 7878 |
| **Sonarr** | Gestion automatique des séries (+ animés) | 8989 |
| **Prowlarr** | Gestionnaire d'indexers/trackers | 9696 |
| **qBittorrent** | Client torrent | 8080 |
| **WireGuard** (optionnel) | VPN pour sécuriser les téléchargements | 51820 |

---

## 🔁 Architecture & Flux

```
┌─────────────────┐
│   Utilisateur   │
│   (Overseerr)   │
└────────┬────────┘
         │ 1. Demande film/série
         ▼
┌─────────────────┐
│ Radarr / Sonarr │
└────────┬────────┘
         │ 2. Recherche contenu
         ▼
┌─────────────────┐
│    Prowlarr     │◄──── Indexers/Trackers
└────────┬────────┘      (YGGTorrent, Nyaa.si, etc.)
         │ 3. Trouve le meilleur torrent
         ▼
┌─────────────────┐
│   qBittorrent   │◄──── (Optionnel: VPN WireGuard)
└────────┬────────┘
         │ 4. Télécharge
         ▼
┌─────────────────┐
│ Dossiers média  │
│  (NAS/Docker)   │
└────────┬────────┘
         │ 5. Renommage + Classement auto
         ▼
┌─────────────────┐
│      Plex       │
└────────┬────────┘
         │ 6. Streaming instantané
         ▼
    📺 TV, 📱 Mobile, 💻 PC
```

---

## 🛠️ Prérequis

- ✅ **NAS Synology** (DSM 7.2+)
- ✅ **Freebox** (ou routeur avec redirection de ports)
- ✅ **Docker / Container Manager** installé sur le NAS
- ✅ **Accès SSH** au NAS
- ✅ **Plex Media Server** ([Télécharger ici](https://www.plex.tv/fr/media-server-downloads/?cat=nas&plat=synology-dsm72))


---

## 📁 Structure des dossiers

Le script crée automatiquement cette structure optimisée :

```
/volume1/
├─ docker/
│  ├─ r-apps/
│  │  ├─ prowlarr/config
│  │  ├─ qbittorrent/config
│  │  ├─ radarr/config
│  │  ├─ sonarr/config
│  │  ├─ overseerr/config
│  │  └─ wireguard/config (optionnel)
│  └─ docker-compose.yml
├─ media/
│  ├─ movies      # Films classés par Radarr
│  ├─ series      # Séries classées par Sonarr
│  └─ anime       # Animés (optionnel, même Sonarr)
└─ torrents/
   ├─ complete/
   │  ├─ movies
   │  ├─ series
   │  └─ anime (optionnel)
   └─ incomplete   # Téléchargements en cours
```

> **💡 Note importante** : Les animés utilisent le **même Sonarr** que les séries classiques, avec un dossier racine séparé. Pas besoin d'instance Docker supplémentaire !

---

## 🚀 Installation

### Étape 1 : SSH sur le NAS

```bash
ssh admin@<IP_NAS>
```

**Sur le NAS : Panneau de configuration > Terminal & SNMP > Activer SSH (port 22)**

### Étape 2 : Lancer le script de setup

```bash
# Se connecter en root
sudo -i

# Cloner ou télécharger ce dépôt
cd /volume1
git clone https://github.com/vkarcher/media-stack.git
cd media-stack

# Lancer le script
chmod +x setup.sh
./setup.sh
```

Le script pose des questions interactives :
```
Inclure support pour les animés ? (y/n) [y]
→ Crée les dossiers /media/anime et /torrents/complete/anime

Installer WireGuard VPN pour qBittorrent ? (y/n) [n]
→ Recommandé pour la sécurité (masque votre IP)
```

**Le script fait automatiquement :**
1. ✅ Crée la structure des dossiers
2. ✅ Configure les permissions
3. ✅ Installe Docker Compose (si nécessaire)
4. ✅ Lance tous les services Docker

**⏱️ Temps : ~2-5 minutes selon la connexion internet**

---

## ⚙️ Configuration des applications

Une fois le script terminé, accédez aux interfaces web pour configurer chaque service :

### qBittorrent

**URL :** `http://<IP_NAS>:8080`

**Identifiants par défaut :**
- Login : `admin`
- Password : `adminadmin`

**Configuration requise :**

1. **Changer le mot de passe** (Outils > Options > Web UI > Authentification)

2. **Créer les catégories** (Catégories > Clic droit > Ajouter une catégorie) :

   | Catégorie | Chemin de sauvegarde |
   |-----------|---------------------|
   | `movies` | `/torrents/complete/movies` |
   | `series` | `/torrents/complete/series` |
   | `anime` | `/torrents/complete/anime` (si activé) |

3. **Définir le dossier par défaut** :
   - Options > Téléchargements
   - Dossier par défaut : `/torrents/incomplete`

---

### Prowlarr

**URL :** `http://<IP_NAS>:9696`

**Configuration requise :**

1. **Ajouter des indexers/trackers** (Indexers > Add Indexer) :
   - **Publics** : YTS, EZTV, The Pirate Bay
   - **Privés** : YGGTorrent, T411, etc. (si vous avez accès)
   - **Animés** : Nyaa.si, HorribleSubs (si support animés)

2. **Connecter les applications** (Settings > Apps > Add Application) :
   
   **Radarr :**
   - Prowlarr Server : `http://prowlarr:9696`
   - Radarr Server : `http://radarr:7878`
   - API Key : (disponible dans Radarr > Settings > General)
   
   **Sonarr :**
   - Prowlarr Server : `http://prowlarr:9696`
   - Sonarr Server : `http://sonarr:8989`
   - API Key : (disponible dans Sonarr > Settings > General)

3. **Tester la synchronisation** (Apps > Test) ✅

---

### Radarr

**URL :** `http://<IP_NAS>:7878`

**Configuration requise :**

1. **Media Management** (Settings > Media Management) :
   - ✅ Rename Movies
   - ✅ Replace Illegal Characters
   - Movie Folder Format : `{Movie Title} ({Release Year})`
   - Movie File Format : `{Movie Title} ({Release Year}) - {Quality Full}`

2. **Ajouter le dossier racine** (Settings > Media Management > Root Folders) :
   - Chemin : `/movies`

3. **Configurer Download Client** (Settings > Download Clients > Add > qBittorrent) :
   - Host : `qbittorrent`
   - Port : `8080`
   - Username : `admin`
   - Password : `adminadmin` (ou votre nouveau mot de passe)
   - Category : `movies`

4. **Minimum Availability** (Settings > Media Management) :
   - `Announced` (plus rapide) ou `Released` (plus sûr)

5. **Quality Profile** (Settings > Profiles) :
   - Vérifier que le profil par défaut convient ou créer le vôtre

---

### Sonarr

**URL :** `http://<IP_NAS>:8989`

**Configuration identique à Radarr :**

1. **Media Management** (Settings > Media Management) :
   - ✅ Rename Episodes
   - ✅ Replace Illegal Characters
   - Series Folder Format : `{Series Title}`
   - Season Folder Format : `Season {season:00}`
   - Episode File Format : `{Series Title} - S{season:00}E{episode:00} - {Episode Title} [{Quality Full}]`

2. **Ajouter le dossier racine** (Settings > Media Management > Root Folders) :
   - Chemin : `/series`

3. **Configurer Download Client** (Settings > Download Clients > Add > qBittorrent) :
   - Host : `qbittorrent`
   - Port : `8080`
   - Username : `admin`
   - Password : `adminadmin`
   - Category : `series`

4. **Episode Monitoring** :
   - All Episodes (recommandé pour automatisation complète)

---

### 🎌 Configuration Sonarr pour les animés

Si vous avez activé le support animés lors du setup, **utilisez le même Sonarr** avec cette configuration :

#### 1. Ajouter un dossier racine pour animés

- Settings > Media Management > Root Folders > Add Root Folder
- Chemin : `/anime`

#### 2. Créer un profil de qualité spécifique (optionnel)

- Settings > Profiles > Add
- Nom : `Anime HD`
- Configurer les qualités souhaitées (recommandé : 720p/1080p minimum)

#### 3. Utiliser des tags pour organiser

- Settings > Tags > Add Tag
- Créer un tag : `anime`

#### 4. Ajouter des indexers spécialisés dans Prowlarr

Les meilleurs indexers pour animés :
- **Nyaa.si** (public, excellent pour animés)
- **HorribleSubs** (si disponible)
- **SubsPlease** (public)
- **AnimeTosho** (public)

#### 5. Ajouter une série animé

Lors de l'ajout d'un animé dans Sonarr :
1. Recherchez la série
2. **Root Folder** : Sélectionnez `/anime`
3. **Quality Profile** : `Anime HD` (si créé)
4. **Tags** : Ajoutez le tag `anime`
5. **Monitored** : All Episodes
6. Cliquez sur **Add Series**

#### 6. Configuration avancée (optionnel)

Pour une meilleure reconnaissance des noms d'animés :

- Settings > Indexers > Options
- **Anime Standard Episode Format** : `{Series Title} - S{season:00}E{episode:00} - {absolute:000} - {Episode Title} [{Quality Full}]`

**✅ Résultat :** Un seul Sonarr gère séries classiques ET animés, avec organisation automatique !

---

### Overseerr

**URL :** `http://<IP_NAS>:5055`

**Configuration initiale :**

1. **Connexion Plex** :
   - Sign in with Plex
   - Autoriser l'accès

2. **Configurer Plex Server** :
   - Server : Sélectionner votre serveur Plex
   - Libraries : Sélectionner Films et Séries TV

3. **Ajouter Radarr** (Settings > Radarr > Add Radarr Server) :
   - Default Server : ✅
   - Server Name : `Radarr`
   - Hostname or IP : `<IP_NAS>`
   - Port : `7878`
   - API Key : (copier depuis Radarr > Settings > General)
   - URL Base : (laisser vide)
   - Quality Profile : (sélectionner votre profil)
   - Root Folder : `/movies`
   - Test & Save

4. **Ajouter Sonarr** (Settings > Sonarr > Add Sonarr Server) :
   - Default Server : ✅
   - Server Name : `Sonarr`
   - Hostname or IP : `<IP_NAS>`
   - Port : `8989`
   - API Key : (copier depuis Sonarr > Settings > General)
   - Quality Profile : (sélectionner votre profil)
   - Root Folder : `/series`
   - **Anime Root Folder** : `/anime` (si activé)
   - Test & Save

5. **Inviter des utilisateurs** (Settings > Users) :
   - Importer depuis Plex
   - Définir les permissions (requêtes, etc.)

---

## 🌐 Configuration réseau (Freebox)

**📋 Voir [`FREEBOX_SETUP.md`](FREEBOX_SETUP.md) pour le guide COMPLET avec conseils de sécurité**

### Résumé rapide des ports essentiels

Sur **http://mafreebox.freebox.fr** → **Paramètres > Gestion des ports** :

| Service | Port interne | Protocole | Port externe | Note |
|---------|-------------|-----------|--------------|------|
| Radarr | 7878 | TCP | 7878 | Films |
| Sonarr | 8989 | TCP | 8989 | Séries + Animés |
| Prowlarr | 9696 | TCP | 9696 | Indexers |
| Overseerr | 5055 | TCP | 5055 | Demandes utilisateur |
| qBittorrent Web | 8080 | TCP | 8080 | Interface web |
| qBittorrent P2P | 6881 | TCP/UDP | 6881 | Téléchargements |
| Plex | 32400 | TCP | 32400 | Streaming |
| WireGuard | 51820 | UDP | 51820 | VPN (optionnel) |

> **⚠️ Important** : Pour des raisons de sécurité, il est recommandé de ne PAS exposer Overseerr directement sur Internet. Utilisez un VPN ou un reverse proxy HTTPS.

---

## 🔒 Sécurité & VPN

### Points de sécurité essentiels

- ✅ **Changez TOUS les mots de passe par défaut**
- ✅ **Activez HTTPS** (Nginx Proxy Manager, Traefik, Cloudflare Tunnel)
- ✅ **Utilisez un VPN pour qBittorrent** (WireGuard inclus dans le setup)
- ✅ **N'exposez pas Overseerr publiquement** (ou ajoutez authentification forte)
- ✅ **Sauvegardez régulièrement** `/volume1/docker/r-apps/*/config` (Hyper Backup)

### Configuration VPN pour qBittorrent

Si vous avez installé WireGuard lors du setup :

#### 1. Récupérer la configuration VPN

```bash
ls -la /volume1/docker/r-apps/wireguard/config/
```

Vous trouverez les fichiers de configuration client dans `peer1/`.

#### 2. Faire passer qBittorrent par le VPN

Éditez `/volume1/docker/docker-compose.yml` et dans la section `qbittorrent`, ajoutez :

```yaml
network_mode: "container:wireguard"
```

⚠️ **Important** : Commentez alors les lignes `ports:` de qBittorrent car les ports seront exposés via WireGuard.

#### 3. Redémarrer les services

```bash
cd /volume1/docker
docker-compose down
docker-compose up -d
```

#### 4. Vérifier que le VPN fonctionne

- Allez dans qBittorrent > Options > Advanced > Network Interface
- L'interface devrait être celle du VPN (généralement `wg0`)
- Testez votre IP sur https://ipleak.net depuis qBittorrent

**→ Plus de détails VPN dans [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)**

---

## 🔄 Maintenance

### Voir les logs

```bash
cd /volume1/docker

# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f radarr
docker-compose logs -f sonarr
```

### Mettre à jour les services

```bash
cd /volume1/docker

# Télécharger les nouvelles versions
docker-compose pull

# Redémarrer avec les nouvelles versions
docker-compose up -d

# Vérifier l'état
docker-compose ps
```

### Sauvegarder la configuration

Utilisez **Hyper Backup** (Synology) pour sauvegarder :
```
/volume1/docker/r-apps/*/config
```

Ou manuellement :
```bash
tar -czf backup_$(date +%Y%m%d).tar.gz /volume1/docker/r-apps/
```

**→ Pour la maintenance avancée, voir [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md)**

---

## ❓ FAQ

### Général

<details>
<summary><strong>Puis-je utiliser cette stack sans Plex ? (Jellyfin, Emby...)</strong></summary>

**Oui absolument !** Cette stack fonctionne avec n'importe quel serveur média :
- **Jellyfin** (open-source, gratuit)
- **Emby** (alternative commerciale)
- **Kodi** (lecture locale)

Pour Jellyfin, utilisez **Jellyseerr** au lieu d'Overseerr. Le reste de la configuration est identique.
</details>

<details>
<summary><strong>Est-ce compatible avec d'autres NAS que Synology ?</strong></summary>

**Oui**, tant que votre NAS supporte Docker :
- QNAP
- Asustor  
- TrueNAS
- Ubuntu Server / Linux générique

Adaptez simplement les chemins (remplacez `/volume1` par votre chemin de montage).
</details>

<details>
<summary><strong>Combien d'espace disque faut-il prévoir ?</strong></summary>

**Recommandations minimales :**
- Docker + configs : ~5 GB
- Zone de téléchargement (`/torrents`) : 100-500 GB minimum
- Bibliothèque média (`/media`) : selon vos besoins (1-10+ TB)

**Astuce** : Utilisez des disques externes ou NAS de grande capacité.
</details>

<details>
<summary><strong>Le VPN est-il obligatoire ?</strong></summary>

**Non, mais fortement recommandé** pour :
- Protéger votre vie privée
- Éviter les avertissements HADOPI (France)
- Contourner les blocages d'ISP

Alternatives si pas de VPN :
- Seedbox externe
- Usenet (Sabnzbd + indexers Usenet)
</details>

---

### Animés

<details>
<summary><strong>Pourquoi un seul Sonarr suffit pour séries ET animés ?</strong></summary>

Sonarr supporte nativement les animés grâce à :
- **Dossiers racines multiples** (`/series` et `/anime`)
- **Profils de qualité différents** (profil "Anime" vs "Séries")
- **Tags** pour organiser et filtrer
- **Metadata providers** (TheTVDB supporte les animés)

Avoir 2 instances Docker séparées :
- ❌ Double consommation de ressources
- ❌ Configuration à dupliquer
- ❌ Maintenance x2
- ❌ Complexité inutile

**Une seule instance = simplicité et efficacité !**
</details>

<details>
<summary><strong>Quels indexers utiliser pour les animés ?</strong></summary>

**Indexers publics recommandés :**
- **Nyaa.si** (meilleur pour animés, très complet)
- **SubsPlease** (releases rapides)
- **AnimeTosho** (agrégateur)

**Indexers privés** (si vous avez accès) :
- AnimeBytes
- BakaBT

**Configuration dans Prowlarr :**
1. Indexers > Add Indexer
2. Recherchez "Nyaa" ou "Anime"
3. Ajoutez et testez
</details>

<details>
<summary><strong>Les noms d'animés ne sont pas reconnus, que faire ?</strong></summary>

**Problème courant** : Les animés ont souvent des noms en romaji/japonais.

**Solutions :**
1. **Utilisez TheTVDB** comme metadata provider (par défaut dans Sonarr)
2. **Ajoutez l'anime manuellement** avec l'ID TheTVDB correct
3. **Utilisez les noms alternatifs** lors de la recherche
4. **Format de fichier** : Assurez-vous que vos releases sont nommées selon les standards (ex: `[SubsPlease] One Piece - 1080p.mkv`)

**Exemple de recherche :**
- ❌ `進撃の巨人` (kanji)
- ✅ `Attack on Titan` (anglais)
- ✅ `Shingeki no Kyojin` (romaji)
</details>

<details>
<summary><strong>Comment gérer les saisons d'animés (cour) ?</strong></summary>

Les animés japonais sont souvent diffusés par **saisons** (cour = ~12-13 épisodes).

**Dans Sonarr :**
- Traitez chaque cour comme une saison distincte
- Exemple : "My Hero Academia" = 7 saisons

**Structure recommandée :**
```
/anime/
  └─ My Hero Academia/
      ├─ Season 01/
      ├─ Season 02/
      └─ ...
```

Sonarr gère automatiquement cette structure si configuré correctement.
</details>

---

### Configuration & Troubleshooting

<details>
<summary><strong>Radarr/Sonarr ne trouvent rien, que faire ?</strong></summary>

**Checklist de dépannage :**

1. **Vérifier Prowlarr** :
   - Au moins 1 indexer actif
   - Prowlarr > System > Tasks > Refresh récent

2. **Vérifier la connexion Prowlarr ↔ Radarr/Sonarr** :
   - Prowlarr > Apps > Test (doit être vert ✅)

3. **Vérifier les indexers dans Radarr/Sonarr** :
   - Settings > Indexers (au moins 1 indexer doit apparaître)

4. **Logs** :
   ```bash
   docker-compose logs prowlarr
   docker-compose logs radarr
   ```

5. **Recherche manuelle** :
   - Movie/Series > Manual Search
   - Vérifiez si des résultats apparaissent
</details>

<details>
<summary><strong>Les téléchargements ne démarrent pas dans qBittorrent</strong></summary>

**Causes possibles :**

1. **Catégories mal configurées** :
   - Vérifier que `movies`, `series`, `anime` existent dans qBittorrent
   - Chemins : `/torrents/complete/movies`, etc.

2. **Connexion Radarr/Sonarr ↔ qBittorrent** :
   - Settings > Download Clients > Test (doit être vert ✅)
   - Vérifier login/password

3. **Permissions de dossiers** :
   ```bash
   chmod 775 -R /volume1/torrents
   chown -R 1026:100 /volume1/torrents  # PUID:PGID
   ```

4. **Firewall/VPN bloque** :
   - Si VPN actif, vérifier que la connexion fonctionne
</details>

<details>
<summary><strong>Overseerr ne voit pas Radarr/Sonarr</strong></summary>

**Solutions :**

1. **Utiliser l'IP du NAS** au lieu de `localhost` :
   - ✅ `http://<IP_NAS>:7878`
   - ❌ `http://localhost:7878`

2. **Vérifier que les services sont démarrés** :
   ```bash
   docker-compose ps
   ```

3. **Copier la bonne API Key** :
   - Radarr > Settings > General > API Key
   - Copier exactement (sans espaces)

4. **Tester la connexion manuellement** :
   ```bash
   curl http://<IP_NAS>:7878/api/v3/system/status -H "X-Api-Key: YOUR_API_KEY"
   ```
</details>

<details>
<summary><strong>Comment accéder aux services depuis l'extérieur ?</strong></summary>

**Méthode 1 : Redirection de ports Freebox** (plus simple)
- Voir [`FREEBOX_SETUP.md`](FREEBOX_SETUP.md)
- Accès via `http://<IP_PUBLIQUE>:7878`
- ⚠️ Pas sécurisé (HTTP uniquement)

**Méthode 2 : Reverse Proxy + HTTPS** (recommandé)
- Installer Nginx Proxy Manager
- Certificat Let's Encrypt (HTTPS automatique)
- Sous-domaines : `radarr.votredomaine.com`

**Méthode 3 : Cloudflare Tunnel** (le plus sécurisé)
- Aucun port à ouvrir
- HTTPS automatique
- Zero Trust Security

**Méthode 4 : VPN** (Tailscale, WireGuard)
- Accès privé uniquement
- Le plus sécurisé
</details>

<details>
<summary><strong>Puis-je utiliser plusieurs instances de qBittorrent ?</strong></summary>

**Oui**, utile pour :
- Séparer VPN / No-VPN
- Limiter bande passante différemment
- Organiser par type de contenu

**Comment faire :**
1. Dupliquer la section qBittorrent dans `docker-compose.yml`
2. Changer le nom du container et le port
3. Pointer un client vers chaque instance dans Radarr/Sonarr
</details>

---

### Performance

<details>
<summary><strong>Mon NAS est lent / surchargé</strong></summary>

**Optimisations possibles :**

1. **Limiter les ressources Docker** :
   Éditez `docker-compose.yml` et ajoutez :
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
         memory: 512M
   ```

2. **Réduire le nombre de trackers dans Prowlarr** :
   - Gardez seulement les plus rapides/fiables

3. **Désactiver la recherche automatique** :
   - Radarr/Sonarr > Settings > Indexers
   - RSS Sync Interval : augmenter à 60+ minutes

4. **Utiliser un cache SSD** (Synology SSD Cache) :
   - Accélère Docker et base de données
</details>

<details>
<summary><strong>Les recherches Prowlarr sont très lentes</strong></summary>

**Causes et solutions :**

1. **Trop de trackers** :
   - Limiter à 5-10 trackers max
   - Privilégier les trackers rapides

2. **Timeouts trop courts** :
   - Prowlarr > Settings > Indexers
   - Query Timeout : augmenter à 30-60s

3. **Trackers down/lents** :
   - Prowlarr > Indexers > Trier par "Response Time"
   - Désactiver les plus lents
</details>

---

## 💡 Extensions possibles

Une fois votre stack de base fonctionnelle, vous pouvez ajouter :

| Service | Fonction | Difficulté |
|---------|----------|------------|
| **Bazarr** | Téléchargement automatique de sous-titres | ⭐ Facile |
| **Tautulli** | Dashboard et statistiques Plex | ⭐ Facile |
| **Requestrr** | Bot Discord pour requêtes Overseerr | ⭐⭐ Moyen |
| **Nginx Proxy Manager** | Reverse proxy + HTTPS automatique | ⭐⭐ Moyen |
| **Jellyfin** | Alternative open-source à Plex | ⭐⭐ Moyen |
| **Lidarr** | Gestion automatique de musique | ⭐⭐ Moyen |
| **Readarr** | Gestion automatique de livres/ebooks | ⭐⭐ Moyen |
| **Notifiarr** | Notifications Discord/Telegram | ⭐⭐ Moyen |
| **Organizr** | Dashboard centralisé pour tous les services | ⭐⭐⭐ Avancé |
| **Traefik** | Reverse proxy avancé avec auto-discovery | ⭐⭐⭐ Avancé |

**→ Guides d'installation dans [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) section "Extensions"**

---

## 📦 Fichiers fournis

- [`setup.sh`](setup.sh) — Script d'installation automatique
- [`docker/`](docker/) — Fichiers docker-compose pour chaque service
- [`QUICKSTART.md`](QUICKSTART.md) — Guide rapide (5 minutes)
- [`FREEBOX_SETUP.md`](FREEBOX_SETUP.md) — Configuration Freebox complète
- [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) — Solutions & FAQs détaillées
- `README.md` — Ce fichier (documentation principale)

---

## 📄 Licence

Ce projet est sous licence **MIT** — voir [`LICENSE`](LICENSE).

---

## 🙏 Contributions

Les contributions sont les bienvenues ! N'hésitez pas à :
- 🐛 Signaler des bugs
- 💡 Proposer des améliorations
- 📝 Améliorer la documentation
- ⭐ Mettre une étoile si ce projet vous aide !

---

**🎉 Profitez de votre stack média automatisée !**

Pour toute question, consultez [`TROUBLESHOOTING.md`](TROUBLESHOOTING.md) ou ouvrez une issue sur GitHub.
