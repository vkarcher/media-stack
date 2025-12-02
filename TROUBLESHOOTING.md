# 🔧 Troubleshooting & FAQs

## Installation & Déploiement

### Le script ne s'exécute pas

```bash
# Vérifier les permissions
chmod +x setup.sh

# Exécuter en shell bash explicite
bash setup.sh

# Vérifier si vous êtes root
sudo -i
```

### Les services ne démarre pas

```bash
# Vérifier les logs
cd /volume1/docker
docker-compose logs

# Redémarrer tous les services
docker-compose down
docker-compose up -d

# Vérifier l'état
docker-compose ps
```

### Erreur : "Cannot connect to Docker daemon"

```bash
# Docker n'est peut-être pas installé
# Installez Container Manager depuis le Centre de paquets Synology

# Ou installez Docker manuellement
sudo -i
docker --version
```

---

## Configuration Applications

### Overseerr ne voit pas Radarr/Sonarr

1. Vérifiez que les services tournent :
   ```bash
   docker-compose ps
   ```

2. Testez la connexion (depuis le NAS) :
   ```bash
   curl http://radarr:7878
   curl http://sonarr:8989
   ```

3. Dans Overseerr, utilisez l'IP interne du NAS :
   ```
   http://radarr:7878 (Docker)
   ou
   http://<IP_NAS>:7878 (Réseau externe)
   ```

### Radarr/Sonarr ne voient pas Prowlarr

**Solution :**
- Utilisez le nom DNS Docker : `http://prowlarr:9696`
- ET NOT `http://localhost:9696`

**Vérifier :**
```bash
docker exec radarr curl http://prowlarr:9696
```

### Les torrents ne télécharge pas

1. **Vérifier qBittorrent est accessible :**
   ```bash
   curl http://localhost:8080
   ```

2. **Vérifier les logs Radarr/Sonarr :**
   ```bash
   docker-compose logs radarr
   docker-compose logs sonarr
   ```

3. **Vérifier les catégories qBittorrent :**
   - Allez sur http://<IP_NAS>:8080
   - Options > Téléchargement
   - Vérifiez les chemins `/torrents/complete/movies`, `/torrents/complete/series`

4. **Vérifier Prowlarr a des trackers :**
   - http://<IP_NAS>:9696
   - Onglet Indexers > Au moins 1 tracker doit être présent

---

## Redirection Ports Freebox

### Les applications ne sont pas accessibles de l'extérieur

1. **Vérifier l'IP NAS :**
   ```bash
   hostname -I
   ```

2. **Vérifier la redirection Freebox :**
   - Allez sur http://mafreebox.freebox.fr
   - Paramètres > Gestion des ports
   - Vérifiez que l'IP NAS est correcte

3. **Tester de l'extérieur :**
   ```bash
   # Depuis un téléphone 4G/5G
   http://<IP_FREEBOX_PUBLIC>:7878
   ```

4. **Trouver votre IP publique Freebox :**
   ```bash
   # Sur le réseau Freebox
   https://monip.com
   ```

### Freebox dit "Appareil introuvable"

1. **Vérifiez que l'IP NAS est correct :**
   - File Station > Outils > Informations système
   - Cherchez "Adresse IP"

2. **Vérifiez que le port est accessible sur le NAS :**
   ```bash
   telnet localhost 7878
   # Ou : curl http://localhost:7878
   ```

3. **Redémarrez le routeur Freebox :**
   - Attendez 2-3 minutes
   - Réessayez

---

## VPN WireGuard

### WireGuard ne démarre pas

```bash
# Vérifier les modules kernel
lsmod | grep wireguard

# Vérifier les logs
docker-compose logs wireguard

# Redémarrer
docker-compose down
docker-compose up -d wireguard
```

### qBittorrent avec VPN - Configuration

1. **Obtenir la config WireGuard :**
   ```bash
   ls /volume1/docker/r-apps/wireguard/config/
   # Vous trouverez : peer1/...wg0.conf
   ```

2. **Faire tourner qBittorrent sur le VPN :**
   - Éditez `/volume1/docker/docker-compose.yml`
   - Dans la section `qbittorrent`, ajoutez :
   ```yaml
   network_mode: "container:wireguard"
   ```

3. **Redémarrez :**
   ```bash
   cd /volume1/docker
   docker-compose down
   docker-compose up -d
   ```

4. **Vérifiez :**
   - Dans qBittorrent > Statistiques
   - L'IP publique ne doit pas être votre IP réelle

---

## Animés (Sonarr Anime)

### Sonarr Anime ne trouve rien

1. **Vérifier les trackers :**
   - Allez sur Prowlarr (http://<IP_NAS>:9696)
   - Onglet Indexers
   - Ajouter **Nyaa.si** ou **HorribleSubs**

2. **Configurer Prowlarr > Apps :**
   - Ajouter Sonarr Anime :
   ```
   http://sonarr-anime:8988
   ```

3. **Dans Sonarr Anime :**
   - Onglet Indexers > Ajouter Prowlarr : `http://prowlarr:9696`
   - Onglet Download Client > Ajouter qBittorrent

4. **Rechercher un anime :**
   - Dans Overseerr, cherchez un anime
   - Cliquez sur "Request"
   - Devrait être automatiquement trouvé et téléchargé

---

## Performance & Optimisation

### Le NAS est lent

1. **Vérifier les ressources Docker :**
   ```bash
   docker stats
   ```

2. **Limiter les ressources (optionnel) :**
   - Éditez `/volume1/docker/docker-compose.yml`
   - Ajoutez dans chaque service :
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '0.5'
         memory: 512M
   ```

3. **Redémarrez les services :**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Les recherches sont lentes (Prowlarr)

1. **Vérifier le nombre de trackers :**
   - Chaque tracker ralentit les recherches
   - Gardez seulement les trackers essentiels

2. **Augmenter les timeouts :**
   - Prowlarr > Settings > Indexers
   - Augmentez "Search Timeout"

---

## Sauvegarde & Restauration

### Sauvegarder la configuration

```bash
# Manuellement
tar -czf backup_$(date +%Y%m%d).tar.gz /volume1/docker/r-apps/

# Ou utiliser Hyper Backup Synology
# File Station > Hyper Backup > Créer une tâche de sauvegarde
```

### Restaurer depuis une sauvegarde

```bash
# Extraire le backup
tar -xzf backup_20250102.tar.gz -C /

# Redémarrer les services
docker-compose restart
```

---

## Logs & Debugging

### Voir les logs en temps réel

```bash
cd /volume1/docker

# Tous les services
docker-compose logs -f

# Un service spécifique
docker-compose logs -f radarr
docker-compose logs -f sonarr
docker-compose logs -f prowlarr
docker-compose logs -f overseerr
docker-compose logs -f qbittorrent
docker-compose logs -f wireguard (si installé)
```

### Exporter les logs

```bash
# Exporter tous les logs
docker-compose logs > /tmp/docker-logs.txt

# Sur votre ordinateur (via SCP)
scp admin@<IP_NAS>:/tmp/docker-logs.txt ./
```

---

## Mises à Jour

### Mettre à jour les images Docker

```bash
cd /volume1/docker

# Télécharger les nouvelles versions
docker-compose pull

# Redémarrer avec les nouvelles versions
docker-compose up -d

# Vérifier
docker-compose ps
```

### Mettre à jour le script setup.sh

```bash
cd /volume1/media-stack

# Récupérer les dernières mises à jour
git pull

# Relancer (si nécessaire)
./setup.sh
```

---

## Réinitialisation Complète

⚠️ **ATTENTION : Cela supprimera toutes les données !**

```bash
# Arrêter les services
cd /volume1/docker
docker-compose down

# Supprimer les conteneurs
docker-compose down -v

# Supprimer les dossiers de configuration
rm -rf /volume1/docker/r-apps/*/config/*

# Relancer (recrée les configs par défaut)
docker-compose up -d
```

---

## Besoin d'aide ?

- 📖 Consultez le **README.md**
- 🌐 Consultez **FREEBOX_SETUP.md** pour les ports
- 💬 Issues sur GitHub
- 🔗 Communautés :
  - Sonarr: https://forums.sonarr.tv/
  - Radarr: https://forums.radarr.tv/
  - Overseerr: https://github.com/sct/overseerr
