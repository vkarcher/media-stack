# 📺 Guide Complet Sonarr

> Automatisation complète de la gestion de séries TV et animés

**⏱️ Temps estimé :** 30-35 minutes  
**📊 Niveau :** Intermédiaire  
**🔗 Prérequis :** Sonarr installé, Prowlarr configuré, qBittorrent opérationnel

---

## 📖 Table des matières

1. [Qu'est-ce que Sonarr ?](#quest-ce-que-sonarr-)
2. [Première connexion](#première-connexion)
3. [Configuration Media Management](#configuration-media-management)
4. [Profils de qualité](#profils-de-qualité)
5. [Ajouter des indexers](#ajouter-des-indexers)
6. [Configurer Download Client](#configurer-download-client)
7. [Ajouter des séries](#ajouter-des-séries)
8. [Configuration pour animés](#-configuration-pour-animés)
9. [Calendrier et monitoring](#calendrier-et-monitoring)
10. [Troubleshooting](#troubleshooting)

---

## Qu'est-ce que Sonarr ?

**Sonarr** gère automatiquement vos **séries TV** et **animés** :

### Fonctionnalités principales

✅ **Monitoring épisodes** — Surveille sorties automatiquement  
✅ **Recherche automatique** — Trouve nouveaux épisodes  
✅ **Téléchargement auto** — Via qBittorrent  
✅ **Renommage intelligent** — Format S01E01  
✅ **Upgrade automatique** — Vers meilleure qualité  
✅ **Séries + Animés** — Un seul Sonarr suffit !  
✅ **Calendrier** — Voir prochaines sorties

### Workflow

```
1. Vous ajoutez une série
2. Sonarr monitore les nouveaux épisodes
3. Dès qu'un épisode sort →
4. Sonarr recherche sur Prowlarr
5. Télécharge via qBittorrent
6. Renomme et organise dans /series ou /anime
7. Plex détecte automatiquement
8. Épisode disponible !
```

---

## Première connexion

### Accéder à Sonarr

🌐 **URL :** `http://<IP_NAS>:8989`

### Configuration initiale

**1. Authentification**

- Settings > General > Security
- **Authentication** : Forms (Login Page)
- **Username** : admin
- **Password** : (mot de passe fort)
- ✅ Save

**2. API Key**

- Copier pour Prowlarr/Overseerr
- Settings > General > API Key

---

## Configuration Media Management

**Settings > Media Management**

### Episode Naming

**Standard Episode Format :**
```
{Series Title} - S{season:00}E{episode:00} - {Episode Title} [{Quality Full}]
```

**Résultat :**
```
Breaking Bad - S01E01 - Pilot [Bluray-1080p].mkv
Lupin - S02E05 - Chapitre 5 [WEB-DL-1080p].mkv
```

**Daily Episode Format (talk-shows) :**
```
{Series Title} - {Air-Date} - {Episode Title} [{Quality Full}]
```

**Anime Episode Format :**
```
{Series Title} - S{season:00}E{episode:00} - {absolute:000} - {Episode Title} [{Quality Full}]
```

**Résultat :**
```
One Piece - S01E1050 - 1050 - The Battle Ends [WEB-DL-1080p].mkv
```

---

### Folder Naming

**Series Folder Format :**
```
{Series Title}
```

**Season Folder Format :**
```
Season {season:00}
```

**Résultat :**
```
/series/
  └─ Breaking Bad/
      ├─ Season 01/
      │   ├─ Breaking Bad - S01E01 - Pilot.mkv
      │   └─ Breaking Bad - S01E02 - Cat's in the Bag.mkv
      └─ Season 02/
```

---

### Options recommandées

| Option | Valeur | Explication |
|--------|--------|-------------|
| **Rename Episodes** | ✅ | Renomme automatiquement |
| **Replace Illegal Characters** | ✅ | Retire : / \ ? |
| **Standard Episode Format** | (voir ci-dessus) | Format épisodes |
| **Season Folder Format** | Season {season:00} | Dossiers saisons |
| **Create empty folders** | ❌ | Pas de dossiers vides |
| **Delete empty folders** | ✅ | Nettoie automatiquement |
| **Episode Title Required** | Always | Exige titre épisode |

✅ **Save**

---

## Profils de qualité

**Settings > Profiles**

### Profil "HD" (séries classiques)

**Add Profile**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | HD |
| **Upgrade Allowed** | ✅ |
| **Upgrade Until** | Bluray-1080p |

**Qualities (ordre préférence) :**
```
Bluray-1080p      ✅
WEB-DL-1080p      ✅
WEBDL-1080p       ✅
HDTV-1080p        ✅
Bluray-720p       ✅
WEB-DL-720p       ✅
HDTV-720p         ✅
```

---

### Profil "Anime" (recommandé pour animés)

**Add Profile**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | Anime HD |
| **Upgrade Until** | Bluray-1080p |

**Qualities :**
```
Bluray-1080p      ✅
WEB-DL-1080p      ✅
HDTV-1080p        ✅
Bluray-720p       ✅
WEB-DL-720p       ✅
```

**💡 Pourquoi un profil Anime ?**
- Permet de différencier séries/animés
- Règles upgrade différentes si besoin
- Organisation plus claire

---

## Ajouter des indexers

### Via Prowlarr (automatique)

Si Prowlarr configuré :
- Settings > Indexers
- Vos indexers sont déjà là (YGGTorrent, EZTV, Nyaa, etc.)

✅ Passez à la section suivante

---

### Manuellement (si besoin)

**Pour séries classiques :**
- EZTV
- YGGTorrent (français)

**Pour animés :**
- **Nyaa.si** (essentiel !)
- SubsPlease
- AnimeTosho

**Settings > Indexers > Add Indexer**

Exemple Nyaa.si :
```yaml
Name: Nyaa
Enable RSS: ✅
Enable Automatic Search: ✅
Categories: TV/Anime
```

---

## Configurer Download Client

**Settings > Download Clients > Add > qBittorrent**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | qBittorrent |
| **Host** | `qbittorrent` |
| **Port** | `8080` |
| **Username** | `admin` |
| **Password** | `adminadmin` |
| **Category** | `series` ⚠️ |

### Options

| Option | Valeur |
|--------|--------|
| **Remove Completed** | ❌ (pour YGG) |
| **Remove Failed** | ✅ |
| **Initial State** | Start |

✅ Test & Save

---

## Ajouter des séries

### Méthode 1 : Recherche manuelle

**1. Series > Add New Series**

**2. Recherchez une série**

Tapez : `Breaking Bad`

**3. Sélectionnez**

Cliquez sur "Breaking Bad (2008)"

**4. Configuration**

| Paramètre | Valeur | Explication |
|-----------|--------|-------------|
| **Root Folder** | `/series` | Dossier destination |
| **Monitor** | All Episodes | Tous les épisodes |
| **Quality Profile** | HD | Profil qualité |
| **Series Type** | Standard | (Daily pour talk-shows, Anime pour animés) |
| **Season Folder** | ✅ Yes | Crée dossiers saisons |
| **Tags** | (vide) | Ou custom |

**5. Options**

- ✅ **Search for missing episodes** (recherche immédiate)
- ✅ **Search for cutoff unmet episodes** (upgrade)

**6. Add Series**

→ Sonarr va :
1. Créer `/series/Breaking Bad/`
2. Créer `Season 01/`, `Season 02/`, etc.
3. Rechercher TOUS les épisodes
4. Télécharger automatiquement

---

### Monitoring Options

**Monitor saisons spécifiques :**

| Option | Quand utiliser |
|--------|---------------|
| **All Episodes** | Séries terminées (binge) |
| **Future Episodes** | Séries en cours (nouveaux épisodes seulement) |
| **Missing Episodes** | Compléter collection |
| **Existing Episodes** | Upgrade seulement |
| **First Season** | Tester avant de tout télécharger |
| **Latest Season** | Saison en cours |
| **None** | Pas de téléchargement auto |

---

### Series Type

| Type | Usage |
|------|-------|
| **Standard** | Séries classiques (Breaking Bad, Lupin, etc.) |
| **Daily** | Talk-shows, journaux (Daily Show, etc.) |
| **Anime** | ⚠️ Animés japonais |

**💡 Important pour animés :** Series Type = Anime active :
- Numérotation absolue (1, 2, 3... au lieu de S01E01)
- Meilleure reconnaissance noms japonais
- Format spécifique

---

## 🎌 Configuration pour animés

**→ Voir aussi : [Guide Animés complet](../guides/anime-configuration.md)**

### Étape 1 : Ajouter dossier racine /anime

**Settings > Media Management > Root Folders**

**Add Root Folder :**
```
/anime
```

✅ Save

---

### Étape 2 : Créer tag "anime"

**Settings > Tags > Add Tag**

```
Tag Label: anime
```

---

### Étape 3 : Ajouter un animé

**1. Series > Add New**

**2. Recherchez** : `One Piece`

**3. Configuration spécifique animés**

| Paramètre | Valeur |
|-----------|--------|
| **Root Folder** | `/anime` ⚠️ |
| **Monitor** | All Episodes |
| **Quality Profile** | Anime HD |
| **Series Type** | **Anime** ⚠️ |
| **Season Folder** | ✅ |
| **Tags** | `anime` |

**4. Add Series**

---

### Indexers pour animés

**Essentiels :**

**1. Nyaa.si** (meilleur)
- Settings > Indexers
- Devrait être sync depuis Prowlarr
- Catégories : TV/Anime

**2. SubsPlease**
- Releases rapides VOSTFR

**3. AnimeTosho**
- Agrégateur multi-sources

---

### Noms d'animés non reconnus ?

**Problème courant :** TheTVDB a parfois des noms différents.

**Solutions :**

**1. Recherche avec nom anglais**
- ❌ `進撃の巨人` (kanji)
- ✅ `Attack on Titan` (anglais)

**2. Ajouter Alternate Titles**
- Series > Edit > Alternate Titles
- Ajouter : "Shingeki no Kyojin" (romaji)

**3. Recherche manuelle avec ID**
- TheTVDB ID ou AniDB ID

---

## Calendrier et monitoring

### Calendar

**Calendar (onglet)**

Vue des prochaines sorties :
```
Aujourd'hui:
  Breaking Bad - S05E14 (dans 2h)

Demain:
  The Walking Dead - S11E08
  One Piece - Episode 1051

Cette semaine:
  ...
```

**Options :**
- Vue jour / semaine / mois
- Filtre par série
- Couleurs : Rouge = manquant, Vert = téléchargé

---

### Activity Queue

**Activity > Queue**

Téléchargements en cours :
```
Série                        Épisode      Progress  ETA
Breaking Bad                 S05E14       67%       8 min
One Piece                    1050         12%       45 min
```

---

### Wanted

**Wanted > Missing**

Liste épisodes manquants :
```
Série              Saison   Épisode   Date de sortie
Breaking Bad       5        14        Il y a 2 jours
The Walking Dead   11       7         Il y a 1 semaine
```

**Actions :**
- **Search All** : Rechercher tous les manquants
- **Search Selected** : Sélection uniquement

---

### Cutoff Unmet

**Wanted > Cutoff Unmet**

Épisodes téléchargés mais qualité < cible :

```
Série       Épisode  Qualité actuelle  Cible
Lupin       S02E01   HDTV-720p        Bluray-1080p
```

Sonarr upgradé automatiquement si trouve mieux.

---

## Troubleshooting

### ❌ Série ajoutée mais aucun épisode trouvé

**Causes :**

**1. Indexers insuffisants**
- Settings > Indexers
- Besoin d'au moins 2-3 indexers actifs
- EZTV (anglais) + YGGTorrent (français)

**2. Série trop récente**
- Pas encore en torrent
- Attendez quelques heures/jours

**3. Nom incorrect**
- TheTVDB a nom différent du torrent
- Ajoutez Alternate Titles

---

### ❌ Animés non trouvés

**Causes spécifiques animés :**

**1. Series Type ≠ Anime**
- Series > Edit
- Series Type : **Anime** ⚠️

**2. Indexer Nyaa.si manquant**
- Settings > Indexers
- Ajouter Nyaa.si via Prowlarr

**3. Numérot

ation épisodes**
- Animés utilisent souvent numérotation absolue
- Sonarr doit être en mode "Anime" pour comprendre

**4. Nom non reconnu**
- Cherchez avec nom anglais
- Exemple : "Attack on Titan" pas "Shingeki no Kyojin"

---

### ⚠️ Épisodes téléchargés mais pas importés

**Vérifications :**

**1. Catégorie qBittorrent**
- Doit être `series` (ou `anime` si configuré)

**2. Permissions**
```bash
chmod 775 -R /volume1/torrents/complete/series
chmod 775 -R /volume1/media/series
```

**3. Nom fichier**
- Sonarr cherche pattern S01E01
- Si torrent a format bizarre, import échoue

**4. Logs**
- System > Logs > Files
- Chercher "import failed"

---

### 🔴 "Episode file does not exist"

**Cause :** Fichier supprimé ou déplacé manuellement.

**Solution :**
1. Series > Episode
2. **Unmonitor** l'épisode
3. Supprimez l'entrée
4. **Search** à nouveau

---

### ❌ RSS ne fonctionne pas

**Cause :** Indexer RSS désactivé.

**Solution :**
- Settings > Indexers > (votre indexer) > Edit
- ✅ **Enable RSS**
- Settings > Indexers > Options
- **RSS Sync Interval** : 15 minutes

---

### ⚠️ Upgrade ne se fait pas

**Vérifications :**

**1. Profile Upgrade activé**
- Settings > Profiles > HD
- ✅ **Upgrades Allowed**
- **Upgrade Until** : Bluray-1080p

**2. Cutoff Unmet**
- Wanted > Cutoff Unmet
- Épisode doit apparaître ici

**3. Recherche manuelle**
- Episode > Search manuellement
- Vérifiez si meilleure qualité existe

---

## 📊 Configuration recommandée finale

```yaml
# Media Management
Rename Episodes: ✅
Standard Format: {Series Title} - S{season:00}E{episode:00} - {Episode Title} [{Quality Full}]
Season Folders: ✅

# Quality Profiles
HD (séries): Upgrade until Bluray-1080p
Anime HD: Upgrade until Bluray-1080p

# Root Folders
/series (séries classiques)
/anime (animés)

# Indexers
EZTV: ✅ (anglais)
YGGTorrent: ✅ (français)
Nyaa.si: ✅ (animés)

# Download Client
qBittorrent:
  Category: series
  Remove Completed: ❌

# Monitoring
RSS Sync: 15 minutes
Monitor: All Episodes (ou Future Episodes)
```

---

## 📚 Guides connexes

- **[Radarr](03-radarr.md)** — Configuration similaire films
- **[Prowlarr](02-prowlarr.md)** — Gestion indexers
- **[qBittorrent](01-qbittorrent.md)** — Configuration client
- **[Animés complet](../guides/anime-configuration.md)** — Guide détaillé animés

---

**✅ Sonarr est parfaitement configuré !**

Vos séries et animés seront automatiquement surveillés, téléchargés et organisés ! 📺
