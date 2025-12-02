# 🔍 Guide Complet Prowlarr

> Gestionnaire centralisé d'indexers pour votre stack média

**⏱️ Temps estimé :** 20-25 minutes  
**📊 Niveau :** Intermédiaire  
**🔗 Prérequis :** Prowlarr installé, qBittorrent configuré

---

## 📖 Table des matières

1. [Qu'est-ce que Prowlarr ?](#quest-ce-que-prowlarr-)
2. [Première connexion](#première-connexion)
3. [Ajouter des indexers publics](#ajouter-des-indexers-publics)
4. [Configurer FlareSolverr](#configurer-flaresolverr)
5. [Ajouter YGGTorrent](#ajouter-yggtorrent)
6. [Synchroniser avec Radarr/Sonarr](#synchroniser-avec-radarrsonarr)
7. [Indexers pour animés](#indexers-pour-animés)
8. [Gestion des indexers](#gestion-des-indexers)
9. [Troubleshooting](#troubleshooting)

---

## Qu'est-ce que Prowlarr ?

**Prowlarr** est un **gestionnaire centralisé d'indexers** (trackers torrents et Usenet).

### Pourquoi Prowlarr ?

**Sans Prowlarr :**
```
Radarr → Ajouter 10 indexers manuellement
Sonarr → RE-ajouter les 10 MÊMES indexers
→ 20 configurations à maintenir !
```

**Avec Prowlarr :**
```
Prowlarr → Ajouter 10 indexers UNE FOIS
         ↓
   Synchronisation automatique
         ↓
Radarr + Sonarr reçoivent automatiquement les 10 indexers
→ 1 seule configuration à maintenir !
```

### Avantages

- ✅ **Configuration centralisée** : Ajoutez un indexer une fois
- ✅ **Synchronisation auto** : Radarr/Sonarr mis à jour automatiquement
- ✅ **Recherche globale** : Testez vos indexers facilement
- ✅ **Statistiques** : Voyez quels indexers fonctionnent le mieux
- ✅ **Support FlareSolverr** : Bypass Cloudflare (YGG, etc.)

---

## Première connexion

### Accéder à Prowlarr

🌐 **URL :** `http://<IP_NAS>:9696`

### Configuration initiale

**1. Authentification (recommandée)**

- Settings > General > Security
- **Authentication** : Forms (Login Page)
- **Username** : admin
- **Password** : (choisir un mot de passe fort)
- ✅ Save

**2. Clé API**

Copiez votre **API Key** (vous en aurez besoin pour Radarr/Sonarr) :
- Settings > General > Security
- **API Key** : `a1b2c3d4e5f6...` (longue chaîne)
- 📋 Copiez-la dans un fichier texte

---

## Ajouter des indexers publics

### Indexers recommandés (publics, sans compte)

**Pour Films/Séries :**
- **YTS** (films de qualité, petits fichiers)
- **EZTV** (séries TV en anglais)
- **The Pirate Bay** (très complet mais instable)
- **1337x** (bon équilibre qualité/quantité)

**Pour Animés :**
- **Nyaa.si** (meilleur pour animés)
- **AnimeTosho** (agrégateur animés)

---

### Ajouter un indexer public

**1. Indexers > Add Indexer**

**2. Recherchez "YTS"**

Dans la barre de recherche, tapez `YTS`.

**3. Cliquez sur "YTS"**

**4. Configuration YTS**

| Paramètre | Valeur | Explication |
|-----------|--------|-------------|
| **Name** | YTS | Nom affiché |
| **Enable** | ✅ Yes | Activer l'indexer |
| **Redirect** | ❌ No | Pas de redirection |
| **Priority** | 25 | Priorité moyenne (1-50) |
| **Tags** | (vide) | Pas de tag nécessaire |
| **Minimum Seeders** | 1 | Évite torrents morts |
| **Seed Ratio** | (vide) | Trackers publics = pas de ratio |

**5. Categories**

Cochez au minimum :
- ✅ Movies
- ✅ Movies/Foreign
- ✅ Movies/HD
- ✅ Movies/UHD

**6. Test & Save**

- Cliquez **Test**
- Devrait afficher : ✅ "All checks have passed"
- **Save**

---

### Répétez pour d'autres indexers

**EZTV :**
```yaml
Name: EZTV
Categories: TV, TV/HD
Priority: 25
```

**Nyaa.si (animés) :**
```yaml
Name: Nyaa
Categories: TV/Anime
Priority: 30
```

---

## Configurer FlareSolverr

FlareSolverr est **obligatoire** pour YGGTorrent et autres sites protégés par Cloudflare.

**→ Voir [Guide FlareSolverr complet](07-flaresolverr.md) pour l'installation**

### Configuration dans Prowlarr

**1. Settings > Indexers**

**2. Section "FlareSolverr"**

| Paramètre | Valeur |
|-----------|--------|
| **Tags** | `flaresolverr` |
| **Host** | `http://flaresolverr:8191/` |
| **Max Timeout** | `60` secondes |

**3. Créer le tag**

Si le tag `flaresolverr` n'existe pas :
- Settings > Tags
- Add Tag : `flaresolverr`
- Save

**4. Test**

- Cliquez **Test** dans la section FlareSolverr
- ✅ "Connection successful"
- Save Settings

---

## Ajouter YGGTorrent

**→ Voir [Guide YGGTorrent Setup complet](../guides/yggtorrent-setup.md)**

### Résumé rapide

**1. Indexers > Add Indexer > "YGGTorrent"**

**2. Configuration**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | YGGTorrent |
| **Enable** | ✅ |
| **Priority** | 50 (haute priorité) |
| **Tags** | `flaresolverr` ⚠️ **IMPORTANT** |
| **Username** | Votre login YGG |
| **Password** | Votre mot de passe YGG |
| **Passkey** | Votre Passkey YGG ([comment l'obtenir](../guides/yggtorrent-setup.md#étape-3--récupérer-votre-passkey-ygg)) |
| **Multi Languages** | ✅ |
| **Categories** | Movies, TV, TV/Anime |

**3. Test & Save**

✅ Si FlareSolverr est bien configuré, le test devrait passer.

---

## Synchroniser avec Radarr/Sonarr

Prowlarr va **automatiquement** pousser vos indexers vers Radarr et Sonarr.

### Ajouter Radarr

**1. Settings > Apps > Add Application**

**2. Sélectionnez "Radarr"**

**3. Configuration**

| Paramètre | Valeur | Où le trouver |
|-----------|--------|---------------|
| **Prowlarr Server** | `http://prowlarr:9696` | (auto) |
| **Radarr Server** | `http://radarr:7878` | (utiliser DNS Docker) |
| **API Key** | `...` | Radarr > Settings > General > API Key |
| **Sync Level** | Add and Remove Only | Prowlarr gère tout |

**4. Test & Save**

- **Test** : ✅ "Connection successful"
- **Save**

---

### Ajouter Sonarr

**Même procédure que Radarr :**

| Paramètre | Valeur |
|-----------|--------|
| **Sonarr Server** | `http://sonarr:8989` |
| **API Key** | (Sonarr > Settings > General) |

---

### Vérification

**1. Allez dans Radarr**

🌐 `http://<IP_NAS>:7878`

- Settings > Indexers
- **Tous vos indexers Prowlarr** devraient apparaître !
  - YTS
  - EZTV
  - YGGTorrent
  - etc.

**2. Testez dans Radarr**

- Movies > Add New Movie
- Recherchez un film : "Matrix"
- **Search**
- Vous devriez voir des résultats de **tous les indexers**

✅ Si vous voyez des résultats, la synchronisation fonctionne !

---

## Indexers pour animés

### Meilleurs indexers animés

**Publics (gratuits) :**
1. **Nyaa.si** — Le meilleur pour animés (japonais/anglais)
2. **SubsPlease** — Releases rapides VOSTFR
3. **AnimeTosho** — Agrégateur multi-sources
4. **HorribleSubs** — Encode qualité (si encore actif)

**Privés (nécessitent compte) :**
1. **AnimeBytes** (excellent mais difficile d'accès)
2. **BakaBT** (qualité premium)

---

### Configuration Nyaa.si

**1. Add Indexer > "Nyaa"**

**2. Configuration**

| Paramètre | Valeur |
|-----------|--------|
| **Name** | Nyaa |
| **Enable** | ✅ |
| **Priority** | 30 |
| **Tags** | `anime` (optionnel) |
| **Filter** | No Filter (tout) |
| **Categories** | ✅ Anime, Anime - English-translated |

**3. Save**

---

### Synchronisation avec Sonarr

Sonarr recevra automatiquement Nyaa.si via Prowlarr.

**Dans Sonarr :**
- Settings > Indexers
- **Nyaa** devrait apparaître
- Utilisez-le pour vos séries animées

---

## Gestion des indexers

### Voir les statistiques

**1. Indexers (page principale)**

Vous verrez pour chaque indexer :
- **Status** : 🟢 Actif / 🔴 Erreur
- **Queries** : Nombre de recherches
- **Grabs** : Nombre de téléchargements
- **Average Response Time** : Vitesse moyenne

---

### Désactiver un indexer

**Clic droit** sur l'indexer > **Disable**

Utile si :
- Indexer trop lent
- Trop de faux positifs
- Tracker down temporairement

---

### Priorités

**Priority** (1-50) détermine l'ordre de recherche :
- **50** : Très haute priorité (YGGTorrent, trackers privés)
- **25** : Priorité moyenne (trackers publics)
- **10** : Basse priorité (backup)

**Radarr/Sonarr** interrogent d'abord les indexers avec priorité haute.

---

### Tags

Les **tags** permettent de :
- Grouper des indexers (ex: `french`, `anime`, `4k`)
- Assigner des indexers spécifiques à certains films/séries

**Exemple :**
```yaml
Tag "french":
  - YGGTorrent
  - Sharewood
  
Dans Radarr → Film français → Tag "french"
→ Radarr utilisera uniquement YGG + Sharewood
```

---

## Troubleshooting

### ❌ Indexer en erreur (🔴)

**Clic sur l'indexer** > Voir le message d'erreur.

**Erreurs courantes :**

**1. "Connection timed out"**
- **Cause** : Indexer down ou trop lent
- **Solution** : Désactivez temporairement, réessayez plus tard

**2. "Authentication failed"**
- **Cause** : Login/password/Passkey incorrect
- **Solution** : Re-vérifiez vos identifiants

**3. "Cloudflare challenge failed"**
- **Cause** : FlareSolverr pas configuré ou tag manquant
- **Solution** : [Voir guide FlareSolverr](07-flaresolverr.md)

---

### ❌ Aucun résultat dans Radarr/Sonarr

**Causes possibles :**

**1. Synchronisation Prowlarr pas faite**
- Prowlarr > Settings > Apps > Radarr/Sonarr
- Cliquez **"Sync App Indexers"** (forcer sync)

**2. Indexers désactivés**
- Prowlarr > Indexers
- Vérifiez que vos indexers sont 🟢 actifs

**3. Catégories mal configurées**
- Indexer > Edit > Categories
- Movies/TV bien cochées ?

---

### ⚠️ "Too many requests" (rate limit)

**Cause** : Trop de recherches en peu de temps.

**Solutions :**

1. **Augmentez l'intervalle de recherche** :
   - Radarr/Sonarr > Settings > Indexers
   - RSS Sync Interval : `30` minutes (au lieu de 15)

2. **Désactivez l'indexer temporairement**
   - Attendez 10-15 minutes
   - Réactivez

---

### ❌ Prowlarr ne se synchronise pas avec Radarr/Sonarr

**Solutions :**

**1. Vérifier la connexion**
- Settings > Apps > Radarr > Test
- Doit être ✅ vert

**2. Vérifier l'API Key**
- Radarr > Settings > General > API Key
- Copier exactement (sans espaces)

**3. Forcer la synchronisation**
- Settings > Apps > Radarr
- Bouton **"Sync App Indexers"**

**4. Redémarrer Prowlarr**
```bash
docker-compose restart prowlarr
```

---

## 📊 Configuration recommandée finale

### Indexers essentiels

**Pour contenu français :**
```yaml
✅ YGGTorrent (Priority: 50, Tag: flaresolverr)
✅ Sharewood (Priority: 40, Tag: flaresolverr) (si accès)
```

**Pour contenu anglais :**
```yaml
✅ YTS (Priority: 25)
✅ EZTV (Priority: 25)
✅ 1337x (Priority: 20)
```

**Pour animés :**
```yaml
✅ Nyaa.si (Priority: 30)
✅ SubsPlease (Priority: 25)
```

### Apps synchronisées

```yaml
✅ Radarr (http://radarr:7878)
✅ Sonarr (http://sonarr:8989)
```

### FlareSolverr

```yaml
✅ Configuré (http://flaresolverr:8191/)
✅ Tag: flaresolverr
✅ Timeout: 60s
```

---

## 📚 Guides connexes

- **[YGGTorrent Setup](../guides/yggtorrent-setup.md)** — Installation complète YGG
- **[FlareSolverr](07-flaresolverr.md)** — Bypass Cloudflare
- **[qBittorrent](01-qbittorrent.md)** — Configuration client torrent
- **[Radarr](03-radarr.md)** — Utilisation des indexers
- **[Sonarr](04-sonarr.md)** — Utilisation des indexers

---

**✅ Prowlarr est maintenant configuré !**

Tous vos indexers sont synchronisés avec Radarr et Sonarr. Les recherches sont automatisées !
