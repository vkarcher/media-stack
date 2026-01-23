# 🤖 Configuration Arr-Stack (Sonarr/Radarr)

C'est le cerveau de votre installation. Une bonne configuration ici = des téléchargements parfaits sans effort.

## 1. Concepts de base

- **Sonarr** = Séries TV (et Animés).
- **Radarr** = Films.
- **Prowlarr** = Gère les sites de torrents pour les deux.

## 2. Lier Prowlarr aux Arrs

Avant tout, configurez Prowlarr :
1. Allez sur **Prowlarr** (`:9696`).
2. Ajoutez vos indexeurs (YGG, Torrent9, 1337x...).
    - *Settings > Indexers*.
3. Connectez Sonarr et Radarr :
    - *Settings > Apps*.
    - Ajoutez Sonarr : URL `http://sonarr:8989`, API Key (trouvée dans Sonarr > Settings > General).
    - Ajoutez Radarr : URL `http://radarr:7878`, API Key (trouvée dans Radarr).
    - Cliquez sur **Test** puis **Save**.
4. Prowlarr va automatiquement configurer les indexeurs dans Sonarr et Radarr !

## 3. Configuration Sonarr/Radarr (La partie FR 🇫🇷)

Pour télécharger du contenu Français (VFF, TrueFrench) de qualité, il faut configurer les **Custom Formats**.

### A. Profiles de Qualité (Quality Profiles)
*Settings > Profiles*

Créez un profil "HD FR" :
- Cochez **Upgrade Allowed** (pour passer d'une version CAM à une version HD automatiquement).
- Qualités souhaitées : Web 1080p, Bluray 1080p.
- Langue : **French** (Important mais pas suffisant).

### B. Custom Formats (Le secret du succès)
*Settings > Custom Formats*

Nous allons créer une règle pour forcer la "Vraie version française".

1. **Ajouter un Custom Format** : Nommez-le "Version FR".
2. **Ajouter une condition** : Choisissez "Regular Expression".
3. **Regex** : Mettez ceci :
   ```regex
   \b(MULTI|TRUEFRENCH|VFF|VFQ|VF)\b
   ```
4. Sauvegardez.

### C. Lier le Custom Format au Profil
1. Retournez dans *Settings > Profiles*.
2. Modifiez votre profil "HD FR".
3. À droite, dans "Custom Formats", cochez "Version FR".
4. Mettez un "Score" minimum (ex: 100) ou cochez "Required" (Requis).
   - **Required** : Si le torrent n'a pas les mots clés (MULTI, VFF...), il sera ignoré. C'est radical mais efficace.

## 4. Connexion au Client de Téléchargement

Dans Sonarr ET Radarr :
1. *Settings > Download Clients*.
2. Ajoutez **qBittorrent**.
3. **Host** : `qbittorrent` (c'est le nom du conteneur Docker).
4. **Port** : `8080`.
5. **Username/Password** : `admin` / `adminadmin` (ou celui que vous avez changé).
6. **Category** :
   - Pour Sonarr : `series`
   - Pour Radarr : `movies`
7. Test & Save.

## 5. Root Folders (Dossiers Racines)

Quand vous ajoutez une série/film, on vous demande le "Path".
⚠️ **TRÈS IMPORTANT POUR LES HARDLINKS**

Choisissez TOUJOURS :
- `/data/media/series` (pour Sonarr)
- `/data/media/movies` (pour Radarr)

Surtout pas `/media/...` ou un autre chemin. Il faut que ce soit `/data/...` pour que le lien avec qBittorrent (`/data/torrents`) soit instantané.
