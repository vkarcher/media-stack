# ⚙️ Guide Complet qBittorrent

> Configuration complète de qBittorrent pour votre stack média automatisée

**⏱️ Temps estimé :** 15-20 minutes  
**📊 Niveau :** Débutant → Avancé  
**🔗 Prérequis :** qBittorrent installé via setup.sh

---

## 📖 Table des matières

1. [Première connexion](#première-connexion)
2. [Configuration de base](#configuration-de-base)
3. [Création des catégories](#création-des-catégories)
4. [Configuration pour YGGTorrent](#configuration-pour-yggtorrent)
5. [Limitation de bande passante](#limitation-de-bande-passante)
6. [Configuration VPN](#configuration-vpn)
7. [Options avancées](#options-avancées)
8. [Troubleshooting](#troubleshooting)

---

## Première connexion

### Accéder à qBittorrent

🌐 **URL :** `http://<IP_NAS>:8080`

### Identifiants par défaut

```
Username: admin
Password: adminadmin
```

⚠️ **IMPORTANT** : Changez ce mot de passe immédiatement !

---

## Configuration de base

### 1. Changer le mot de passe

**Outils > Options > Web UI > Authentification**

| Paramètre | Valeur recommandée |
|-----------|-------------------|
| Username | `admin` (ou changez) |
| Password | **Mot de passe fort** |

✅ Cliquez sur **Save**

---

### 2. Interface en français

**Tools > Options > Behavior > Language**

- Sélectionnez : **Français**
- Redémarrez qBittorrent (docker-compose restart qbittorrent)

---

### 3. Dossiers de téléchargement

**Options > Téléchargements**

| Paramètre | Valeur |
|-----------|--------|
| **Enregistrer les fichiers dans** | `/torrents/incomplete` |
| **Conserver les torrents incomplets dans** | `/torrents/incomplete` |
| **Déplacer lorsque la catégorie change** | ✅ Activé |
| **Déplacer les .torrent terminés vers** | ❌ Désactivé |
| **Copier les .torrent terminés vers** | ❌ Désactivé |

✅ Save

---

## Création des catégories

Les catégories permettent à Radarr/Sonarr de ranger automatiquement les fichiers.

### Catégorie "movies"

1. **Clic droit** dans la zone "Catégories" (colonne gauche)
2. **Ajouter une catégorie**

| Paramètre | Valeur |
|-----------|--------|
| **Nom** | `movies` |
| **Chemin de sauvegarde** | `/torrents/complete/movies` |

3. ✅ **OK**

---

### Catégorie "series"

Même procédure :

| Paramètre | Valeur |
|-----------|--------|
| **Nom** | `series` |
| **Chemin de sauvegarde** | `/torrents/complete/series` |

---

### Catégorie "anime" (optionnel)

Si vous avez activé le support animés :

| Paramètre | Valeur |
|-----------|--------|
| **Nom** | `anime` |
| **Chemin de sauvegarde** | `/torrents/complete/anime` |

---

### Résultat attendu

Vous devriez voir 3 catégories dans la sidebar :
```
Catégories
├─ movies
├─ series
└─ anime
```

---

## Configuration pour YGGTorrent

Vous devez configurer qBittorrent selon le [profil YGG choisi](../guides/yggtorrent-profiles.md).

### 🟢 Configuration "Profil Légit"

**Options > BitTorrent**

**Seeding Limits** :
```yaml
☑ When ratio reaches: 2.0
  Then: Pause torrent

☐ When seeding time reaches: (désactivé)

☐ When inactive seeding time reaches: (désactivé)
```

**Explanation** :
- Ratio 2.0 = Upload 2x ce que vous téléchargez
- Pause (pas supprimer) = Évite Hit & Run YGG
- Temps illimité = Seedez aussi longtemps que possible

---

### 🟡 Configuration "Profil Équilibré"

**Options > BitTorrent**

**Seeding Limits** :
```yaml
☑ When ratio reaches: 0.6
  OR
☑ When seeding time reaches: 4320 minutes (3 jours)
  Then: Pause torrent

Whichever comes first
```

**Explanation** :
- Ratio 0.6 = Au-dessus du minimum YGG (0.5)
- 3 jours = Règle anti-Hit & Run YGG
- Pause = Respecte les règles YGG

---

### 🔴 Configuration "Profil Risqué" (non recommandé)

⚠️ **AVERTISSEMENT** : Risque de ban YGG élevé !

**Options > BitTorrent**

**Seeding Limits** :
```yaml
☑ When ratio reaches: 0.1
  OR
☑ When seeding time reaches: 1440 minutes (1 jour)
  Then: Remove torrent (⚠️)

Whichever comes first
```

**→ Voir [Guide Profils YGG](../guides/yggtorrent-profiles.md) pour tous les détails**

---

## Limitation de bande passante

### Limiter l'upload global

**Options > Vitesse**

| Profil | Upload Limit | Explication |
|--------|--------------|-------------|
| 🟢 Légit | `Unlimited` | Maximum de contribution |
| 🟡 Équilibré | `1 MB/s` | Économie bande passante |
| 🔴 Risqué | `50 KB/s` | Upload minimal |

---

### Limiter le download global

**Options > Vitesse > Global Rate Limits**

```yaml
Download Rate Limit: (selon votre connexion)
  - Fibre: Unlimited
  - ADSL: 5-10 MB/s
  - 4G/5G: 2-5 MB/s
```

---

### Scheduler (horaires)

**Options > Vitesse > Alternative Rate Limits**

Exemples d'utilisation :
- Nuit (22h-8h) : Upload illimité
- Journée (8h-22h) : Upload limité à 500 KB/s

```yaml
☑ Alternative Rate Limits

Upload: 500 KB/s (journée)
         Unlimited (nuit)

Schedule:
  - Lundi-Dimanche: 08:00-22:00 → Limited
  - Lundi-Dimanche: 22:00-08:00 → Unlimited
```

---

## Configuration VPN

### Vérifier que qBittorrent utilise le VPN

Si vous avez installé WireGuard :

**1. Options > Advanced > Network Interface**

```yaml
Network Interface: wg0 (WireGuard)
```

Si vous voyez `wg0` dans la liste, le VPN fonctionne ! ✅

---

**2. Test d'IP**

- Allez sur **https://ipleak.net**
- Comparez l'IP affichée avec votre IP réelle
- Si différente → ✅ VPN actif

---

**3. Forcer l'interface (sécurité)**

**Options > Advanced**

```yaml
☑ Network Interface: wg0

☑ Bind to IP address: (IP du VPN)
```

Ceci force qBittorrent à utiliser **uniquement** le VPN.

Si le VPN tombe → qBittorrent arrête de télécharger (sécurité).

---

## Options avancées

### Connexions

**Options > Connection**

```yaml
Port utilisé pour les connexions entrantes: 6881
☑ Utiliser UPnP / NAT-PMP pour le routeur

Nombre maximum de connexions globales: 500
Nombre maximum par torrent: 100

Nombre d'emplacements d'upload globaux: 50
Nombre par torrent: 5
```

---

### Anonymat et confidentialité

**Options > BitTorrent > Privacy**

```yaml
☑ Enable DHT (pour les torrents publics)
☑ Enable PeX (échange de peers)
☑ Enable Local Peer Discovery

☐ Enable anonymous mode (déconseillé, casse les trackers privés)
```

**Pour YGGTorrent** : Gardez DHT/PeX **activés**.

---

### Queueing

**Options > BitTorrent > Torrent Queueing**

```yaml
☑ Maximum active downloads: 5
☑ Maximum active uploads: 10
☑ Maximum active torrents: 15

☑ Do not count slow torrents in these limits
```

Adaptez selon les capacités de votre NAS.

---

## Troubleshooting

### ❌ "Connexion refusée" sur port 8080

**Cause** : qBittorrent pas démarré ou port incorrect.

**Solutions** :

1. **Vérifier que le container tourne** :
   ```bash
   docker ps | grep qbittorrent
   ```

2. **Redémarrer qBittorrent** :
   ```bash
   cd /volume1/docker
   docker-compose restart qbittorrent
   ```

3. **Vérifier les logs** :
   ```bash
   docker-compose logs qbittorrent
   ```

---

### ❌ Téléchargements ne démarrent pas

**Causes possibles** :

1. **Catégorie mal configurée**
   - Vérifiez `/torrents/complete/movies` existe
   - Permissions : `chmod 775 -R /volume1/torrents`

2. **Radarr/Sonarr non connecté**
   - Radarr > Settings > Download Clients > Test
   - Doit être vert ✅

3. **Firewall bloque** :
   - Port 6881 ouvert dans Freebox ?
   - Voir [FREEBOX_SETUP.md](../../FREEBOX_SETUP.md)

---

### ⚠️ Upload très lent

**Causes** :

1. **Upload Rate Limit** trop bas
   - Options > Vitesse > Upload: augmentez

2. **Seeders insuffisants**
   - Torrent mort ou peu populaire
   - Normal, pas d'inquiétude

3. **VPN lent** :
   - Changez de serveur VPN
   - Désactivez temporairement pour tester

---

### ❌ "Stalled" sur tous les torrents

**Cause** : Pas de peers/seeders ou connexion bloquée.

**Solutions** :

1. **Test connexion** :
   - Téléchargez un torrent public Ubuntu
   - Si ça fonctionne → Problème du tracker

2. **DHT/PeX activés** :
   - Options > BitTorrent > Privacy
   - ✅ Enable DHT + PeX

3. **Port forwarding** :
   - Freebox > Rediriger port 6881 vers NAS

---

### 🔴 Hit & Run détectés sur YGG

**Cause** : Torrents supprimés avant ratio 1.0 ou 3 jours.

**Solutions** :

1. **Changer configuration** :
   - Then: **Pause torrent** (pas Remove)
   - [Profils YGG](../guides/yggtorrent-profiles.md)

2. **Seedez plus longtemps** :
   - When seeding time: 4320 min (3 jours minimum)

3. **Vérifiez votre ratio YGG** :
   - http://yggtorrent.top > Mon compte

---

## 📊 Résumé configuration recommandée

### Pour 99% des utilisateurs

```yaml
# Dossiers
Enregistrer dans: /torrents/incomplete
Catégories: movies, series, anime

# Seeding (Profil Équilibré)
Ratio: 0.6 OR Seed time: 3 jours
Then: Pause torrent

# Vitesse
Upload: 1 MB/s (ou Unlimited si fibre)
Download: Unlimited

# Connexions
Max connections: 500
Max uploads: 50

# Sécurité
VPN: WireGuard (si installé)
Interface: wg0
```

---

## 📚 Guides connexes

- **[Profils YGGTorrent](../guides/yggtorrent-profiles.md)** — 3 configurations détaillées
- **[VPN Setup](../guides/vpn-setup.md)** — WireGuard pour sécuriser
- **[Radarr](03-radarr.md)** — Connexion avec qBittorrent
- **[Sonarr](04-sonarr.md)** — Connexion avec qBittorrent

---

**✅ Votre qBittorrent est maintenant configuré !**

Prochaine étape : [Configurer Prowlarr](02-prowlarr.md) pour ajouter YGGTorrent
