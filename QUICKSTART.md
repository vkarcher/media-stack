# 🚀 Quick Start — 5 minutes pour un setup complet

## Étape 1️⃣ : Sur votre ordinateur

```bash
# Clonez le dépôt
git clone https://github.com/vkarcher/media-stack.git
cd media-stack

# Copiez le script sur le NAS (remplacez l'IP)
scp setup.sh admin@192.168.1.X:/tmp/
```

## Étape 2️⃣ : SSH sur le NAS

```bash
ssh admin@192.168.1.X
sudo -i
cd /tmp
chmod +x setup.sh
./setup.sh
```

## Étape 3️⃣ : Le script pose des questions

```
Inclure support pour les animés ? (y/n) [y] 
→ Tapez : y (ou entrée)

Installer WireGuard VPN pour qBittorrent ? (y/n) [n] 
→ Tapez : y (recommandé pour sécurité) ou n
```

## Étape 4️⃣ : Attendez la fin ✅

Le script va :
- Créer `/volume1/docker`, `/volume1/media`, `/volume1/torrents`
- Installer Docker Compose (si nécessaire)
- Lancer tous les services
- Afficher les URLs d'accès

**Temps : ~2-5 minutes selon la connexion internet**

---

## 📝 Configuration rapide des applications

### 1. qBittorrent : `http://<IP_NAS>:8080`

- Identifiants : `admin` / `adminadmin`
- Options > Applications Web : Ajouter `http://<IP_NAS>:9696`
- Créer catégories Movies, Series, Anime

### 2. Prowlarr : `http://<IP_NAS>:9696`

- Ajouter des indexers/trackers
- Apps : Radarr, Sonarr, Sonarr-Anime

### 3. Radarr : `http://<IP_NAS>:7878`

- Indexers : ajouter Prowlarr
- Download Client : ajouter qBittorrent
- Media Folder : `/movies`

### 4. Sonarr : `http://<IP_NAS>:8989`

- Même config que Radarr
- Media Folder : `/series`

**Pour les animés (si activé) :**
- Ajouter dossier racine `/anime` (Settings > Media Management > Root Folders)
- Créer profil "Anime" (Settings > Profiles)
- Tag "anime" pour organiser (Settings > Tags)
- Ajouter indexer Nyaa.si dans Prowlarr

### 5. Overseerr : `http://<IP_NAS>:5055`

- Serveur Plex : `http://<IP_NAS>:32400`
- Radarr, Sonarr
- Dans Sonarr : Root Folder séries `/series`, animés `/anime`
- Inviter les utilisateurs Plex

### 6. Plex Media Server

**⚠️ Installation requise avant de continuer :**

🔗 **Télécharger Plex :** https://www.plex.tv/fr/media-server-downloads/?cat=nas&plat=synology-dsm72

1. Téléchargez le fichier `.spk` (x86_64 pour DS224+)
2. **Centre de paquets** > **Installation manuelle**
3. Installez le `.spk`
4. Accédez à `http://<IP_NAS>:32400/web`
5. Créez votre compte Plex (gratuit)
6. Ajoutez vos bibliothèques :
   - Films : `/volume1/media/movies`
   - Séries : `/volume1/media/series`
   - Animés : `/volume1/media/anime` (si activé)

**→ Guide détaillé :** [docs/apps/06-plex.md](docs/apps/06-plex.md)

---

## 🌐 Redirection Freebox (10 minutes)

Allez sur **http://mafreebox.freebox.fr** > Paramètres > Gestion des ports

| Service | Port | Type |
|---------|------|------|
| Radarr | 7878 | TCP |
| Sonarr | 8989 | TCP |
| Prowlarr | 9696 | TCP |
| qBittorrent | 8080 | TCP |
| qBittorrent P2P | 6881 | TCP + UDP |
| Overseerr | 5055 | TCP |
| Plex | 32400 | TCP |

**⚠️ Voir `FREEBOX_SETUP.md` pour plus de détails**

---

## ✅ Test rapide

### Sur le NAS

```bash
cd /volume1/docker

# Voir l'état des services
docker-compose ps

# Voir les logs
docker-compose logs -f
```

### De l'intérieur du réseau

```bash
# Accédez à Overseerr
http://192.168.1.X:5055

# Cherchez un film/série
# Cliquez sur "Request"
# Observez les logs
```

### De l'extérieur (Freebox configurée)

```bash
# Trouvez votre IP Freebox publique (https://monip.com)
http://<IP_PUBLIQUE>:5055
```

---

## 🆘 Ça ne fonctionne pas ?

1. **Vérifier les logs :**
   ```bash
   cd /volume1/docker
   docker-compose logs radarr
   ```

2. **Redémarrer les services :**
   ```bash
   docker-compose restart
   ```

3. **Consulter :**
   - `README.md` — Documentation complète
   - `TROUBLESHOOTING.md` — Solutions courantes
   - `FREEBOX_SETUP.md` — Configuration ports

---

## 💡 Prochaines étapes

- ✅ Configurer plus de trackers (privés si accès)
- ✅ Activer le VPN pour qBittorrent
- ✅ Installer Nginx Proxy Manager + HTTPS
- ✅ Automatiser les sous-titres (Bazarr)
- ✅ Ajouter Tautulli pour stats Plex

---

**🎉 Fait ! Vous avez une stack média automatisée complète !**

Pour des détails, consultez `README.md`
