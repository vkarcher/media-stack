# 🎌 Configuration Complète Animés

> Guide exhaustif pour télécharger et organiser vos animés avec Sonarr

**⏱️ Temps estimé :** 25 minutes  
**📊 Niveau :** Intermédiaire  
**🔗 Prérequis :** Sonarr installé, Prowlarr configuré

---

## 📖 Table des matières

1. [Pourquoi un seul Sonarr suffit](#pourquoi-un-seul-sonarr-suffit)
2. [Configuration Sonarr pour animés](#configuration-sonarr-pour-animés)
3. [Indexers spécialisés animés](#indexers-spécialisés-animés)
4. [Ajouter un animé](#ajouter-un-animé)
5. [Problèmes courants](#problèmes-courants)
6. [Optimisations](#optimisations)
7. [FAQ](#faq)

---

## Pourquoi un seul Sonarr suffit

### Architecture recommandée

```
UN SEUL Sonarr
├─ /series (séries classiques)
└─ /anime (animés)

→ 1 conteneur Docker
→ Configuration centralisée
→ Ressources optimisées
→ Simple et efficace
```

### Comment Sonarr différencie séries et animés ?

**Sonarr utilise plusieurs mécanismes :**

1. **Dossiers racines** : `/series` vs `/anime`
2. **Series Type** : "Standard" vs "Anime"
3. **Tags** : `anime` pour filtrer
4. **Profils qualité** : "HD" vs "Anime HD"

---

## Configuration Sonarr pour animés

### Étape 1 : Créer dossier racine `/anime`

**Sonarr > Settings > Media Management > Root Folders**

1. Cliquez **Add Root Folder**
2. Path : `/anime`
3. ✅ Save

**Résultat :**
```
Root Folders:
  • /series (séries classiques)
  • /anime (animés)
```

---

### Étape 2 : Créer profil qualité "Anime HD"

**Settings > Profiles > Add**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | Anime HD |
| **Upgrades Allowed** | ✅ Yes |
| **Upgrade Until** | Bluray-1080p |

**Qualities (ordre de préférence) :**
```
Bluray-1080p      ✅
WEB-DL-1080p      ✅
HDTV-1080p        ✅
Bluray-720p       ✅
WEB-DL-720p       ✅
```

**Pourquoi un profil dédié ?**
- Encodages animés différents (H.264/H.265)
- Souvent en 720p/1080p (rarement 4K)
- Permet règles upgrade spécifiques

---

### Étape 3 : Créer tag "anime"

**Settings > Tags > Add Tag**

```
Tag Label: anime
```

**Utilité du tag :**
- Filtrer facilement vos animés
- Assigner indexers spécifiques (Nyaa.si)
- Règles automatiques (notifications, etc.)

---

### Étape 4 : Format de nommage spécial

**Settings > Media Management**

**Anime Episode Format :**
```
{Series Title} - S{season:00}E{episode:00} - {absolute:000} - {Episode Title} [{Quality Full}]
```

**Résultat :**
```
One Piece - S01E1050 - 1050 - Title [WEB-DL-1080p].mkv
```

**Pourquoi `{absolute:000}` ?**
- Animés utilisent numérotation absolue (1, 2, 3...)
- Pas toujours S01E01 comme séries américaines
- Permet meilleure organisation

---

## Indexers spécialisés animés

### Les meilleurs indexers pour animés

#### 1. **Nyaa.si** (⭐⭐⭐⭐⭐ ESSENTIEL)

**Type :** Public, gratuit  
**Contenu :** Animés japonais VOSTFR/VO  
**Qualité :** Excellente

**Ajouter dans Prowlarr :**

Settings > Indexers > Add Indexer > "Nyaa"

| Paramètre | Valeur |
|-----------|--------|
| **Name** | Nyaa |
| **Enable** | ✅ |
| **Priority** | 30 (haute) |
| **Tags** | `anime` |
| **Categories** | ✅ TV/Anime |

✅ Test & Save

---

#### 2. **SubsPlease** (⭐⭐⭐⭐)

**Type :** Public  
**Contenu :** Releases rapides VOSTFR  
**Qualité :** Bonne

**Ajouter dans Prowlarr :**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | SubsPlease |
| **Categories** | TV/Anime |
| **Priority** | 25 |

---

#### 3. **AnimeTosho** (⭐⭐⭐)

**Type :** Public (agrégateur)  
**Contenu :** Multi-sources  

---

#### 4. **YGGTorrent** (⭐⭐⭐⭐ pour français)

Si vous avez YGG configuré, il a aussi des animés VF/VOSTFR !

**Categories dans YGG :**
- ✅ TV/Anime

---

### Configuration indexers dans Sonarr

Si Prowlarr sync automatique :
- Sonarr > Settings > Indexers
- Nyaa.si, SubsPlease devraient apparaître automatiquement

**Vérification :**
- Settings > Indexers
- Au moins **Nyaa.si** doit être présent ✅

---

## Ajouter un animé

### Méthode complète

**1. Sonarr > Series > Add New Series**

**2. Recherchez l'animé**

⚠️ **Important :** Utilisez le **nom anglais** !

```
✅ "Attack on Titan"
✅ "Demon Slayer"
❌ "進撃の巨人" (kanji)
❌ "Shingeki no Kyojin" (parfois ne fonctionne pas)
```

**3. Sélectionnez la série**

Cliquez sur "Attack on Titan (2013)"

**4. Configuration SPÉCIFIQUE animés**

| Paramètre | Valeur | ⚠️ Important |
|-----------|--------|-------------|
| **Root Folder** | `/anime` | ⚠️ PAS /series |
| **Monitor** | All Episodes | Ou Future Episodes |
| **Quality Profile** | Anime HD | Profil créé précédemment |
| **Series Type** | **Anime** | ⚠️ ESSENTIEL |
| **Season Folder** | ✅ Yes | |
| **Tags** | `anime` | Pour filtrage |

**5. Options de recherche**

- ✅ **Search for missing episodes**
- ✅ **Search for cutoff unmet episodes**

**6. Add Series**

→ Sonarr va :
1. Créer `/anime/Attack on Titan/`
2. Rechercher sur Nyaa.si
3. Télécharger automatiquement

---

### Series Type : Anime vs Standard

**Différences importantes :**

| Aspect | Standard | Anime |
|--------|----------|-------|
| **Numérotation** | S01E01 | Absolue (1, 2, 3...) |
| **Format fichier** | S01E01 | Numéro absolu inclus |
| **Metadata** | TheTVDB | TheTVDB + AniDB |
| **Saisons** | Par année/arc | Parfois condensées |

**→ Series Type = Anime améliore drastiquement la reconnaissance !**

---

## Problèmes courants

### ❌ Animé non trouvé

**Causes :**

**1. Nom incorrect**
- ❌ Nom japonais (kanji/romaji)
- ✅ Nom anglais

**Exemples :**
```
進撃の巨人 → Attack on Titan
鬼滅の刃 → Demon Slayer
僕のヒーローアカデミア → My Hero Academia
```

**2. Series Type ≠ Anime**
- Sonarr > Series > Edit
- Series Type : **Anime** ⚠️

**3. Indexer Nyaa.si manquant**
- Settings > Indexers
- Ajouter Nyaa.si via Prowlarr

---

### ⚠️ Épisodes mal nommés/organisés

**Cause :** Format de nommage incorrect.

**Solution :**

Settings > Media Management

**Anime Episode Format :**
```
{Series Title} - S{season:00}E{episode:00} - {absolute:000} - {Episode Title} [{Quality Full}]
```

**Résultat attendu :**
```
One Piece/
  └─ Season 01/
      ├─ One Piece - S01E1048 - 1048 - Title [WEB-DL-1080p].mkv
      ├─ One Piece - S01E1049 - 1049 - Title [WEB-DL-1080p].mkv
```

---

### 🔴 TheTVDB ne reconnaît pas l'animé

**Cause :** Nom différent sur TheTVDB.

**Solutions :**

**1. Recherche manuelle avec ID**

Add New Series > Search : `tvdb:12345` ou `anidb:6789`

**2. Alternate Titles**

Series > Edit > Alternate Titles
Ajouter versions :
- Nom romaji
- Nom anglais alt
- Nom japonais

**3. Utiliser AniDB**

Certains animés sont mieux sur AniDB que TheTVDB.

---

### ❌ Numérotation absolue incorrecte

**Problème :** One Piece Épisode 1050 → détecté comme S01E50

**Cause :** Series Type pas en "Anime"

**Solution :**
1. Series > Edit
2. **Series Type** : Anime
3. **Episode Ordering** : Absolute (if available)
4. Save

---

### ⚠️ Saisons (cour) mal gérées

**Problème animé japonais :** Séries par cour (12-13 épisodes)

**Exemple :** "My Hero Academia"
- Japon : Saison 1 (cour 1) = 13 épisodes
- TheTVDB : Season 1 = 13 épisodes

**Généralement OK**, mais parfois :
- TheTVDB regroupe 2 cours en 1 saison
- Ou sépare autrement

**Solution :** Vérifiez TheTVDB manuellement et ajustez monitoring

---

## Optimisations

### 1. Recherche préférentielle Nyaa.si

**Settings > Indexers > Nyaa > Edit**

```yaml
Priority: 50 (très haute)
```

→ Sonarr cherchera d'abord sur Nyaa pour les animés

---

### 2. Profil qualité optimisé

**Pour animés, 720p suffit souvent :**

Settings > Profiles > Anime HD

**Upgrade Until :** Bluray-720p (au lieu de 1080p)

**Avantages :**
- Taille fichiers réduite
- Qualité excellente (encodage anime optimisé)
- Téléchargements plus rapides

---

### 3. Tags pour automation

**Utilisez tags pour :**

**Notifications Discord spéciales animés :**
```yaml
Tag: anime
→ Webhook Discord #anime
```

**Indexers dédiés :**
```yaml
Series avec tag "anime" → Cherche seulement Nyaa.si + SubsPlease
Series sans tag → Cherche tous indexers
```

---

### 4. Calendar filtering

**Calendar > Filter by Tag : anime**

→ Voir seulement sorties animés

---

## FAQ

<details>
<summary><strong>Dois-je vraiment mettre Series Type = Anime ?</strong></summary>

**OUI, c'est ESSENTIEL !**

Sans Series Type = Anime :
- ❌ Numérotation absolue ignorée
- ❌ Mauvaise reconnaissance épisodes
- ❌ Import échoue souvent

Avec Series Type = Anime :
- ✅ Numérotation absolue activée
- ✅ Format fichier correct
- ✅ Metadata optimisées
</details>

<details>
<summary><strong>Pourquoi Nyaa.si ne trouve rien pour un animé récent ?</strong></summary>

**Causes possibles :**

1. **Animé trop récent** (sortie < 1h)
   - Attendez quelques heures

2. **Nom de recherche incorrect**
   - Vérifiez nom anglais exact

3. **Fansub pas encore sorti**
   - SubsPlease, HorribleSubs ont délais variables

4. **Animé non populaire**
   - Peu de fansubs le traitent
   - Essayez d'autres indexers
</details>

<details>
<summary><strong>Quelle différence entre VOSTFR et VF ?</strong></summary>

**VOSTFR :** Version Originale Sous-Titrée Français
- Audio japonais
- Sous-titres français
- **Disponible rapidement** (quelques heures après diffusion Japon)

**VF :** Version Française (doublée)
- Audio français
- **Délai important** (plusieurs mois/années)
- Moins disponible en torrent

**Recommandation :** VOSTFR pour nouveautés
</details>

<details>
<summary><strong>Animés longs (One Piece, Naruto) : comment gérer ?</strong></summary>

**Problème :** 1000+ épisodes = téléchargement massif

**Solutions :**

1. **Monitor : Latest Season**
   - Télécharge seulement nouveaux épisodes
   - Pas les anciens

2. **Monitor : Missing Episodes (manuel)**
   - Sélectionnez manuellement épisodes voulus

3. **Unmonitor les saisons anciennes**
   - Series > Seasons
   - Décochez saisons 1-20 (par exemple)
</details>

<details>
<summary><strong>Peut-on mélanger séries et animés dans /series ?</strong></summary>

**Techniquement oui**, mais **pas recommandé** :

❌ **Désavantages :**
- Organisation confuse
- Difficile de filtrer
- Tags obligatoires partout

✅ **Avec `/anime` séparé :**
- Organisation claire
- Filtrage facile
- Profils dédiés

**Gardez `/series` et `/anime` séparés !**
</details>

---

## 📊 Configuration recommandée finale

```yaml
# Sonarr Settings
Root Folders:
  - /series (séries classiques)
  - /anime (animés)

Profiles:
  - HD (séries) : Upgrade to Bluray-1080p
  - Anime HD : Upgrade to Bluray-720p

Tags:
  - anime

# Indexers (via Prowlarr)
Nyaa.si: Priority 50, Tag anime
SubsPlease: Priority 30, Tag anime
YGGTorrent: Priority 40 (si VF/VOSTFR français)

# Naming
Anime Episode Format:
{Series Title} - S{season:00}E{episode:00} - {absolute:000} - {Episode Title} [{Quality Full}]
```

---

## 📚 Guides connexes

- **[Sonarr complet](../apps/04-sonarr.md)** — Configuration générale
- **[Prowlarr](../apps/02-prowlarr.md)** — Ajouter Nyaa.si
- **[YGGTorrent Setup](yggtorrent-setup.md)** — Si VF/VOSTFR français

---

**✅ Configuration animés complète !**

Vos animés seront automatiquement téléchargés et organisés ! 🎌
