# 🎬 Guide Complet Radarr

> Automatisation complète de la gestion de films

**⏱️ Temps estimé :** 25-30 minutes  
**📊 Niveau :** Intermédiaire  
**🔗 Prérequis :** Radarr installé, Prowlarr configuré, qBittorrent opérationnel

---

## 📖 Table des matières

1. [Qu'est-ce que Radarr ?](#quest-ce-que-radarr-)
2. [Première connexion](#première-connexion)
3. [Configuration Media Management](#configuration-media-management)
4. [Profils de qualité](#profils-de-qualité)
5. [Ajouter des indexers](#ajouter-des-indexers)
6. [Configurer Download Client](#configurer-download-client)
7. [Ajouter des films](#ajouter-des-films)
8. [Listes automatiques](#listes-automatiques)
9. [Recherche et monitoring](#recherche-et-monitoring)
10. [Troubleshooting](#troubleshooting)

---

## Qu'est-ce que Radarr ?

**Radarr** est un **gestionnaire automatique de films** qui :

### Fonctionnalités principales

✅ **Recherche automatique** de films sur vos indexers  
✅ **Téléchargement automatique** via qBittorrent  
✅ **Renommage intelligent** selon vos règles  
✅ **Organisation** dans `/movies`  
✅ **Monitoring** des sorties (Bluray, Web-DL, etc.)  
✅ **Upgrade automatique** vers meilleure qualité  
✅ **Notifications** (Discord, Telegram, etc.)

### Workflow automatique

```
1. Vous ajoutez un film dans Radarr
2. Radarr recherche sur Prowlarr (YGG, etc.)
3. Prowlarr retourne les meilleurs torrents
4. Radarr envoie à qBittorrent
5. qBittorrent télécharge
6. Radarr renomme et déplace dans /movies
7. Plex détecte automatiquement
8. Film disponible !
```

**Zéro intervention manuelle après configuration** ✨

---

## Première connexion

### Accéder à Radarr

🌐 **URL :** `http://<IP_NAS>:7878`

### Configuration initiale

**1. Authentification (recommandée)**

- Settings > General > Security
- **Authentication** : Forms (Login Page)
- **Username** : admin
- **Password** : (choisir mot de passe fort)
- ✅ Save

**2. API Key**

- Settings > General > Security
- **API Key** : `a1b2c3d4...` (copier pour Prowlarr/Overseerr)

---

## Configuration Media Management

**Settings > Media Management**

### Movie Naming

**Standard Movie Format :**
```
{Movie Title} ({Release Year}) - {Quality Full}
```

**Exemples de résultat :**
```
The Matrix (1999) - Bluray-1080p.mkv
Le Comte de Monte-Cristo (2024) - WEB-DL-2160p.mkv
```

**Movie Folder Format :**
```
{Movie Title} ({Release Year})
```

**Résultat :**
```
/movies/The Matrix (1999)/The Matrix (1999) - Bluray-1080p.mkv
```

---

### Options recommandées

| Option | Valeur | Explication |
|--------|--------|-------------|
| **Rename Movies** | ✅ Enabled | Renomme automatiquement |
| **Replace Illegal Characters** | ✅ Enabled | Retire : / \ ? etc. |
| **Colon Replacement** | Delete | `Film: Titre` → `Film Titre` |
| **Standard Movie Format** | (voir ci-dessus) | Format de fichier |
| **Movie Folder Format** | (voir ci-dessus) | Format de dossier |

---

### File Management

| Option | Valeur | Explication |
|--------|--------|-------------|
| **Unmonitor Deleted Movies** | ✅ Enabled | Arrête monitoring si supprimé |
| **Propers and Repacks** | Prefer and Upgrade | Upgrade automatique si PROPER/REPACK |
| **Analyse video files** | ✅ Enabled | Détecte codec, résolution |
| **Change File Date** | None | Garder date originale |
| **Recycling Bin** | (vide) | Ou `/recyclebin` si vous voulez |

✅ **Save Settings**

---

## Profils de qualité

**Settings > Profiles**

### Profil par défaut : "Any"

Par défaut, Radarr a un profil "Any" qui accepte toutes les qualités.

**Recommandé : Créer des profils personnalisés**

---

### Profil "HD" (recommandé pour la plupart)

**1. Add Profile**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | HD |
| **Upgrades Allowed** | ✅ Yes |
| **Upgrade Until** | Bluray-1080p |

**2. Qualities (ordre de préférence) :**

```
Bluray-1080p      ✅ (meilleure qualité)
WEB-DL-1080p      ✅
WEBDL-1080p       ✅
HDTV-1080p        ✅
Bluray-720p       ✅
WEB-DL-720p       ✅
HDTV-720p         ✅
DVD               ❌ (désactivé)
```

**Explication :**
- Radarr acceptera 720p/1080p
- Mais upgradé automatiquement vers Bluray-1080p si disponible

---

### Profil "4K" (si vous avez l'espace)

| Paramètre | Valeur |
|-----------|--------|
| **Name** | 4K |
| **Upgrade Until** | Bluray-2160p |

**Qualities :**
```
Bluray-2160p      ✅
WEBDL-2160p       ✅
Bluray-1080p      ✅ (temporaire)
```

⚠️ **4K = fichiers TRÈS lourds** (30-80 GB par film)

---

### Profil "SD" (connexion limitée)

| Paramètre | Valeur |
|-----------|--------|
| **Name** | SD |
| **Upgrade Until** | WEB-DL-720p |

**Qualities :**
```
WEB-DL-720p       ✅
HDTV-720p         ✅
DVD               ✅
```

---

## Ajouter des indexers

### Via Prowlarr (recommandé)

Si Prowlarr est configuré, vos indexers sont **automatiquement synchronisés**.

**Vérification :**
- Settings > Indexers
- Vous devriez voir : YGGTorrent, YTS, EZTV, etc.

✅ **Si vos indexers sont là, passez à la section suivante.**

---

### Manuellement (si pas de Prowlarr)

**Settings > Indexers > Add Indexer**

**Recherchez votre tracker, exemple "YTS" :**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | YTS |
| **Enable RSS** | ✅ |
| **Enable Automatic Search** | ✅ |
| **Enable Interactive Search** | ✅ |
| **Minimum Seeders** | 1 |

✅ Test & Save

---

## Configurer Download Client

**Settings > Download Clients > Add > qBittorrent**

### Configuration qBittorrent

| Paramètre | Valeur | Explication |
|-----------|--------|-------------|
| **Name** | qBittorrent | Nom du client |
| **Enable** | ✅ | Activer |
| **Host** | `qbittorrent` | Nom DNS Docker |
| **Port** | `8080` | Port WebUI |
| **Username** | `admin` | Login qBittorrent |
| **Password** | `adminadmin` | (ou votre mdp) |
| **Category** | `movies` | ⚠️ IMPORTANT |
| **Priority** | Default | Priorité téléchargement |

---

### Options avancées

| Option | Valeur | Explication |
|--------|--------|-------------|
| **Remove Completed** | ❌ Disabled | Laisse seeder (YGG) |
| **Remove Failed** | ✅ Enabled | Supprime échecs |
| **Initial State** | Start | Démarre immédiatement |

✅ **Test** → Doit être vert ✅  
✅ **Save**

---

## Ajouter des films

### Méthode 1 : Recherche manuelle

**1. Movies > Add New Movie**

**2. Recherchez un film**

Tapez : `Matrix`

**3. Sélectionnez le film**

Cliquez sur "The Matrix (1999)"

**4. Configuration**

| Paramètre | Valeur |
|-----------|--------|
| **Root Folder** | `/movies` |
| **Monitor** | Movie Only (ou Movie and Collection) |
| **Minimum Availability** | Released (ou Announced si impatient) |
| **Quality Profile** | HD (ou votre profil) |
| **Tags** | (vide ou custom) |

**5. Options**

- ✅ **Start search for missing movie** (recherche immédiate)
- ❌ Add Without Searching (ajout sans recherche)

**6. Add Movie**

→ Radarr va **immédiatement** :
1. Rechercher le film sur tous vos indexers
2. Choisir le meilleur torrent
3. L'envoyer à qBittorrent
4. Surveiller le téléchargement

---

### Méthode 2 : Import depuis dossier existant

Si vous avez déjà des films :

**1. Movies > Library Import**

**2. Sélectionnez `/movies`**

**3. Radarr scanne et détecte vos films**

**4. Associez chaque film**

Radarr essaiera de reconnaître automatiquement.

✅ Import

---

## Listes automatiques

Radarr peut **ajouter automatiquement** des films depuis des listes.

**Settings > Lists > Add List**

### Liste IMDb

**1. Sélectionnez "IMDb List"**

**2. Configuration**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | IMDb Top 250 |
| **Enable Automatic Add** | ✅ |
| **Monitor** | Movie Only |
| **Minimum Availability** | Released |
| **Quality Profile** | HD |
| **Root Folder** | `/movies` |
| **Tags** | `imdb` |
| **List URL** | https://www.imdb.com/chart/top |

✅ Test & Save

**Résultat :** Radarr ajoutera automatiquement les films du Top 250 IMDb !

---

### Liste Trakt

**1. Add List > "Trakt List"**

**2. Authentifiez-vous sur Trakt.tv**

**3. Choisissez vos listes** :
- Trending
- Popular
- Anticipated
- Watchlist personnelle

✅ Radarr sync toutes les 24h

---

## Recherche et monitoring

### Recherche automatique

**Par défaut, Radarr recherche automatiquement :**

1. **RSS Sync** (toutes les 15 min)
   - Vérifie les nouveaux torrents
   - Upgrade si meilleure qualité

2. **Au

towanted Search** (quotidien)
   - Recherche films "Wanted" (manquants)

**Settings > Indexers > Options**

| Option | Valeur | Explication |
|--------|--------|-------------|
| **RSS Sync Interval** | 15 minutes | Fréquence vérification |
| **Minimum Age** | 0 | Délai avant download (minutes) |
| **Retention** | 0 | Conservation historique (jours) |

---

### Recherche manuelle

**1. Cliquez sur un film**

**2. Bouton "Search" (icône 🔍)**

**3. Radarr affiche tous les torrents disponibles**

```
Titre                         Taille  Seed  Quality      Indexer
The Matrix 1999 1080p BluRay  8.5 GB   47   Bluray-1080p YGGTorrent
The Matrix 1999 720p BluRay   4.2 GB   89   Bluray-720p  YTS
...
```

**4. Cliquez sur le torrent voulu**

→ Envoyé à qBittorrent automatiquement

---

### Activity Queue

**Activity > Queue**

Voir les téléchargements en cours :
```
Film                      Progress  ETA       Download Speed
The Matrix (1999)         47%       12 min    5.2 MB/s
```

---

## Troubleshooting

### ❌ "No indexers available with automatic search enabled"

**Cause :** Aucun indexer configuré ou tous désactivés.

**Solutions :**

1. **Vérifier Settings > Indexers**
   - Au moins 1 indexer doit être présent
   - ✅ Enable Automatic Search coché

2. **Si vide : ajouter indexers**
   - Via Prowlarr (recommandé)
   - Ou manuellement

---

### ❌ Film ajouté mais pas de recherche

**Causes possibles :**

**1. "Start search" pas coché**
- Lors de l'ajout, cochez ✅ "Start search for missing movie"

**2. Minimum Availability**
- Si défini sur "Released" mais film pas sorti
- Solution : Changer en "Announced"

**3. Indexers down**
- System > Status
- Vérifier que indexers sont 🟢

---

### ❌ "No results found"

**Causes :**

**1. Film trop récent**
- Pas encore disponible en torrent
- Attendez quelques jours/semaines

**2. Mauvaise recherche**
- Radarr cherche "The Matrix" mais YGG a "Matrix"
- Settings > Movies > Edit > Alternate Titles
- Ajouter titre français

**3. Qualité trop élevée**
- Profil "4K" mais film seulement en 1080p
- Solution : Profil "HD" ou "Any"

---

### ⚠️ Film téléchargé mais pas importé

**Causes :**

**1. Catégorie qBittorrent incorrecte**
- Doit être `movies`
- qBittorrent > Torrent > Catégorie : movies

**2. Permissions dossiers**
```bash
chmod 775 -R /volume1/torrents
chmod 775 -R /volume1/media/movies
```

**3. Logs Radarr**
- System > Logs
- Chercher erreurs "import failed"

---

### 🔴 "Failed to import"

**Vérifiez :**

**1. Format fichier**
- Radarr supporte : .mkv, .mp4, .avi
- Pas : .rar, .zip (extraire d'abord)

**2. Taille minimale**
- Settings > Media Management
- Minimum Free Space : 100 MB (par défaut)
- Vérifier espace disque disponible

**3. Analyse du fichier**
```bash
# Voir si le fichier est valide
file /volume1/torrents/complete/movies/Matrix.mkv
```

---

### ❌ Upgrade ne fonctionne pas

**Cause :** Profil mal configuré.

**Solution :**

1. **Settings > Profiles > HD**
2. **Upgrades Allowed** : ✅ Enabled
3. **Upgrade Until** : Bluray-1080p (ou votre cible)
4. Save

---

## 📊 Configuration recommandée finale

```yaml
# Media Management
Rename Movies: ✅
Format: {Movie Title} ({Release Year}) - {Quality Full}
Replace Illegal Characters: ✅

# Quality Profile
Name: HD
Upgrade Until: Bluray-1080p
Qualities: 720p, 1080p

# Indexers (via Prowlarr)
YGGTorrent: ✅ Priority 50
YTS: ✅ Priority 25
1337x: ✅ Priority 20

# Download Client
qBittorrent: ✅
Category: movies
Remove Completed: ❌ (pour YGG ratio)

# Lists (optionnel)
IMDb Top 250: ✅
Trakt Trending: ✅

# Monitoring
Minimum Availability: Released
RSS Sync: 15 minutes
```

---

## 📚 Guides connexes

- **[Sonarr](04-sonarr.md)** — Configuration similaire pour séries
- **[Prowlarr](02-prowlarr.md)** — Gestion indexers
- **[qBittorrent](01-qbittorrent.md)** — Configuration client
- **[Overseerr](05-overseerr.md)** — Interface demande films

---

**✅ Radarr est maintenant parfaitement configuré !**

Vos films seront désormais **automatiquement** recherchés, téléchargés, renommés et organisés ! 🎬
