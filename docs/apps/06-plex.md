# 📽️ Guide Complet Plex Media Server

> Serveur de streaming média pour tous vos appareils

**⏱️ Temps estimé :** 30 minutes  
**📊 Niveau :** Débutant  
**🔗 Prérequis :** NAS avec médias organisés

---

## 📖 Table des matières

1. [Qu'est-ce que Plex ?](#quest-ce-que-plex-)
2. [Installation](#installation)
3. [Première configuration](#première-configuration)
4. [Ajouter bibliothèques](#ajouter-bibliothèques)
5. [Agents metadata](#agents-metadata)
6. [Transcoding](#transcoding)
7. [Utilisateurs](#utilisateurs)
8. [Applications client](#applications-client)
9. [Troubleshooting](#troubleshooting)

---

## Qu'est-ce que Plex ?

**Plex Media Server** transforme votre NAS en **Netflix personnel** :

### Fonctionnalités

✅ **Streaming** — Regardez partout (TV, mobile, PC, navigateur)  
✅ **Metadata** — Posters, synopsis, notes IMDb automatiques  
✅ **Transcoding** — Adapte qualité selon connexion  
✅ **Multi-utilisateurs** — Comptes famille/amis  
✅ **Synchronisation** — Téléchargez pour hors-ligne  
✅ **Multi-plateformes** — iOS, Android, Smart TV, etc.

### Plex vs Jellyfin

| Aspect | Plex | Jellyfin |
|--------|------|----------|
| **Prix** | Gratuit (+ Plex Pass optionnel) | 100% gratuit |
| **Interface** | Plus polie | Open-source |
| **Apps** | Toutes plateformes | Moins d'apps |
| **Transcoding** | Excellent | Bon |
| **Live TV** | Plex Pass | Gratuit |

---

## Installation

### Sur Synology NAS

**Méthode 1 : Téléchargement manuel (recommandée pour DSM 7.2+)**

🔗 **Télécharger Plex :** https://www.plex.tv/fr/media-server-downloads/?cat=nas&plat=synology-dsm72

1. Téléchargez le fichier `.spk` pour votre architecture (x86_64 pour DS224+)
2. **Centre de paquets** > **Installation manuelle**
3. Sélectionnez le fichier `.spk` téléchargé
4. **Installer** et suivez l'assistant

**Méthode 2 : Package Center (alternative)**

1. **Centre de paquets** Synology
2. Recherchez **"Plex Media Server"**
3. **Installer**
4. Suivez l'assistant

💡 **Note :** La méthode 1 garantit la dernière version officielle

---

**Méthode 2 : Docker (si vous préférez)**

Ajoutez à `docker-compose.yml` :

```yaml
  plex:
    image: lscr.io/linuxserver/plex:latest
    container_name: plex
    network_mode: host
    environment:
      - PUID=1026
      - PGID=100
      - VERSION=docker
      - TZ=Europe/Paris
    volumes:
      - /volume1/docker/r-apps/plex/config:/config
      - /volume1/media:/media
    restart: unless-stopped
```

```bash
docker-compose up -d plex
```

---

### Sur autres systèmes

- **Windows** : https://www.plex.tv/media-server-downloads/
- **Mac** : Même lien
- **Linux** : `sudo apt install plexmediaserver`

---

## Première configuration

### Accéder à Plex

🌐 **URL :** `http://<IP_NAS>:32400/web`

### Créer compte Plex

**1. Sign Up (si pas de compte)**

- Email
- Username
- Password

**2. Sign In (si compte existant)**

---

### Configuration serveur

**Assistant de configuration :**

**Étape 1 : Serveur détecté**

Plex détecte automatiquement votre serveur.

Nom : `<Nom_NAS>` (ou personnalisez)

✅ Next

---

**Étape 2 : Accès extérieur**

**Permettre accès depuis Internet ?**

- ✅ **Oui** : Accessible partout (4G, vacances, etc.)
- ❌ **Non** : Seulement réseau local

**Recommandation :** ✅ Oui (Plex gère sécurité)

✅ Next

---

**Étape 3 : Ajouter bibliothèques**

(On fait ça en détail dans section suivante)

Cliquez **"Later"** pour l'instant.

✅ Done

---

## Ajouter bibliothèques

### Films

**Settings > Libraries > Add Library**

**1. Type de bibliothèque**

Sélectionnez : **Movies**

**2. Nom**

```
Nom : Films
(ou "Movies" si anglais)
```

**3. Langue**

```
Language: Français
(ou English selon préférence)
```

**4. Ajouter dossiers**

**Add Folder** :
```
/volume1/media/movies
```

ou si Docker :
```
/media/movies
```

**5. Options avancées (recommandées)**

| Option | Valeur | Explication |
|--------|--------|-------------|
| **Scanner** | Plex Movie | Détection films |
| **Agent** | Plex Movie | Metadata |
| **Enable video preview thumbnails** | ✅ | Aperçus vidéo |
| **Enable intro detection** | ✅ | Détecte génériques (Plex Pass) |
| **Collections** | Show Collections | Affiche collections (Marvel, etc.) |

✅ **Add Library**

---

### Séries TV

**Add Library > TV Shows**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | Séries |
| **Language** | Français |
| **Folder** | `/volume1/media/series` |
| **Scanner** | Plex Series |
| **Agent** | The TVDB |
| **Episode ordering** | TheTVDB (or Aired) |

✅ Add Library

---

### Animés

**Add Library > TV Shows**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | Animés |
| **Language** | Français (ou Japonais) |
| **Folder** | `/volume1/media/anime` |
| **Scanner** | Plex Series |
| **Agent** | The TVDB |
| **Episode ordering** | **Absolute** ⚠️ |

**💡 Absolute ordering** est important pour animés (épisodes numérotés 1, 2, 3... au lieu de S01E01).

✅ Add Library

---

### Scan bibliothèques

Plex va automatiquement scanner les dossiers.

**Forcer un scan manuel :**

1. Cliquez sur bibliothèque (Films, Séries, etc.)
2. **⋮** (3 points) > **Scan Library Files**

⏳ Attendez fins du scan (peut prendre 10-30 min si beaucoup de fichiers)

---

## Agents metadata

Les **agents** récupèrent automatiquement :
- Posters
- Résumés
- Notes
- Casting
- Genres

### Agents par défaut

- **Films** : Plex Movie (utilise IMDb, TMDB)
- **Séries** : The TVDB
- **Animés** : The TVDB (ou AniDB si configuré)

---

### Améliorer metadata

**Si posters/infos incorrects :**

**1. Clic sur le média**

**2. Icône "..." > Fix Match**

**3. Recherchez à nouveau**

Tapez le titre correct ou ID (IMDb, TVDB).

**4. Match**

Plex va re-télécharger les metadata.

---

### Options metadata

**Settings > Library > (votre bibliothèque) > Edit**

**Advanced**

| Option | Recommandation |
|--------|---------------|
| **Prefer local metadata** | ❌ (Plex metadata meilleure) |
| **Use embedded tags** | ❌ |
| **Store track titles in** | Plex |
| **Generate video preview thumbnails** | ✅ Scheduled |
| **Generate chapter thumbnails** | ✅ As a scheduled task |

---

## Transcoding

**Transcoding** = Convertir vidéo en temps réel pour s'adapter à la connexion.

### Pourquoi transcoder ?

**Exemple :**
```
Fichier original : 4K 80 Mbps (énorme)
Client : Mobile 4G (connexion 10 Mbps)
→ Plex transcode en 1080p 8 Mbps
```

---

### Configuration transcoding

**Settings > Transcoder**

| Option | Valeur | Explication |
|--------|--------|-------------|
| **Transcoder quality** | Automatic | Adapte selon client|
| **Transcoder default duration** | 60 minutes | |
| **Transcoder throttle buffer** | 60 seconds | |
| **Use hardware acceleration** | ✅ Si supporté | Intel QuickSync, NVIDIA, etc. |

---

### Hardware transcoding (Plex Pass)

**Nécessite Plex Pass ($5/mois ou $120 à vie)**

**Avantages :**
- ✅ Transcoding BEAUCOUP plus rapide
- ✅ Moins de charge CPU
- ✅ Plusieurs streams simultanés

**Synology :**
- DS224+ : Intel QuickSync ✅ Supporté
- Settings > Transcoder
- ✅ **Use hardware acceleration when available**

---

### DirectPlay vs Transcode

| Mode | Quand | Avantage |
|------|-------|----------|
| **DirectPlay** | Client compatible + bonne connexion | Pas de transcoding, instantané |
| **DirectStream** | Format compatible, conteneur pas | Léger transcoding |
| **Transcode** | Client incompatible ou connexion faible | Adapte qualité |

**Astuce :** Encouragez DirectPlay (moins charge serveur)

---

## Utilisateurs

### Gérer utilisateurs

**Settings > Users & Sharing**

**1. Enable** :
- ✅ **Plex Home** (utilisateurs locaux)
- ✅ **Friends** (utilisateurs externes)

---

### Ajouter un utilisateur Plex Home

**Add User (Plex Home)**

| Paramètre | Valeur |
|-----------|--------|
| **Username** | John |
| **Email** | (optionnel) |
| **PIN** | (optionnel, pour enfants) |
| **Managed User** | ✅ (si enfant) |

**Bibliothèques** :
- ✅ Films
- ✅ Séries
- ✅ Animés

✅ Save

---

### Inviter un ami (externe)

**Invite Friend**

1. Entrez l'**email** de votre ami
2. **Bibliothèques à partager** :
   - ✅ Films
   - ✅ Séries
   - (❌ Animés si privé)
3. **Restrictions** :
   - Limiter bande passante ?
   - Sync autorisé ?

✅ Send Invite

→ Votre ami reçoit email et peut accéder à votre serveur !

---

## Applications client

Plex est disponible **partout** :

### Web

🌐 **https://app.plex.tv**

Connexion avec votre compte → Accès à votre serveur

---

### Mobile

**iOS** : App Store → "Plex"  
**Android** : Play Store → "Plex"

**Note :** Première activation mobile = $5 one-time (ou Plex Pass)

---

### Smart TV

**Samsung** : Galaxy Store → "Plex"  
**LG** : LG Content Store → "Plex"  
**Android TV** : Play Store → "Plex"  
**Apple TV** : App Store → "Plex"

---

### PC/Mac

**Windows** : Microsoft Store → "Plex"  
**Mac** : Mac App Store → "Plex"

Ou toujours via navigateur web.

---

### Consoles

**PlayStation** : PlayStation Store → "Plex"  
**Xbox** : Microsoft Store → "Plex"

---

## Troubleshooting

### ❌ "Server not found"

**Causes :**

**1. Plex Server pas démarré**
```bash
# Synology
sudo systemctl status plexmediaserver

# Docker
docker ps | grep plex
```

**2. Port 32400 bloqué**
- Firewall Synology
- Freebox port forwarding

**3. Accès externe désactivé**
- Settings > Remote Access
- ✅ Enable Remote Access

---

### ⚠️ Transcoding très lent

**Solutions :**

**1. Activer hardware acceleration**
- Settings > Transcoder
- ✅ Use hardware acceleration (Plex Pass requis)

**2. Limiter qualité transcoding**
- Settings > Transcoder
- Transcoder quality : Automatic → Prefer higher speed

**3. DirectPlay si possible**
- Client > Settings > Quality
- Automatic → Original Quality

---

### ❌ Metadata incorrectes

**Solutions :**

**1. Fix Match**
- Film/Série > ⋮ > Fix Match
- Recherchez avec titre correct ou ID

**2. Refresh Metadata**
- ⋮ > Refresh Metadata
- Force re-download

**3. Nom fichier incorrect**
- Renommez selon format Plex :
  - Film : `Matrix (1999).mkv`
  - Série : `Breaking Bad - S01E01.mkv`

---

### 🔴 "Not authorized"

**Cause :** Connexion Plex expirée.

**Solution :**
- Sign Out
- Sign In à nouveau
- Ré-autorisez le serveur

---

### ⚠️ Buffering constant

**Causes :**

**1. Connexion trop lente**
- Client > Quality : Baissez qualité
- 1080p 10Mbps → 720p 4Mbps

**2. Serveur surchargé**
- Trop de streams simultanés
- Limitez nombre d'utilisateurs simultanés

**3. Disque dur lent**
- NAS avec HDD lent
- Upgrade vers SSD ou cache SSD

---

## 📊 Configuration recommandée finale

```yaml
# Serveur
Name: <Votre NAS>
Remote Access: ✅ Enabled

# Bibliothèques
Movies: /volume1/media/movies (Plex Movie agent)
TV Shows: /volume1/media/series (TVDB agent)
Anime: /volume1/media/anime (TVDB agent, Absolute ordering)

# Transcoding
Quality: Automatic
Hardware Acceleration: ✅ (si Plex Pass)

# Utilisateurs
Plex Home: Famille
Friends: Amis invités
Libraries Shared: Selon utilisateur

# Applications
Web: app.plex.tv
Mobile: App Plex (iOS/Android)
TV: App Plex Smart TV
```

---

## 📚 Guides connexes

- **[Radarr](03-radarr.md)** — Automatisation films → Plex
- **[Sonarr](04-sonarr.md)** — Automatisation séries → Plex
- **[Overseerr](05-overseerr.md)** — Interface demande Plex

---

**✅ Plex est configuré !**

Profitez de vos médias partout, sur tous vos appareils ! 📽️
