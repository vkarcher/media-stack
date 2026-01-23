# 🍿 Configuration Jellyfin

Jellyfin est votre lecteur multimédia. C'est lui qui va streamer vos films sur votre TV.

## 1. Initialisation

Lors du premier lancement (`http://<IP>:8096`), l'assistant vous guide.
L'étape cruciale est l'ajout des bibliothèques.

Ajoutez une bibliothèque **Films** :
- Dossier : `/data/media/movies`
- (Le dossier `/data` est monté automatiquement par Docker)

Ajoutez une bibliothèque **Séries** :
- Dossier : `/data/media/series`

## 2. Transcodage Matériel (Important !)

Si votre NAS a un processeur Intel (comme le DS224+, DS920+...), activez l'accélération matérielle pour que la lecture soit fluide sans tuer le CPU.

1. Allez dans le **Tableau de bord** (Dashboard) > **Lecture** (Playback).
2. **Accélération matérielle** : Choisissez `Intel QuickSync (QSV)` (ou VAAPI si QSV n'est pas dispo).
3. Cochez les codecs supportés (H264, HEVC, VC1...).
4. Sauvegardez.

> Si une vidéo ne se lance pas, essayez de désactiver le transcodage pour tester.

## 3. Plugins Recommandés

Dans **Tableau de bord > Catalogue** :

- **TMDb Box Sets** : Crée automatiquement des collections (ex: "Harry Potter Collection").
- **Jellyfin-Plugin-MergeVersions** : Si vous avez un film en 1080p et 4K, il les regroupe en une seul fiche.
- **Reports** : Pour avoir des stats sur qui regarde quoi.

## 4. Pour vos appareils (Clients)

- **Android TV / Google TV** : L'app officielle "Jellyfin for Android TV" est top.
- **Apple TV / iOS** : Utilisez **Infuse** (payant mais incroyable) ou **Swiftfin** (gratuit).
- **PC** : **Jellyfin Media Player** (bien mieux que le navigateur web).
