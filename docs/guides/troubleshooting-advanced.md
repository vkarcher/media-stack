# 🔧 Troubleshooting Avancé

> Solutions aux problèmes complexes et optimisations

**⏱️ Temps estimé :** Variable  
**📊 Niveau :** Avancé  
**🔗 Prérequis :** Connaissances Docker, Linux basiques

---

## 📖 Table des matières

1. [Logs Docker détaillés](#logs-docker-détaillés)
2. [Problèmes réseau](#problèmes-réseau)
3. [Permissions fichiers](#permissions-fichiers)
4. [Optimisation performances](#optimisation-performances)
5. [Migration configuration](#migration-configuration)
6. [Debugging avancé](#debugging-avancé)

---

## Logs Docker détaillés

### Voir tous les logs

```bash
cd /volume1/docker

# Logs de tous les conteneurs
docker-compose logs

# Logs en temps réel (tous)
docker-compose logs -f

# Logs spécifique
docker-compose logs -f radarr
```

---

### Filtrer logs par erreur

```bash
# Erreurs seulement
docker-compose logs | grep -i error

# Avertissements
docker-compose logs | grep -i warn

# Service spécifique + erreurs
docker-compose logs radarr | grep -i "error\|fail"
```

---

### Logs avec timestamps

```bash
docker-compose logs -f --timestamps radarr
```

---

### Exporter logs

```bash
# Sauvegarder dans fichier
docker-compose logs radarr > radarr_logs_$(date +%Y%m%d).txt

# Dernières 1000 lignes
docker-compose logs --tail=1000 radarr > radarr_last1000.txt
```

---

## Problèmes réseau

### Test connectivité entre conteneurs

```bash
# Entrer dans un conteneur
docker exec -it radarr /bin/bash

# Tester ping vers autre conteneur
ping prowlarr

# Tester résolution DNS
nslookup prowlarr

# Tester port spécifique
nc -zv qbittorrent 8080

# curl API
curl http://prowlarr:9696/api/v1/health
```

---

### Vérifier réseau Docker

```bash
# Lister réseaux
docker network ls

# Inspecter réseau
docker network inspect bridge

# Voir quels conteneurs sont sur quel réseau
docker inspect radarr | grep -i network
```

---

### DNS ne fonctionne pas

**Symptôme :** Conteneurs ne se trouvent pas par nom

**Solutions :**

**1. Vérifier tous sur même réseau**

```bash
docker network inspect bridge | grep Name
```

Tous vos conteneurs doivent apparaître.

**2. Redémarrer Docker daemon**

```bash
sudo systemctl restart docker
```

**3. Recréer réseau**

```bash
docker-compose down
docker network prune
docker-compose up -d
```

---

## Permissions fichiers

### Problème classique

```
Error: Permission denied
Cannot write to /movies
```

**Cause :** PUID/PGID incorrects

---

### Vérifier PUID/PGID

```bash
# Votre utilisateur actuel
id

# Devrait montrer :
# uid=1026(admin) gid=100(users)
```

---

### Corriger permissions

**1. Chown récursif**

```bash
# Tous dossiers média
sudo chown -R 1026:100 /volume1/media
sudo chown -R 1026:100 /volume1/torrents
sudo chown -R 1026:100 /volume1/docker/r-apps
```

**2. Chmod**

```bash
# Lecture+écriture pour tous
sudo chmod -R 775 /volume1/media
sudo chmod -R 775 /volume1/torrents
```

---

### Vérifier permissions actuelles

```bash
ls -la /volume1/media/

# Devrait montrer :
# drwxrwxr-x ... 1026 users ... movies
```

---

### Permissions Docker volumes

```yaml
# Dans docker-compose.yml
volumes:
  - /volume1/media:/media:rw  # rw = read-write
```

---

## Optimisation performances

### Limiter ressources conteneurs

**Éviter que Docker consomme tout le CPU/RAM**

```yaml
# docker-compose.yml
services:
  radarr:
    ...
    deploy:
      resources:
        limits:
          cpus: '0.5'      # Max 50% CPU
          memory: 512M     # Max 512 MB RAM
        reservations:
          cpus: '0.25'
          memory: 256M
```

---

### Monitoring ressources

```bash
# Stats temps réel
docker stats

# Spécifique
docker stats radarr sonarr prowlarr
```

---

### Optimiser base de données

**Radarr/Sonarr utilisent SQLite**

```bash
# Entrer dans conteneur
docker exec -it radarr /bin/bash

# Optimiser DB
sqlite3 /config/radarr.db "VACUUM;"
sqlite3 /config/radarr.db "REINDEX;"
```

---

### Cache Plex

```bash
# Vider cache Plex (si lent)
rm -rf /volume1/docker/r-apps/plex/config/Library/Application\ Support/Plex\ Media\ Server/Cache/*
```

---

## Migration configuration

### Sauvegarder configs

```bash
# Backup complet
tar -czf backup_$(date +%Y%m%d).tar.gz \
  /volume1/docker/r-apps/*/config

# Backup sélectif
tar -czf radarr_backup.tar.gz \
  /volume1/docker/r-apps/radarr/config
```

---

### Restaurer configs

```bash
# Extraire backup
tar -xzf backup_20241202.tar.gz -C /

# Redémarrer services
docker-compose restart
```

---

### Migrer vers nouveau NAS

**1. Sur ancien NAS :**

```bash
# Backup
tar -czf media-stack-backup.tar.gz \
  /volume1/docker/r-apps \
  /volume1/media \
  /volume1/torrents
```

**2. Transférer fichier backup**

```bash
scp media-stack-backup.tar.gz admin@<NEW_NAS_IP>:/tmp/
```

**3. Sur nouveau NAS :**

```bash
# Extraire
tar -xzf /tmp/media-stack-backup.tar.gz -C /volume1/

# Lancer setup.sh
./setup.sh
```

---

## Debugging avancé

### Mode debug Radarr/Sonarr

**Settings > General > Log Level**

```
Trace (très verbeux)
```

**Puis :**

```bash
docker-compose logs -f radarr | grep -i trace
```

---

### Tester API manuellement

```bash
# Get API Key de Radarr
cat /volume1/docker/r-apps/radarr/config/config.xml | grep ApiKey

# Tester API
curl -H "X-Api-Key: YOUR_API_KEY" \
  http://localhost:7878/api/v3/system/status | jq
```

---

### Inspecter conteneur

```bash
# Infos complètes conteneur
docker inspect radarr

# Voir variables env
docker inspect radarr | grep -A 20 Env

# Voir volumes
docker inspect radarr | grep -A 10 Mounts
```

---

### Redémarrage clean

```bash
# Arrêter tout
docker-compose down

# Nettoyer volumes orphelins
docker volume prune

# Nettoyer réseaux
docker network prune

# Redémarrer
docker-compose up -d
```

---

## 🚨 Problèmes critiques

### Conteneur crash en boucle

```bash
# Voir pourquoi
docker-compose logs radarr --tail=50

# Rebuild image
docker-compose pull radarr
docker-compose up -d --force-recreate radarr
```

---

### Base de données corrompue

```bash
# Backup DB
cp /volume1/docker/r-apps/radarr/config/radarr.db \
   /volume1/docker/r-apps/radarr/config/radarr.db.backup

# Réparer
sqlite3 /volume1/docker/r-apps/radarr/config/radarr.db ".recover" \
  | sqlite3 /volume1/docker/r-apps/radarr/config/radarr_recovered.db

# Remplacer
mv radarr_recovered.db radarr.db

# Redémarrer
docker-compose restart radarr
```

---

### Docker daemon ne démarre pas

```bash
# Status
sudo systemctl status docker

# Logs systemd
sudo journalctl -u docker --no-pager | tail -50

# Restart daemon
sudo systemctl restart docker
```

---

## 📚 Guides connexes

- **[qBittorrent](../apps/01-qbittorrent.md)** — Troubleshooting qBittorrent
- **[Radarr](../apps/03-radarr.md)** — Troubleshooting Radarr
- **[Sonarr](../apps/04-sonarr.md)** — Troubleshooting Sonarr

---

**✅ Guide troubleshooting avancé !**

En cas de problème complexe, commencez par les logs ! 🔍
