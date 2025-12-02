#!/bin/bash

####################################
# Setup automatique Stack Média
# Pour NAS Synology DSM 7.2+
####################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_PATH="/volume1"
DOCKER_PATH="$BASE_PATH/docker"
MEDIA_PATH="$BASE_PATH/media"
TORRENTS_PATH="$BASE_PATH/torrents"

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Stack Média Automatisée - Setup NAS  ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Configuration interactive${NC}"
echo ""
read -p "Inclure support pour les animés ? (y/n) [y] " INCLUDE_ANIME
INCLUDE_ANIME=${INCLUDE_ANIME:-y}

read -p "Installer WireGuard VPN pour qBittorrent ? (y/n) [n] " INCLUDE_VPN
INCLUDE_VPN=${INCLUDE_VPN:-n}

echo ""

# Vérifier si on est root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Ce script doit être exécuté en tant que root${NC}"
   echo "   Utilisez : sudo -i"
   exit 1
fi

# Vérifier DSM
echo -e "${YELLOW}📋 Vérification de l'environnement...${NC}"
if [ ! -f /etc/dsm_version ]; then
    echo -e "${YELLOW}⚠️  Non détecté sur Synology (continuant quand même)${NC}"
fi

# Récupérer les IDs utilisateur/groupe
PUID=$(id -u | awk '{print $1}')
PGID=$(id -g | awk '{print $1}')
if [ -z "$PUID" ]; then PUID=1026; fi
if [ -z "$PGID" ]; then PGID=100; fi

echo -e "${GREEN}✓ PUID=$PUID, PGID=$PGID${NC}"

# 1. Créer la structure des dossiers
echo -e "${YELLOW}📁 Création de la structure des dossiers...${NC}"

mkdir -p "$DOCKER_PATH/r-apps/prowlarr/config"
mkdir -p "$DOCKER_PATH/r-apps/qbittorrent/config"
mkdir -p "$DOCKER_PATH/r-apps/radarr/config"
mkdir -p "$DOCKER_PATH/r-apps/sonarr/config"
mkdir -p "$DOCKER_PATH/r-apps/overseerr/config"
mkdir -p "$MEDIA_PATH/movies"
mkdir -p "$MEDIA_PATH/series"
mkdir -p "$TORRENTS_PATH/complete/movies"
mkdir -p "$TORRENTS_PATH/complete/series"
mkdir -p "$TORRENTS_PATH/incomplete"

if [[ "$INCLUDE_ANIME" == "y" ]] || [[ "$INCLUDE_ANIME" == "Y" ]]; then
    mkdir -p "$MEDIA_PATH/anime"
    mkdir -p "$TORRENTS_PATH/complete/anime"
    echo -e "${GREEN}✓ Support animés activé (dossiers créés, configurez Sonarr avec /anime)${NC}"
fi

echo -e "${GREEN}✓ Dossiers créés${NC}"

# 2. Définir les permissions
echo -e "${YELLOW}🔐 Configuration des permissions...${NC}"
chmod 775 -R "$DOCKER_PATH" "$MEDIA_PATH" "$TORRENTS_PATH"
echo -e "${GREEN}✓ Permissions configurées${NC}"

# 3. Installer Docker Compose si nécessaire
echo -e "${YELLOW}🐳 Vérification de Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}   Installation de Docker Compose...${NC}"
    COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)"
    curl -fsSL "$COMPOSE_URL" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installé${NC}"
else
    echo -e "${GREEN}✓ Docker Compose déjà présent${NC}"
fi

# 4. Créer les fichiers docker-compose

# Prowlarr
echo -e "${YELLOW}📝 Création du docker-compose pour Prowlarr...${NC}"
cat > "$DOCKER_PATH/r-apps/prowlarr/docker-compose.yml" << EOF
version: '3.8'
services:
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/prowlarr/config:/config
    ports:
      - 9696:9696
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ Prowlarr configuré${NC}"

# qBittorrent
echo -e "${YELLOW}📝 Création du docker-compose pour qBittorrent...${NC}"
cat > "$DOCKER_PATH/r-apps/qbittorrent/docker-compose.yml" << EOF
version: '3.8'
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
      - WEBUI_PORT=8080
    volumes:
      - /volume1/docker/r-apps/qbittorrent/config:/config
      - /volume1/torrents:/torrents
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ qBittorrent configuré${NC}"

# Radarr
echo -e "${YELLOW}📝 Création du docker-compose pour Radarr...${NC}"
cat > "$DOCKER_PATH/r-apps/radarr/docker-compose.yml" << EOF
version: '3.8'
services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/radarr/config:/config
      - /volume1/media/movies:/movies
      - /volume1/torrents:/torrents
    ports:
      - 7878:7878
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ Radarr configuré${NC}"

# Sonarr
echo -e "${YELLOW}📝 Création du docker-compose pour Sonarr...${NC}"
cat > "$DOCKER_PATH/r-apps/sonarr/docker-compose.yml" << EOF
version: '3.8'
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/sonarr/config:/config
      - /volume1/media/series:/series
      - /volume1/torrents:/torrents
    ports:
      - 8989:8989
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ Sonarr configuré${NC}"

# Note: Pour les animés, utilisez le même Sonarr avec un dossier racine /anime
# Voir README.md section "Configuration Sonarr pour animés"

# Overseerr
echo -e "${YELLOW}📝 Création du docker-compose pour Overseerr...${NC}"
cat > "$DOCKER_PATH/r-apps/overseerr/docker-compose.yml" << EOF
version: '3.8'
services:
  overseerr:
    image: lscr.io/linuxserver/overseerr:latest
    container_name: overseerr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/overseerr/config:/config
    ports:
      - 5055:5055
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ Overseerr configuré${NC}"

# Créer le docker-compose global
echo -e "${YELLOW}📝 Création du docker-compose global...${NC}"
cat > "$DOCKER_PATH/docker-compose.yml" << EOF
version: '3.8'
services:
  prowlarr:
    image: lscr.io/linuxserver/prowlarr:latest
    container_name: prowlarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/prowlarr/config:/config
    ports:
      - 9696:9696
    restart: unless-stopped

  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
      - WEBUI_PORT=8080
    volumes:
      - /volume1/docker/r-apps/qbittorrent/config:/config
      - /volume1/torrents:/torrents
    ports:
      - 8080:8080
      - 6881:6881
      - 6881:6881/udp
    restart: unless-stopped

  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/radarr/config:/config
      - /volume1/media/movies:/movies
      - /volume1/torrents:/torrents
    ports:
      - 7878:7878
    restart: unless-stopped

  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/sonarr/config:/config
      - /volume1/media/series:/series
      - /volume1/torrents:/torrents
    ports:
      - 8989:8989
    restart: unless-stopped

  overseerr:
    image: lscr.io/linuxserver/overseerr:latest
    container_name: overseerr
    environment:
      - PUID=$PUID
      - PGID=$PGID
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/overseerr/config:/config
    ports:
      - 5055:5055
    restart: unless-stopped
EOF
echo -e "${GREEN}✓ Docker-compose global créé${NC}"

# 4.5 Configuration VPN WireGuard (optionnel)
if [[ "$INCLUDE_VPN" == "y" ]] || [[ "$INCLUDE_VPN" == "Y" ]]; then
    echo -e "${YELLOW}📝 Création du docker-compose pour WireGuard VPN...${NC}"
    mkdir -p "$DOCKER_PATH/r-apps/wireguard/config"
    
    cat >> "$DOCKER_PATH/docker-compose.yml" << 'EOF'

  wireguard:
    image: lscr.io/linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1026
      - PGID=100
      - TZ=Europe/Paris
      - SERVERURL=auto
      - SERVERPORT=51820
      - PEERS=1
      - PEERDNS=auto
      - INTERNAL_SUBNET=10.0.0.0
    volumes:
      - /volume1/docker/r-apps/wireguard/config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
EOF
    echo -e "${GREEN}✓ WireGuard VPN configuré (port 51820)${NC}"
    
    # Configurer qBittorrent avec VPN (optionnel - commenté)
    echo -e "${YELLOW}💡 Pour utiliser le VPN avec qBittorrent, décommentez 'network_mode' dans docker-compose.yml${NC}"
fi

# 5. Lancer les services
echo -e "${YELLOW}🚀 Lancement des services Docker...${NC}"
cd "$DOCKER_PATH"
docker-compose up -d

echo -e "${GREEN}✓ Services lancés${NC}"

# 6. Afficher le statut
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ INSTALLATION RÉUSSIE !              ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}📝 Détails des services :${NC}"
echo ""
echo "  qBittorrent  → http://<IP_NAS>:8080"
echo "  Prowlarr     → http://<IP_NAS>:9696"
echo "  Radarr       → http://<IP_NAS>:7878"
echo "  Sonarr       → http://<IP_NAS>:8989"
echo "  Overseerr    → http://<IP_NAS>:5055"



if [[ "$INCLUDE_VPN" == "y" ]] || [[ "$INCLUDE_VPN" == "Y" ]]; then
    echo "  WireGuard    → Port 51820 (UDP)"
fi

echo ""
echo -e "${YELLOW}📁 Chemins (dans le NAS) :${NC}"
echo "  Docker       → $DOCKER_PATH"
echo "  Média        → $MEDIA_PATH"
echo "  Torrents     → $TORRENTS_PATH"

if [[ "$INCLUDE_ANIME" == "y" ]] || [[ "$INCLUDE_ANIME" == "Y" ]]; then
    echo "  Anime        → $MEDIA_PATH/anime"
fi

echo ""
echo -e "${YELLOW}⚙️  Ports à configurer dans Freebox :${NC}"
echo "  • qBittorrent (8080, 6881)"
echo "  • Radarr (7878)"
echo "  • Sonarr (8989)"



if [[ "$INCLUDE_VPN" == "y" ]] || [[ "$INCLUDE_VPN" == "Y" ]]; then
    echo "  • WireGuard (51820)"
fi

echo "  • Prowlarr (9696)"
echo "  • Overseerr (5055)"
echo "  • Plex (32400)"
echo ""
echo -e "${YELLOW}📋 Prochaines étapes :${NC}"
echo "  1. Configurer les applications via leurs interfaces web"
if [[ "$INCLUDE_ANIME" == "y" ]] || [[ "$INCLUDE_ANIME" == "Y" ]]; then
    echo "  2. Pour les animés : Configurer Sonarr avec dossier racine /anime (voir README.md)"
    echo "  3. Mettre en place la redirection de ports Freebox (voir README.md)"
    echo "  4. Consulter README.md pour les détails complets"
else
    echo "  2. Mettre en place la redirection de ports Freebox (voir README.md)"
    echo "  3. Consulter README.md pour les détails complets"
fi

if [[ "$INCLUDE_VPN" == "y" ]] || [[ "$INCLUDE_VPN" == "Y" ]]; then
    echo "  4. (VPN) Récupérer la config WireGuard dans /volume1/docker/r-apps/wireguard/config"
fi

echo ""
echo -e "${YELLOW}🔧 Pour voir les logs :${NC}"
echo "  cd $DOCKER_PATH"
echo "  docker-compose logs -f <service>"
echo ""
echo -e "${YELLOW}⏹️  Pour arrêter/redémarrer :${NC}"
echo "  docker-compose stop"
echo "  docker-compose up -d"
echo ""
