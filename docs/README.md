# 📚 Documentation Complète — Stack Média Automatisée

> Guide exhaustif pour débutants : configuration de 0 jusqu'à une stack média 100% automatisée

---

## 🎯 Par où commencer ?

### Vous êtes complètement débutant ?
👉 Commencez ici : [Guide de démarrage rapide](../QUICKSTART.md)

### Vous avez déjà installé la stack ?
👉 Consultez les [guides par application](#-guides-par-application) ci-dessous

### Vous voulez YGGTorrent ?
👉 Suivez le [Guide YGGTorrent complet](guides/yggtorrent-setup.md)

---

## 📖 Table des matières

1. [Guides par application](#-guides-par-application)
2. [Guides thématiques](#-guides-thématiques)
3. [Configuration avancée](#-configuration-avancée)
4. [Troubleshooting](#-troubleshooting)

---

## 🔧 Guides par application

Chaque guide est **complet** et **indépendant** : captures d'écran, explications détaillées, FAQ.

### 1. [qBittorrent](apps/01-qbittorrent.md)
**Ce que vous apprendrez :**
- ✅ Installation et première configuration
- ✅ Créer les catégories (movies, series, anime)
- ✅ Limiter la bande passante
- ✅ Configurer le VPN
- ✅ 3 profils de seed (Légit / Équilibré / Risqué)
- ✅ Automatisation complète

**Niveau :** ⭐ Débutant → ⭐⭐⭐ Avancé

---

### 2. [Prowlarr](apps/02-prowlarr.md)
**Ce que vous apprendrez :**
- ✅ Qu'est-ce qu'un indexer ?
- ✅ Ajouter des trackers publics (EZTV, YTS, etc.)
- ✅ Ajouter YGGTorrent (tracker privé français)
- ✅ Configurer FlareSolverr (bypass Cloudflare)
- ✅ Synchroniser avec Radarr/Sonarr
- ✅ Trackers spécialisés animés (Nyaa.si)

**Niveau :** ⭐⭐ Intermédiaire

---

### 3. [Radarr](apps/03-radarr.md)
**Ce que vous apprendrez :**
- ✅ Configuration complète de A à Z
- ✅ Profils de qualité (720p, 1080p, 4K)
- ✅ Renommage automatique
- ✅ Listes automatiques (IMDb, Trakt)
- ✅ Recherche automatique vs manuelle
- ✅ Gestion des films multi-versions

**Niveau :** ⭐⭐ Intermédiaire

---

### 4. [Sonarr](apps/04-sonarr.md)
**Ce que vous apprendrez :**
- ✅ Configuration complète (séries + animés)
- ✅ Profils pour séries classiques
- ✅ Profils pour animés (Nyaa.si)
- ✅ Monitoring par saison/épisode
- ✅ Renommage S01E01
- ✅ Calendrier et notifications
- ✅ Dossiers racines multiples

**Niveau :** ⭐⭐ Intermédiaire

---

### 5. [Overseerr](apps/05-overseerr.md)
**Ce que vous apprendrez :**
- ✅ Installation et connexion Plex
- ✅ Ajouter Radarr et Sonarr
- ✅ Gérer les utilisateurs
- ✅ Quotas et permissions
- ✅ Notifications (Discord, Telegram)
- ✅ Interface utilisateur pour la famille

**Niveau :** ⭐ Débutant

---

### 6. [Plex](apps/06-plex.md)

🔗 **Télécharger Plex :** https://www.plex.tv/fr/media-server-downloads/?cat=nas&plat=synology-dsm72

**Ce que vous apprendrez :**
- ✅ Installation Plex Media Server (avec lien de téléchargement)
- ✅ Ajouter les bibliothèques (films, séries, animés)
- ✅ Agents metadata (posters, descriptions)
- ✅ Transcoding et DirectPlay
- ✅ Utilisateurs et partage
- ✅ Applications client (TV, mobile, web)

**Niveau :** ⭐ Débutant

---

### 7. [FlareSolverr](apps/07-flaresolverr.md)
**Ce que vous apprendrez :**
- ✅ Qu'est-ce que Cloudflare ?
- ✅ Pourquoi FlareSolverr est nécessaire
- ✅ Installation Docker
- ✅ Configuration dans Prowlarr
- ✅ Troubleshooting erreurs Cloudflare

**Niveau :** ⭐⭐ Intermédiaire

---

## 🎓 Guides thématiques

### [Configuration YGGTorrent](guides/yggtorrent-setup.md)
**Guide complet pour YGGTorrent (tracker privé français)**

**Contenu :**
- 📦 Installation FlareSolverr
- 🔑 Récupérer votre Passkey YGG
- ⚙️ Configuration Prowlarr
- ✅ Test et validation
- 🐛 Troubleshooting complet

**Temps estimé :** 20 minutes

---

### [Profils YGGTorrent : 3 configurations](guides/yggtorrent-profiles.md)
**Choisissez votre profil selon vos besoins**

#### 🟢 **Profil 1 : "Légit"** (recommandé)
- ✅ Ratio 1.0+ respecté
- ✅ Seed longue durée
- ✅ Aucun risque de ban
- ⚠️ Bande passante élevée

#### 🟡 **Profil 2 : "Équilibré"** (bon compromis)
- ⚠️ Ratio 0.6 minimum
- ✅ Seed 3 jours puis pause
- ⚠️ Risque faible de ban
- ✅ Bande passante modérée

#### 🔴 **Profil 3 : "Risqué"** (à vos risques)
- ❌ Pas de seed / Hit & Run
- 🚨 Risque ÉLEVÉ de ban
- ✅ Bande passante minimale
- ⚠️ Configuration step-by-step avec avertissements

**Pour chaque profil :** Configuration qBittorrent + Radarr/Sonarr détaillée

---

### [Configuration Animés](guides/anime-configuration.md)
**Tout pour télécharger et organiser vos animés**

**Contenu :**
- 🎌 Trackers spécialisés (Nyaa.si, SubsPlease)
- 📁 Structure dossiers `/anime`
- 🏷️ Profils et tags Sonarr
- 📺 Format de nommage
- 🌐 Problèmes de reconnaissance
- 🔄 Saisons (cour) japonaises

---

### [Configuration VPN](guides/vpn-setup.md)
**Sécuriser vos téléchargements avec WireGuard**

**Contenu :**
- 🔐 Pourquoi un VPN ?
- 📦 Installation WireGuard
- ⚙️ Configuration qBittorrent via VPN
- ✅ Test d'anonymat (ipleak.net)
- 🐛 Troubleshooting VPN

---

### [Troubleshooting Avancé](guides/troubleshooting-advanced.md)
**Solutions aux problèmes complexes**

**Contenu :**
- 🔍 Logs Docker détaillés
- 🌐 Problèmes réseau (DNS, proxy)
- 💾 Permissions fichiers
- 🚀 Optimisation performances
- 🔄 Migration de configuration

---

## ⚙️ Configuration avancée

### Reverse Proxy & HTTPS
- Nginx Proxy Manager
- Certificats Let's Encrypt
- Sous-domaines

### Extensions
- Bazarr (sous-titres)
- Tautulli (stats Plex)
- Notifiarr (notifications)
- Organizr (dashboard)

### Monitoring
- Grafana + Prometheus
- Uptime Kuma
- Healthchecks

---

## 🆘 Troubleshooting

### Problèmes courants

| Problème | Guide |
|----------|-------|
| Radarr/Sonarr ne trouvent rien | [Prowlarr](apps/02-prowlarr.md#troubleshooting) |
| Erreur Cloudflare YGGTorrent | [FlareSolverr](apps/07-flaresolverr.md#troubleshooting) |
| Téléchargements ne démarrent pas | [qBittorrent](apps/01-qbittorrent.md#troubleshooting) |
| Animés non reconnus | [Animés](guides/anime-configuration.md#noms-non-reconnus) |
| VPN ne fonctionne pas | [VPN](guides/vpn-setup.md#troubleshooting) |

---

## 📞 Ressources supplémentaires

- [README principal](../README.md) — Vue d'ensemble du projet
- [QUICKSTART.md](../QUICKSTART.md) — Installation rapide
- [FREEBOX_SETUP.md](../FREEBOX_SETUP.md) — Configuration ports
- [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) — FAQs générales

---

## 🎯 Parcours recommandés

### 🆕 Nouveau sur Docker/NAS ?
1. [QUICKSTART.md](../QUICKSTART.md) — Installer la stack
2. [qBittorrent](apps/01-qbittorrent.md) — Configurer le client
3. [Prowlarr](apps/02-prowlarr.md) — Ajouter des trackers
4. [Radarr](apps/03-radarr.md) — Films
5. [Sonarr](apps/04-sonarr.md) — Séries
6. [Overseerr](apps/05-overseerr.md) — Interface utilisateur

### 🇫🇷 Vous voulez YGGTorrent ?
1. [FlareSolverr](apps/07-flaresolverr.md) — Bypass Cloudflare
2. [YGGTorrent Setup](guides/yggtorrent-setup.md) — Installation
3. [YGGTorrent Profils](guides/yggtorrent-profiles.md) — Choisir votre config

### 🎌 Fan d'animés ?
1. [Sonarr](apps/04-sonarr.md) — Configuration de base
2. [Configuration Animés](guides/anime-configuration.md) — Guide complet
3. [Prowlarr](apps/02-prowlarr.md) — Nyaa.si

### 🔒 Sécurité et vie privée ?
1. [VPN Setup](guides/vpn-setup.md) — WireGuard
2. [FREEBOX_SETUP.md](../FREEBOX_SETUP.md) — Sécuriser les ports
3. Reverse Proxy (à venir)

---

**📝 Tous les guides sont régulièrement mis à jour. N'hésitez pas à signaler les erreurs ou proposer des améliorations !**
