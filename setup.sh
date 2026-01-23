#!/bin/bash

# ==========================================
# 🚀 SETUP AUTOMATIQUE (Media Stack)
# ==========================================
# Ce script prépare votre NAS pour recevoir la stack.
# Il crée les dossiers et définit les permissions.

set -e

# Couleurs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}      Préparation du NAS (Jellyfin)     ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"

# Vérification root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Ce script doit être exécuté en tant que root (sudo -i)${NC}"
   exit 1
fi

# Charger les variables si .env existe, sinon demander
if [ -f .env ]; then
    echo -e "${YELLOW}📄 Lecture du fichier .env...${NC}"
    export $(grep -v '^#' .env | xargs)
else
    echo -e "${YELLOW}⚠️  Fichier .env non trouvé !${NC}"
    echo "   Veuillez d'abord copier .env.example vers .env et le configurer."
    echo "   Commande : cp .env.example .env"
    exit 1
fi

# Variables par défaut si non définies dans .env
ROOT_DIR=${ROOT_DIR:-/volume1}
PUID=${PUID:-1026}
PGID=${PGID:-100}

echo -e "📂 Racine : ${ROOT_DIR}"
echo -e "👤 UserID : ${PUID} | GroupID : ${PGID}"
echo ""

# 1. Création de la structure /data (Hardlinks Friendly)
echo -e "${YELLOW}Tag 1/3: Création des dossiers...${NC}"

# Structure unifiée pour les hardlinks
mkdir -p "${ROOT_DIR}/data/torrents/complete"
mkdir -p "${ROOT_DIR}/data/torrents/incomplete"
mkdir -p "${ROOT_DIR}/data/media/movies"
mkdir -p "${ROOT_DIR}/data/media/series"

# Dossiers de config Docker
mkdir -p "${ROOT_DIR}/docker/jellyfin/config"
mkdir -p "${ROOT_DIR}/docker/jellyfin/cache"
mkdir -p "${ROOT_DIR}/docker/jellyseerr/config"
mkdir -p "${ROOT_DIR}/docker/homarr/configs"
mkdir -p "${ROOT_DIR}/docker/homarr/icons"
mkdir -p "${ROOT_DIR}/docker/qbittorrent/config"
mkdir -p "${ROOT_DIR}/docker/prowlarr/config"
mkdir -p "${ROOT_DIR}/docker/sonarr/config"
mkdir -p "${ROOT_DIR}/docker/radarr/config"
mkdir -p "${ROOT_DIR}/docker/bazarr/config"

echo -e "${GREEN}✓ Dossiers créés${NC}"

# 2. Permissions
echo -e "${YELLOW}Tag 2/3: Application des permissions...${NC}"

# On donne la propriété à l'utilisateur défini (souvent admin/1026)
chown -R ${PUID}:${PGID} "${ROOT_DIR}/data"
chown -R ${PUID}:${PGID} "${ROOT_DIR}/docker"

# Permissions larges pour éviter les soucis (775)
chmod -R 775 "${ROOT_DIR}/data"
chmod -R 775 "${ROOT_DIR}/docker"

echo -e "${GREEN}✓ Permissions appliquées${NC}"

# 3. Vérification Docker
echo -e "${YELLOW}Tag 3/3: Vérification Docker...${NC}"
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker Compose n'est pas détecté.${NC}"
    echo "   Assurez-vous d'avoir installé 'Container Manager' sur votre Synology."
else
    echo -e "${GREEN}✓ Docker Compose est prêt${NC}"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ PRÊT À DÉMARRER !                  ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "Prochaines étapes :"
echo -e "1. Vérifiez votre fichier .env"
echo -e "2. Lancez la stack : ${YELLOW}docker-compose up -d${NC}"
echo ""
