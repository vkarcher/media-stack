# 🎭 Guide Complet Overseerr

> Interface de demande média pour vos utilisateurs

**⏱️ Temps estimé :** 20 minutes  
**📊 Niveau :** Débutant  
**🔗 Prérequis :** Plex configuré, Radarr/Sonarr opérationnels

**🔗 Ressources officielles :**
- [GitHub Overseerr](https://github.com/sct/overseerr)
- [Documentation](https://docs.overseerr.dev/)
- [Discord](https://discord.gg/overseerr)

---

## 📖 Table des matières

1. [Qu'est-ce qu'Overseerr ?](#quest-ce-quoverseerr-)
2. [Première connexion](#première-connexion)
3. [Configuration Plex](#configuration-plex)
4. [Ajouter Radarr](#ajouter-radarr)
5. [Ajouter Sonarr](#ajouter-sonarr)
6. [Gérer les utilisateurs](#gérer-les-utilisateurs)
7. [Quotas et permissions](#quotas-et-permissions)
8. [Notifications](#notifications)
9. [Utilisation quotidienne](#utilisation-quotidienne)
10. [Troubleshooting](#troubleshooting)

---

## Qu'est-ce qu'Overseerr ?

**Overseerr** est une **interface web moderne** pour demander des films/séries.

### Pourquoi Overseerr ?

**Sans Overseerr :**
```
Utilisateur : "Je veux voir le film X"
Vous : Ouvrez Radarr, cherchez, ajoutez, etc.
→ Vous devez tout faire manuellement
```

**Avec Overseerr :**
```
Utilisateur : Recherche "Matrix" dans Overseerr
            → Clique "Request"
Overseerr : Envoie automatiquement à Radarr
Radarr : Télécharge automatiquement
Plex : Film disponible automatiquement !
→ Zéro intervention de votre part ✅
```

### Avantages

✅ **Interface moderne** — Style Netflix/IMDb  
✅ **Multi-utilisateurs** — Famille, amis  
✅ **Quotas** — Limite requêtes par utilisateur  
✅ **Notifications** — Discord, Telegram, Email  
✅ **Gestion requêtes** — Approuver/refuser  
✅ **Intégration Plex** — Import utilisateurs automatique

---

## Première connexion

### Accéder à Overseerr

🌐 **URL :** `http://<IP_NAS>:5055`

### Configuration initiale (Assistant)

**Écran 1 : Connexion Plex**

1. Cliquez **"Sign in with Plex"**
2. Connectez-vous avec votre compte Plex
3. **Autoriser** Overseerr

✅ Overseerr va automatiquement :
- Détecter votre serveur Plex
- Importer vos bibliothèques
- Importer vos utilisateurs Plex

---

**Écran 2 : Serveur Plex**

| Paramètre | Valeur |
|-----------|--------|
| **Server** | (Votre serveur Plex détecté automatiquement) |
| **Libraries** | ✅ Movies, ✅ TV Shows, ✅ Anime |

Cochez les bibliothèques que vous voulez synchroniser.

**Scan** → Overseerr va analyser votre bibliothèque Plex.

✅ Next

---

**Écran 3 : Services**

Vous allez ajouter Radarr et Sonarr ici.

(On configure en détail dans les sections suivantes)

Cliquez **"Finish Setup"** pour l'instant.

---

## Configuration Plex

La connexion Plex est déjà faite via l'assistant.

### Vérification

**Settings > Plex**

| Paramètre | Valeur |
|-----------|--------|
| **Server** | Votre serveur Plex |
| **Libraries** | Movies, TV Shows, Anime |
| **Scan Automatically** | ✅ Recommended |
| **Scan Interval** | 6 hours |

✅ Save Changes

---

### Scan manuel

Si vous voulez forcer une synchro :

**Settings > Plex > Manual Library Scan**

Cliquez **"Start Scan"**

→ Overseerr va détecter tous vos films/séries existants.

---

## Ajouter Radarr

**Settings > Services > Radarr**

**Add Radarr Server**

### Configuration

| Paramètre | Valeur | Où le trouver |
|-----------|--------|---------------|
| **Default Server** | ✅ | (si c'est votre seul Radarr) |
| **Server Name** | Radarr | Nom affiché |
| **Hostname or IP** | `<IP_NAS>` | IP de votre NAS |
| **Port** | `7878` | Port Radarr |
| **Use SSL** | ❌ | (sauf si HTTPS configuré) |
| **API Key** | `a1b2c3...` | Radarr > Settings > General > API Key |
| **URL Base** | (vide) | Sauf si reverse proxy |

---

### Sync Options

| Paramètre | Valeur |
|-----------|--------|
| **Quality Profile** | HD | (ou votre profil) |
| **Root Folder** | `/movies` | (doit apparaître dans liste) |
| **Minimum Availability** | Released | Quand télécharger |
| **Tags** | (vide) | Ou custom |
| **External URL** | (vide) | Sauf accès externe |

---

### Test

Cliquez **"Test"** en bas.

✅ "Radarr connection test successful"

Si erreur :
- Vérifiez IP/Port
- Vérifiez API Key (copier-coller exact)
- Radarr est démarré ?

✅ **Save Changes**

---

## Ajouter Sonarr

**Settings > Services > Sonarr**

**Add Sonarr Server**

### Configuration

| Paramètre | Valeur |
|-----------|--------|
| **Default Server** | ✅ |
| **Server Name** | Sonarr |
| **Hostname or IP** | `<IP_NAS>` |
| **Port** | `8989` |
| **API Key** | (Sonarr > Settings > General) |

---

### Sync Options

| Paramètre | Valeur |
|-----------|--------|
| **Quality Profile** | HD |
| **Root Folder** | `/series` |
| **Season Folders** | ✅ |
| **Tags** | (vide) |

---

### Anime Root Folder (si animés activés)

**Enable Anime** : ✅

| Paramètre | Valeur |
|-----------|--------|
| **Anime Quality Profile** | Anime HD |
| **Anime Root Folder** | `/anime` |
| **Anime Season Folders** | ✅ |
| **Anime Tags** | `anime` |

---

### Test & Save

✅ Test → "Sonarr connection test successful"

✅ **Save Changes**

---

## Gérer les utilisateurs

### Importer utilisateurs Plex

**Settings > Users**

**Import Plex Users**

→ Overseerr va automatiquement importer tous vos utilisateurs Plex.

```
Utilisateurs:
  - John Doe (Admin)
  - Jane Smith (User)
  - Bob Martin (User)
```

---

### Permissions par défaut

**Settings > Users > Default Permissions**

Configuration recommandée :

| Permission | Valeur | Explication |
|------------|--------|-------------|
| **Request** | ✅ | Peut demander films/séries |
| **Auto Approve Movie** | ✅ | Films approuvés automatiquement |
| **Auto Approve Series** | ✅ | Séries approuvées automatiquement |
| **Request 4K** | ❌ | (sauf si vous gérez 4K) |
| **Auto Approve 4K** | ❌ | |
| **Advanced Requests** | ❌ | Options avancées cachées |
| **View Requests** | ✅ | Voir leurs propres requêtes |
| **Manage Requests** | ❌ | Gérer requêtes des autres (admin only) |

✅ Save Changes

---

### Quotas

**Settings > Users > Default Permissions > Quotas**

Limiter le nombre de requêtes par utilisateur :

| Quota | Valeur recommandée |
|-------|-------------------|
| **Movie Request Limit** | 10 per week |
| **Series Request Limit** | 5 per week |

✅ Empêche abus (utilisateur qui demande 100 films)

---

### Modifier un utilisateur individuel

**Settings > Users > (utilisateur) > Edit**

Vous pouvez :
- Changer les permissions spécifiques
- Changer les quotas
- Promouvoir en Admin
- Désactiver l'utilisateur

---

## Quotas et permissions

### Niveaux d'accès

**Admin** :
- Tous les droits
- Gère utilisateurs
- Gère settings
- Approuve requêtes

**User** :
- Chercher films/séries
- Faire des requêtes
- Voir ses propres requêtes

**Disabled** :
- Aucun accès

---

### Approval Workflow

**Si Auto Approve = ❌**

```
Utilisateur → Request Matrix
            ↓
Admin → Notifié (email/Discord)
      → Approve ou Deny
            ↓
Si Approve → Radarr télécharge
Si Deny → Requête refusée
```

**Utilisation :** Contrôle strict (quota espace disque, etc.)

---

## Notifications

**Settings > Notifications**

Overseerr peut notifier sur :
- Discord
- Telegram
- Email
- Slack
- Webhook

### Exemple : Discord

**1. Add Discord Agent**

**2. Créez un Webhook Discord**

Sur Discord :
1. Serveur > Paramètres serveur
2. Intégrations > Webhooks
3. Créer un Webhook
4. Copier l'URL

**3. Configuration Overseerr**

| Paramètre | Valeur |
|-----------|--------|
| **Webhook URL** | (collé depuis Discord) |
| **Bot Username** | Overseerr |
| **Bot Avatar URL** | (optionnel) |

**4. Notification Types**

Cochez ce que vous voulez notifier :
- ✅ Media Requested
- ✅ Media Approved
- ✅ Media Available
- ✅ Media Failed
- ❌ Test Notification

✅ Test → Devrait envoyer message Discord

✅ Save Changes

---

## Utilisation quotidienne

### Côté utilisateur

**1. Connexion**

🌐 `http://<IP_NAS>:5055`

→ Sign in with Plex

**2. Recherche**

Barre de recherche : `Matrix`

**3. Résultats**

```
The Matrix (1999)
  - Synopsis
  - Note IMDb
  - Statut : Disponible / Non disponible
```

**4. Demande**

Si pas disponible :
- Cliquez sur le film
- Bouton **"Request"**
- (Optionnel) Choisir profil qualité

✅ Requête envoyée !

**5. Notifications**

L'utilisateur reçoit notifications :
- Requête approuvée
- Téléchargement en cours
- **Film disponible** ✅

---

### Côté admin

**Requests (onglet)**

Liste des requêtes :
```
Requêtes en attente:
  - The Matrix Reloaded (demandé par John)
  - Breaking Bad S01 (demandé par Jane)

Requêtes approuvées:
  - Inception (téléchargement...)
```

**Actions :**
- ✅ Approve
- ❌ Decline
- 🔍 View details

---

## Troubleshooting

### ❌ "Unable to connect to Plex"

**Causes :**

**1. Plex Server pas démarré**
```bash
# Vérifiez Plex
curl http://localhost:32400/web
```

**2. Connexion Plex expirée**
- Settings > Plex
- **Sign Out**
- **Sign in with Plex** à nouveau

**3. Firewall**
- Port 32400 ouvert ?

---

### ❌ "Unable to connect to Radarr/Sonarr"

**Solutions :**

**1. Vérifiez IP/Port**
- Radarr : `http://<IP_NAS>:7878`
- Sonarr : `http://<IP_NAS>:8989`
- Testez dans navigateur

**2. API Key correcte**
- Radarr > Settings > General > API Key
- Copier EXACTEMENT (pas d'espaces)

**3. Test connexion**
- Settings > Services > Radarr/Sonarr
- Bouton **Test**
- Message d'erreur ?

---

### ⚠️ Requêtes approuvées mais pas de téléchargement

**Vérifications :**

**1. Radarr/Sonarr reçoit la requête ?**
- Radarr > Movies (film doit apparaître)
- Sonarr > Series (série doit apparaître)

**2. Radarr/Sonarr cherche ?**
- Radarr > Movie > Activity
- Recherche en cours ?

**3. Indexers configurés ?**
- Radarr > Settings > Indexers
- Au moins 1 indexer actif

---

### ❌ Film déjà dans Plex mais marqué "Unavailable"

**Cause :** Plex scan pas à jour.

**Solution :**
- Settings > Plex > Manual Library Scan
- **Start Scan**
- Attendez 2-3 minutes
- Rafraîchissez Overseerr

---

### ⚠️ Utilisateurs Plex non importés

**Solution :**
- Settings > Users > Import Plex Users
- Cliquez **Import**
- Vérifiez que les utilisateurs ont accès au serveur Plex

---

## 📊 Configuration recommandée finale

```yaml
# Plex
Server: Votre serveur Plex
Libraries: Movies, TV Shows, Anime
Scan: Automatic (6h)

# Radarr
Hostname: <IP_NAS>
Port: 7878
Quality Profile: HD
Root Folder: /movies

# Sonarr
Hostname: <IP_NAS>
Port: 8989
Quality Profile: HD
Root Folder: /series
Anime Root: /anime (si activé)

# Users
Default Permissions: Request + Auto Approve
Quotas: 10 movies/week, 5 series/week

# Notifications
Discord: ✅ (optionnel)
Types: Requested, Approved, Available
```

---

## 📚 Guides connexes

- **[Plex](06-plex.md)** — Configuration serveur média
- **[Radarr](03-radarr.md)** — Gestion films
- **[Sonarr](04-sonarr.md)** — Gestion séries

---

**✅ Overseerr est configuré !**

Vos utilisateurs peuvent maintenant demander films/séries en toute autonomie ! 🎭
