# 🔐 Configuration VPN (WireGuard)

> Sécuriser vos téléchargements avec WireGuard

**⏱️ Temps estimé :** 20-25 minutes  
**📊 Niveau :** Intermédiaire  
**🔗 Prérequis :** qBittorrent installé, connaissances VPN basiques

---

## 📖 Table des matières

1. [Pourquoi un VPN ?](#pourquoi-un-vpn-)
2. [WireGuard vs autres VPN](#wireguard-vs-autres-vpn)
3. [Installation WireGuard](#installation-wireguard)
4. [Configuration qBittorrent](#configuration-qbittorrent)
5. [Tests et vérification](#tests-et-vérification)
6. [Kill Switch](#kill-switch)
7. [Troubleshooting](#troubleshooting)

---

## Pourquoi un VPN ?

### Risques sans VPN

**Votre FAI (Freebox, SFR, Orange...) voit :**
- ✅ Tous vos téléchargements torrent
- ✅ Adresses IP des trackers
- ✅ Contenu téléchargé (metadata)

**Conséquences possibles :**
- 🚨 **HADOPI** (France) — Avertissements + amendes
- ⚠️ **Limitation bande passante** (throttling P2P)
- 📧 **Emails d'avertissement** de votre FAI

---

### Avec VPN

```
Vous → VPN WireGuard → Tracker/Peers
       (IP masquée)
```

**Avantages :**
- ✅ **IP masquée** — FAI ne voit que connexion VPN chiffrée
- ✅ **Évite HADOPI** — Pas de détection téléchargements
- ✅ **Pas de throttling** — FAI ne peut pas limiter P2P
- ✅ **Accès international** — Contourne blocages géographiques

---

## WireGuard vs autres VPN

| VPN | Vitesse | Sécurité | Complexité | Recommandation |
|-----|---------|----------|------------|----------------|
| **WireGuard** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ Moyenne | ✅ **Meilleur choix** |
| OpenVPN | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ Facile | ✅ Alternative |
| IPSec/IKEv2 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ Difficile | ⚠️ Pour experts |

**Pourquoi WireGuard ?**
- 🚀 **Ultra-rapide** (moins d'impact vitesse)
- 🔒 **Sécurité moderne** (cryptographie state-of-the-art)
- 📦 **Léger** (code minimal, moins bugs)
- 🐳 **Docker-friendly** (facile intégration)

---

## Installation WireGuard

### Option 1 : Via le script setup.sh

Si vous avez utilisé `setup.sh` :

```bash
Installer WireGuard VPN pour qBittorrent ? (y/n) [n]
→ Répondez : y
```

Le script configure automatiquement WireGuard.

---

### Option 2 : Installation manuelle Docker

**1. Créez le fichier docker-compose**

```bash
sudo mkdir -p /volume1/docker/r-apps/wireguard
cd /volume1/docker/r-apps/wireguard
nano docker-compose.yml
```

**2. Collez cette configuration**

```yaml
version: '3.8'
services:
  wireguard:
    image: lscr.io/linuxserver/wireguard:latest
    container_name: wireguard
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    environment:
      - PUID=1026
      - PGID=100
      - TZ=Europe/Paris
      - SERVERURL=auto
      - SERVERPORT=51820
      - PEERS=1
      - PEERDNS=auto
      - INTERNAL_SUBNET=10.13.13.0
    volumes:
      - /volume1/docker/r-apps/wireguard/config:/config
      - /lib/modules:/lib/modules
    ports:
      - 51820:51820/udp
    sysctls:
      - net.ipv4.conf.all.src_valid_mark=1
    restart: unless-stopped
```

**3. Sauvegardez** (`Ctrl+O`, `Entrée`, `Ctrl+X`)

**4. Démarrez WireGuard**

```bash
docker-compose up -d
```

**5. Vérifiez les logs**

```bash
docker-compose logs -f wireguard
```

Attendez le message :
```
Server started
```

---

### Option 3 : Fournisseur VPN externe

Si vous utilisez un VPN commercial (NordVPN, ExpressVPN, Mullvad, etc.) :

**1. Récupérez le fichier config WireGuard**

- NordVPN : https://nordvpn.com/servers/tools/
- Mullvad : https://mullvad.net/en/account/#/wireguard-config/
- ProtonVPN : Télécharger config WireGuard

**2. Placez le fichier dans**

```bash
/volume1/docker/r-apps/wireguard/config/wg0.conf
```

**3. Modifiez docker-compose.yml**

Retirez les variables SERVERURL, SERVERPORT, PEERS (pas utilisées avec config externe)

---

## Configuration qBittorrent

### Méthode 1 : qBittorrent à travers WireGuard (recommandée)

**Cette méthode force qBittorrent à utiliser UNIQUEMENT le VPN.**

**1. Éditez votre docker-compose qBittorrent**

```bash
cd /volume1/docker/r-apps/qbittorrent
nano docker-compose.yml
```

**2. Modifiez ainsi**

```yaml
version: '3.8'
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: "container:wireguard"  # ← AJOUTER CETTE LIGNE
    environment:
      - PUID=1026
      - PGID=100
      - TZ=Europe/Paris
      - WEBUI_PORT=8080
    volumes:
      - /volume1/docker/r-apps/qbittorrent/config:/config
      - /volume1/torrents:/torrents
    # ports:  ← COMMENTEZ CETTE SECTION
    #   - 8080:8080
    #   - 6881:6881
    #   - 6881:6881/udp
    restart: unless-stopped
```

**3. Sauvegardez et redémarrez**

```bash
docker-compose down
docker-compose up -d
```

**Explication :**
- `network_mode: "container:wireguard"` → qBittorrent utilise le réseau de WireGuard
- Ports exposés via WireGuard container
- Si VPN tombe → qBittorrent n'a plus accès internet = **Kill Switch natif** ✅

---

### Méthode 2 : Interface réseau (moins sûre)

**Si Méthode 1 ne fonctionne pas :**

**1. qBittorrent > Options > Advanced**

| Paramètre | Valeur |
|-----------|--------|
| **Network Interface** | `wg0` |
| **Optional IP to bind to** | IP du VPN |

**2. Testez**

Si erreur, WireGuard pas configuré correctement.

---

## Tests et vérification

### Test 1 : Vérifier IP qBittorrent

**1. Allez sur https://ipleak.net**

**2. Téléchargez le torrent magnet test**

Cliquez sur "Torrent Address detection"

**3. Ajoutez dans qBittorrent**

**4. Attendez connexion aux peers**

**5. Retournez sur ipleak.net**

**Résultat attendu :**
```
IP détectée : <IP_VPN> (Pays du serveur VPN)
PAS votre vraie IP Freebox !
```

✅ Si IP différente de votre IP Freebox → **VPN fonctionne !**

---

### Test 2 : Kill Switch

**Tester que qBittorrent s'arrête si VPN tombe**

**1. Arrêtez WireGuard**

```bash
cd /volume1/docker/r-apps/wireguard
docker-compose down
```

**2. Vérifiez qBittorrent**

- Essayez d'accéder à `http://<IP_NAS>:8080`
- **Devrait être inaccessible** (si Méthode 1) ✅

**3. Vérifiez torrents**

Dans qBittorrent Activity :
- Torrents devraient être **Stalled** ou **Paused**
- Pas de connexion aux peers

✅ **Kill Switch fonctionne !**

**4. Redémarrez WireGuard**

```bash
docker-compose up -d
```

qBittorrent devrait redevenir accessible et torrents reprendre.

---

### Test 3 : DNS Leak

**1. Allez sur https://dnsleaktest.com**

**2. Standard Test**

**Résultat attendu :**
```
DNS Servers: <Pays VPN>
PAS les DNS de votre FAI (Freebox)
```

✅ Si DNS du VPN → **Pas de fuite DNS**

---

## Kill Switch

### Qu'est-ce qu'un Kill Switch ?

**Kill Switch = Coupe-circuit automatique**

```
VPN actif → qBittorrent télécharge
VPN tombe → qBittorrent s'arrête immédiatement
→ AUCUN trafic P2P visible par FAI
```

---

### Méthode 1 : Kill Switch natif (Méthode recommandée)

Avec `network_mode: "container:wireguard"` :

✅ **Kill Switch automatique** !

Si WireGuard s'arrête → qBittorrent perd connexion internet.

**Aucune configuration supplémentaire nécessaire.**

---

### Méthode 2 : Bind interface (moins fiable)

Si vous utilisez seulement **Network Interface** dans qBittorrent :

⚠️ **Pas de Kill Switch automatique**

Si VPN tombe, qBittorrent peut basculer sur interface normale.

**Solution :**

**Options > Advanced**

```yaml
Network Interface: wg0
Optional IP to bind to: <IP_VPN_fixe>
```

Mais **pas 100% fiable**.

---

## Troubleshooting

### ❌ "Cannot access qBittorrent after VPN setup"

**Cause :** `network_mode: "container:wireguard"` mal configuré.

**Solutions :**

**1. Vérifiez WireGuard running**

```bash
docker ps | grep wireguard
```

Doit être **Up**.

**2. Ports exposés via WireGuard**

Éditez `wireguard/docker-compose.yml` :

```yaml
  wireguard:
    ...
    ports:
      - 51820:51820/udp
      - 8080:8080  # ← AJOUTER pour qBittorrent WebUI
      - 6881:6881
      - 6881:6881/udp
```

**3. Redémarrez tout**

```bash
cd /volume1/docker/r-apps/wireguard
docker-compose down
docker-compose up -d

cd /volume1/docker/r-apps/qbittorrent
docker-compose down
docker-compose up -d
```

---

### ⚠️ VPN très lent

**Causes possibles :**

**1. Serveur VPN surchargé**
- Changez de serveur VPN (config)
- Choisissez serveur proche géographiquement

**2. Protocole UDP bloqué**
- Certains FAI bloquent UDP
- Testez port différent (ex: 443/udp)

**3. Encryption overhead**
- Normal avec VPN
- WireGuard = impact minimal

**Optimisations :**

```yaml
# wireguard config
[Interface]
MTU = 1420  # Ajuster si problèmes
```

---

### 🔴 "DNS not resolving"

**Cause :** DNS du VPN pas configuré.

**Solution :**

**wireguard docker-compose.yml**

```yaml
environment:
  - PEERDNS=auto  # ou 1.1.1.1, 8.8.8.8
```

Ou dans `wg0.conf` :

```ini
[Interface]
DNS = 1.1.1.1, 1.0.0.1
```

---

### ❌ IP leak (vraie IP exposée)

**Test avec ipleak.net montre votre vraie IP**

**Causes :**

**1. VPN pas activé**
```bash
docker-compose logs wireguard
# Vérifiez "Peer connected"
```

**2. qBittorrent pas sur VPN network**
- Vérifiez `network_mode: "container:wireguard"`

**3. WebRTC leak (navigateur)**
- Pas lié à qBittorrent
- Désactivez WebRTC dans navigateur

---

### ⚠️ "Peer connection lost" dans qBittorrent

**Cause :** Port forwarding VPN requis.

**Solution :**

Certains trackers privés nécessitent port forwarding.

**Avec WireGuard :**

- Configurez port forwarding dans votre fournisseur VPN
- Ou utilisez trackers publics (pas de port forwarding requis)

---

## 📊 Configuration recommandée finale

```yaml
# WireGuard (si self-hosted)
Image: lscr.io/linuxserver/wireguard:latest
Port: 51820/udp
SERVERURL: auto
PEERS: 1

# qBittorrent
network_mode: "container:wireguard"
(Pas de ports directs)

# Tests
✅ ipleak.net → IP VPN
✅ dnsleaktest.com → DNS VPN
✅ Kill Switch → qBittorrent arrête si VPN tombe
```

---

## 📚 Guides connexes

- **[qBittorrent](../apps/01-qbittorrent.md)** — Configuration complète
- **[YGGTorrent Profils](yggtorrent-profiles.md)** — Seed avec VPN
- **[Troubleshooting avancé](troubleshooting-advanced.md)** — Problèmes réseau

---

**✅ Votre VPN est configuré !**

Téléchargements sécurisés et anonymes ! 🔐
