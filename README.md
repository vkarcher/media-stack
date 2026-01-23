# 🍿 Ultimate Media Stack (Jellyfin Edition)

![Homarr Dashboard](https://raw.githubusercontent.com/ajnart/homarr/main/public/imgs/hero-light.png)
*(Exemple de votre futur tableau de bord Homarr)*

## 🇫🇷 Introduction

Bienvenue sur la **Media Stack Ultime**. Ce projet a pour but de vous aider à monter un serveur média autonome (type "Netflix Perso") le plus simplement possible, avec une orientation 100% **Qualité** et **Facilité d'utilisation** (Facteur WAF validé ✅).

**Pourquoi cette stack ?**
- **100% Automatisée** : Vous demandez un film sur votre téléphone, il est téléchargé, trié et disponible sur votre TV tout seul.
- **Gratuit & Open Source** : Pas d'abonnement Plex Pass nécessaire.
- **Optimisée** : Utilise les "Hardlinks" pour ne pas dupliquer les fichiers et économiser l'espace disque.
- **Support Français** : Pré-configurée pour récupérer du contenu VFF/TRUEFRENCH de qualité.

---

## 📦 Le Contenu

Votre serveur va tourner avec ces applications (conteneurs Docker) :

| Application | Rôle |
|-------------|------|
| **🏠 Homarr** | **Votre accueil**. Un beau tableau de bord pour accéder à tout. |
| **🍿 Jellyfin** | Le lecteur (comme Netflix). Lit tout, partout (TV, Mobile, Web). |
| **🔍 Jellyseerr** | Le catalogue. C'est là que vous et votre famille demandez "Je veux voir ce film". |
| **🤖 Sonarr** | Gère les Séries (recherche, renommage, qualité). |
| **🤖 Radarr** | Gère les Films. |
| **⚡ qBittorrent** | Le logiciel de téléchargement. |
| **🔎 Prowlarr** | Connecte Sonarr/Radarr à vos sites de torrents (YGG, etc). |
| **🔧 FlareSolverr** | Débloque les protections Cloudflare de certains sites. |

---

## 🚀 Installation Rapide

### Prérequis
- Un NAS Synology (ou tout serveur Linux/Docker).
- Accès SSH (Terminal).

### 1. Télécharger le projet
Connectez-vous à votre NAS en SSH et allez dans votre volume :
```bash
cd /volume1
git clone https://github.com/vkarcher/media-stack.git
cd media-stack
```

### 2. Configurer
Créez votre fichier de configuration à partir de l'exemple :
```bash
cp .env.example .env
```
Ouvrez le fichier `.env` (avec `vi .env` ou l'éditeur texte de Synology) et modifiez si besoin (Timezone, PUID...).

### 3. Préparer les dossiers
Lancez le script magique qui va créer les dossiers `/data` et régler les permissions :
```bash
sudo bash setup.sh
```

### 4. Démarrer !
```bash
sudo docker-compose up -d
```
Attendez quelques minutes que tout démarre.

---

## 🏠 Accès à vos services

Une fois lancé, tout est accessible via l'IP de votre NAS.
Commencez par configurer **Homarr** pour avoir tout sous la main !

- **Homarr (Accueil)** : `http://<IP-NAS>:7575`
- **Jellyfin** : `http://<IP-NAS>:8096`
- **Jellyseerr** : `http://<IP-NAS>:5055`
- **qBittorrent** : `http://<IP-NAS>:8080` (Login: `admin` / mdp: voir logs ou `adminadmin`)

---

## 📚 Documentation Détaillée

Besoin d'aide pour configurer une app précise ?

- [📕 **Guide de Démarrage (Pas à Pas)**](QUICKSTART.md) *(Recommandé pour débutants)*
- [🦅 **Configuration Freebox & Accès Distance**](docs/freebox.md)
- [🧩 **Exemples Modulaires**](docker/README.md) *(Pour prendre juste un bout de la stack)*
- [⚙️ Configuration Homarr](docs/homarr.md)
- [🍿 Configuration Jellyfin & Transcodage](docs/jellyfin.md)
- [🤖 Configuration Sonarr/Radarr (Profils FR)](docs/arr-stack.md)

---

## 💡 Astuces "Pro"

### C'est quoi les "Hardlinks" ?
Cette stack utilise un volume unique `/data`.
- Téléchargement : `/data/torrents/complete/Film.mkv`
- Médiathèque : `/data/media/movies/Film (2024).mkv`

Grâce aux *Hardlinks*, le fichier n'est **pas copié**. Il est "vu" à deux endroits mais ne prend la place que d'une seule fois sur le disque ! Le déplacement est instantané.
⚠️ **Important** : Dans Sonarr/Radarr, quand on vous demande le chemin, naviguez toujours dans `/data/...`.

---
