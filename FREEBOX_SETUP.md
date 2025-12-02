#!/bin/bash

####################################
# Guide Freebox - Configuration des ports
# Pour Stack Média Automatisée
####################################

echo "
╔══════════════════════════════════════════════════════════════╗
║         Configuration Freebox - Guide Automatisé             ║
╚══════════════════════════════════════════════════════════════╝

📋 ÉTAPES DE CONFIGURATION

1️⃣  Accédez à http://mafreebox.freebox.fr
2️⃣  Identifiez-vous
3️⃣  Allez dans : Paramètres > Gestion des ports
4️⃣  Suivez les redirections ci-dessous

╔══════════════════════════════════════════════════════════════╗
║              PORTS À REDIRIGER OBLIGATOIRES                  ║
╚══════════════════════════════════════════════════════════════╝

🎬 RADARR (Films)
   - Port interne : 7878 (TCP)
   - Port externe : 7878 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

📺 SONARR (Séries)
   - Port interne : 8989 (TCP)
   - Port externe : 8989 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

🔎 PROWLARR (Indexeurs)
   - Port interne : 9696 (TCP)
   - Port externe : 9696 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

🎥 OVERSEERR (Demandes)
   - Port interne : 5055 (TCP)
   - Port externe : 5055 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

📽️ PLEX (Diffusion)
   - Port interne : 32400 (TCP)
   - Port externe : 32400 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

╔══════════════════════════════════════════════════════════════╗
║              PORTS POUR qBITTORRENT (Torrents)               ║
╚══════════════════════════════════════════════════════════════╝

⚠️  IMPORTANT : Ces ports doivent être ouverts pour le P2P

Interface Web
   - Port interne : 8080 (TCP)
   - Port externe : 8080 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

P2P - TCP
   - Port interne : 6881 (TCP)
   - Port externe : 6881 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

P2P - UDP
   - Port interne : 6881 (UDP)
   - Port externe : 6881 (UDP)
   - Protocole : UDP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

╔══════════════════════════════════════════════════════════════╗
║              PORTS OPTIONNELS (Si installés)                 ║
╚══════════════════════════════════════════════════════════════╝

🎌 SONARR ANIME (Animés)
   - Port interne : 8988 (TCP)
   - Port externe : 8988 (TCP)
   - Protocole : TCP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

🔐 WIREGUARD VPN (Sécurité optionnelle)
   - Port interne : 51820 (UDP)
   - Port externe : 51820 (UDP)
   - Protocole : UDP
   - IP NAS : <REMPLACER_PAR_IP_NAS>

╔══════════════════════════════════════════════════════════════╗
║                    CONSEILS DE SÉCURITÉ                      ║
╚══════════════════════════════════════════════════════════════╝

🔒 NE PAS EXPOSER :
   ❌ Overseerr (5055) en direct sur internet
   ❌ Les ports sans firewall

✅ À FAIRE :
   ✓ Utilisez un Reverse Proxy (Nginx Proxy Manager, Traefik)
   ✓ Ajoutez HTTPS avec Let's Encrypt
   ✓ Changez tous les mots de passe par défaut
   ✓ Activez la 2FA si disponible
   ✓ Utiliser VPN pour qBittorrent (voir WireGuard)

╔══════════════════════════════════════════════════════════════╗
║                  TROUVER VOTRE IP NAS                        ║
╚══════════════════════════════════════════════════════════════╝

Via SSH :
   ssh admin@<IP_NAS>
   hostname -I

Via File Station Synology :
   Allez dans : Outils > Informations système
   Cherchez : Adresse IP

Via Freebox :
   Allez dans : Gestion des ports > Voir la liste des appareils

╔══════════════════════════════════════════════════════════════╗
║                   TESTER LA CONFIGURATION                    ║
╚══════════════════════════════════════════════════════════════╝

Depuis l'extérieur (Ex: 4G/Mobile) :
   - Radarr : http://<IP_FREEBOX_PUBLIC>:7878
   - Sonarr : http://<IP_FREEBOX_PUBLIC>:8989
   - Overseerr : http://<IP_FREEBOX_PUBLIC>:5055

Trouver votre IP Freebox publique :
   https://monip.com (sur le réseau Freebox)
   Ou : Freebox > Paramètres > État du système

╔══════════════════════════════════════════════════════════════╗
║                   🚀 CONFIGURATION VPN                       ║
╚══════════════════════════════════════════════════════════════╝

SI VOUS AVEZ INSTALLÉ WIREGUARD :

1. Récupérez la config :
   /volume1/docker/r-apps/wireguard/config/

2. Pour utiliser le VPN sur qBittorrent :
   - Éditez : /volume1/docker/docker-compose.yml
   - Décommentez la ligne : network_mode: \"container:wireguard\"
   - Redémarrez : docker-compose down && docker-compose up -d

3. qBittorrent utilisera le VPN pour tous les torrents
   (l'IP publique ne sera pas exposée)

╔══════════════════════════════════════════════════════════════╗
║                      📞 SUPPORT                              ║
╚══════════════════════════════════════════════════════════════╝

Consultez README.md pour :
   - Configuration détaillée de chaque application
   - Troubleshooting
   - Maintenance et mise à jour
   - Bonus et améliorations

"
