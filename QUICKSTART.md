# ⚡ Guide de Démarrage Rapide

Ce guide va droit au but pour installer votre stack en moins de 10 minutes.

## 1. Préparatifs (Sur le NAS)

Connectez-vous en SSH à votre NAS.

```bash
# Devenir root (administrateur suprême)
sudo -i

# Aller dans le volume principal
cd /volume1

# Cloner le projet
git clone https://github.com/vkarcher/media-stack.git
cd media-stack
```

## 2. Configuration

Copiez le fichier d'exemple et éditez-le si nécessaire.

```bash
cp .env.example .env
```

*Optionnel :* Si vous voulez changer le timezone ou les ports :
```bash
vi .env
# Appuyez sur 'i' pour insérer, modifiez, puis 'Echap' et ':wq' pour sauvegarder.
```

## 3. Installation Automatique

Lancez le script qui va créer tous les dossiers (`/data/media`, `/docker/...`) et régler les permissions.

```bash
bash setup.sh
```

## 4. Lancement

```bash
docker-compose up -d
```

Vous devriez voir une liste de "Started" vert.
Attendez 2-3 minutes que les applications s'initialisent.

---

## 5. Accès et Première Configuration

### A. Accéder à Homarr (Dashboard)
Ouvrez `http://<IP_NAS>:7575`.
C'est vide pour l'instant !
1. Passez en "Mode Édition" (en haut à droite).
2. Ajoutez des "Apps".
3. Pour chaque app, mettez son nom et son URL (ex: `http://192.168.1.50:8096` pour Jellyfin).
4. Sauvegardez.

### B. Configurer Jellyfin
Ouvrez `http://<IP_NAS>:8096`.
1. Suivez l'assistant.
2. Quand on vous demande les dossiers, choisissez :
   - **Films** : `/data/media/movies`
   - **Séries** : `/data/media/series`
3. Activez le transcodage matériel (VAAPI/QSV) si vous avez un NAS Intel.

### C. Lier le tout
Le plus important est de connecter **Sonarr/Radarr** à **Jellyseerr** et **qBittorrent**.
*(Voir le guide complet "Arr Stack" pour les détails)*.

---

## ❓ Problèmes fréquents

**Les dossiers sont vides ?**
Vérifiez que vous avez bien lancé `setup.sh`.

**Permission denied ?**
Relancez `bash setup.sh` pour forcer la ré-application des permissions.

**Port déjà utilisé ?**
Modifiez le port posant problème dans le fichier `.env` puis faites `docker-compose up -d`.
