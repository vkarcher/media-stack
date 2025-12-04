# 🔄 Guide YGG-API Auto-Update (Alternative à FlareSolverr)

> Configuration automatique de YGG-API pour Prowlarr - Solution moderne sans dépendance FlareSolverr

**⏱️ Temps estimé :** 15 minutes  
**📊 Niveau :** Intermédiaire  
**⚠️ Prérequis :** Stack média installée avec Prowlarr

---

## 📖 Table des matières

1. [Qu'est-ce que YGG-API ?](#quest-ce-que-ygg-api-)
2. [YGG-API vs FlareSolverr](#ygg-api-vs-flaresolverr)
3. [Installation automatique](#installation-automatique)
4. [Configuration dans Prowlarr](#configuration-dans-prowlarr)
5. [Troubleshooting](#troubleshooting)

---

## Qu'est-ce que YGG-API ?

**YGG-API** est une définition d'indexer personnalisée pour Prowlarr qui permet d'accéder à YGGTorrent via une **API miroir** au lieu du site web principal.

### Avantages

- ✅ **Pas de protection Cloudflare** → Pas besoin de FlareSolverr
- ✅ **Mises à jour automatiques** → Script de synchronisation quotidienne
- ✅ **Plus rapide** → Pas de simulation de navigateur
- ✅ **Moins de ressources** → Pas de conteneur supplémentaire
- ✅ **Plus stable** → Moins de timeouts

### Inconvénients

- ⚠️ **Dépend d'un miroir API tiers** → Fiabilité dépend du mainteneur
- ⚠️ **Moins officiel** → Solution communautaire

---

## YGG-API vs FlareSolverr

| Critère | YGG-API | FlareSolverr |
|---------|---------|--------------|
| **Conteneurs Docker** | 0 supplémentaire | +1 (FlareSolverr) |
| **RAM utilisée** | ~0 MB | ~300 MB |
| **CPU** | Minimal | 5-10% (pics 50%) |
| **Vitesse** | ⚡ Rapide (1-2s) | 🐢 Lent (5-15s) |
| **Stabilité** | 🟢 Stable | 🟡 Timeouts possibles |
| **Officiel** | ❌ Communauté | ✅ Solution standard |

**Recommandation :** Essayez YGG-API en premier. Si ça ne fonctionne pas, utilisez [FlareSolverr](yggtorrent-setup.md).

---

## Installation automatique

### Étape 1 : Créer le dossier Custom Definitions

```bash
# Connexion SSH
ssh admin@<IP_NAS>
sudo -i

# Créer le dossier
mkdir -p /volume1/docker/r-apps/prowlarr/config/Definitions/Custom
chown 1026:100 /volume1/docker/r-apps/prowlarr/config/Definitions/Custom
chmod 755 /volume1/docker/r-apps/prowlarr/config/Definitions/Custom
```

> **Note :** `1026:100` sont les PUID:PGID par défaut de Synology. Si vous avez modifié ces valeurs dans votre `setup.sh`, utilisez vos propres IDs.

---

### Étape 2 : Créer la tâche planifiée DSM

1. **DSM → Panneau de configuration → Planificateur de tâches**

2. **Créer → Tâche planifiée → Script défini par l'utilisateur**

3. **Général** :
   - **Nom** : `YGG-API Auto-Update`
   - **Utilisateur** : `root`
   - **Activé** : ✅ Oui

4. **Planification** :
   - **Date** : Quotidien
   - **Heure** : `03:00` (3h du matin, ou comme vous voulez)
   - **Fréquence** : Une fois par jour

5. **Paramètres de la tâche** → Onglet **"Script défini par l'utilisateur"** :

Collez ce script :

```bash
#!/bin/bash

GIST_ID="8bfded23ef23ec78f6678896f42a2b60"
DEFINITIONS_DIR="/volume1/docker/r-apps/prowlarr/config/Definitions/Custom"
PUID=1026  # ⚠️ Modifiez si vos IDs sont différents
PGID=100   # ⚠️ Modifiez si vos IDs sont différents

echo "=== Vérification YGG-API ==="

lastCommit=$(curl -s "https://api.github.com/gists/$GIST_ID/commits" | jq -r '.[0].committed_at')
echo "Dernier commit: $lastCommit"

files=$(curl -s "https://api.github.com/gists/$GIST_ID" | jq -r '.files | keys[] | select(endswith(".yml"))')

NEED_RESTART=false

for file in $files; do
    filepath="$DEFINITIONS_DIR/$file"
    filebase="${file%.yml}"
    variant=$(echo "$filebase" | sed 's/ygg-api-//' | sed 's/.*/\u&/')
    
    if [ -f "$filepath" ]; then
        lastWrite=$(date -r "$filepath" +"%Y-%m-%dT%H:%M:%SZ" -u)
        if [[ "$lastCommit" > "$lastWrite" ]]; then
            echo "$file - Mise à jour"
            wget -qO "$filepath.tmp" "https://gist.githubusercontent.com/Clemv95/$GIST_ID/raw/$file"
            sed -i "s/^id: yggapi$/id: $filebase/" "$filepath.tmp"
            sed -i "s/^name: YggAPI$/name: YggAPI $variant/" "$filepath.tmp"
            mv "$filepath.tmp" "$filepath"
            chown "$PUID:$PGID" "$filepath"
            chmod 644 "$filepath"
            NEED_RESTART=true
        else
            echo "$file - Déjà à jour"
        fi
    else
        echo "$file - Nouveau fichier"
        wget -qO "$filepath.tmp" "https://gist.githubusercontent.com/Clemv95/$GIST_ID/raw/$file"
        sed -i "s/^id: yggapi$/id: $filebase/" "$filepath.tmp"
        sed -i "s/^name: YggAPI$/name: YggAPI $variant/" "$filepath.tmp"
        mv "$filepath.tmp" "$filepath"
        chown "$PUID:$PGID" "$filepath"
        chmod 644 "$filepath"
        NEED_RESTART=true
    fi
done

if [ "$NEED_RESTART" = true ]; then
    docker restart prowlarr
    echo "Prowlarr redémarré"
fi
```

6. **Cliquez sur OK** pour sauvegarder

7. **Testez immédiatement** :
   - Sélectionnez la tâche
   - Cliquez sur **Exécuter**
   - Attendez 10-30 secondes

---

### Étape 3 : Vérifier les logs

Dans DSM, après l'exécution :
- Sélectionnez la tâche `YGG-API Auto-Update`
- Cliquez sur **Action** → **Afficher les résultats**

Vous devriez voir :
```
=== Vérification YGG-API ===
Dernier commit: 2025-11-02T16:04:40Z
ygg-api-download.yml - Nouveau fichier
ygg-api-magnet.yml - Nouveau fichier
prowlarr
Prowlarr redémarré
```

✅ **Si vous voyez "Prowlarr redémarré", c'est bon !**

---

## Configuration dans Prowlarr

### Étape 1 : Redémarrer Prowlarr (si pas fait automatiquement)

```bash
docker restart prowlarr
```

Ou via DSM : **Container Manager → prowlarr → Redémarrer**

---

### Étape 2 : Ajouter les indexers YGG-API

1. **Prowlarr → Indexers → Add Indexer**

   🌐 `http://<IP_NAS>:9696`

2. **Recherchez "YggAPI"**

   Vous devriez voir apparaître :
   - **YggAPI Download**
   - **YggAPI Magnet**

3. **Ajoutez "YggAPI Download"** (recommandé pour la compatibilité)

   | Paramètre | Valeur | Explication |
   |-----------|--------|-------------|
   | **Name** | `YggAPI Download` | Nom affiché |
   | **Enable** | ✅ Oui | Activer l'indexer |
   | **Priority** | `25` | Priorité moyenne |
   | **Username** | Votre login YGG | Identifiant YGGTorrent |
   | **Password** | Votre mot de passe YGG | Mot de passe YGGTorrent |

4. **Catégories** :
   - ✅ Movies
   - ✅ TV
   - ✅ TV/Anime (si vous voulez des animés)

5. **Test & Save**
   - Cliquez sur **Test**
   - ✅ Devrait afficher "All checks have passed"
   - Cliquez sur **Save**

---

### Étape 3 : (Optionnel) Ajouter "YggAPI Magnet"

**YggAPI Magnet** utilise des liens magnet au lieu de fichiers .torrent.

**Avantages** :
- ✅ Plus rapide (pas de téléchargement de .torrent)
- ✅ Moins de bande passante

**Inconvénients** :
- ⚠️ Peut être moins compatible avec certains clients torrent

Ajoutez-le de la même manière si vous le souhaitez.

---

### Étape 4 : Synchroniser avec Radarr/Sonarr

Prowlarr va automatiquement pousser les indexers vers Radarr et Sonarr.

**Vérification :**

1. **Radarr → Settings → Indexers**
   - `http://<IP_NAS>:7878`
   - YggAPI Download devrait apparaître ✅

2. **Sonarr → Settings → Indexers**
   - `http://<IP_NAS>:8989`
   - YggAPI Download devrait apparaître ✅

---

## Test de fonctionnement

### Test 1 : Recherche manuelle dans Prowlarr

1. **Prowlarr → Search**
2. Recherchez : `Le Comte de Monte-Cristo` ou `Lupin`
3. Cliquez sur **Search**

**Résultat attendu** :
- Des résultats de **YggAPI Download** apparaissent
- Seeders/Leechers visibles
- Taille et qualité affichées

✅ **Si vous voyez des résultats, YGG-API fonctionne !**

---

### Test 2 : Téléchargement via Radarr

1. **Radarr → Movies → Add New Movie**
2. Recherchez : `Le Comte de Monte-Cristo 2024`
3. Ajoutez le film (Root Folder: `/movies`)
4. Cliquez sur le film → **Search**

**Résultat attendu** :
- Radarr trouve des releases sur YggAPI
- Le téléchargement démarre dans qBittorrent

✅ **Film téléchargé = succès !**

---

## Troubleshooting

### ❌ YggAPI n'apparaît pas dans Prowlarr

**Solutions** :

1. **Vérifier que les fichiers YAML existent** :
   ```bash
   ls -la /volume1/docker/r-apps/prowlarr/config/Definitions/Custom/
   ```
   Devrait afficher :
   ```
   ygg-api-download.yml
   ygg-api-magnet.yml
   ```

2. **Vérifier les permissions** :
   ```bash
   chown 1026:100 /volume1/docker/r-apps/prowlarr/config/Definitions/Custom/*.yml
   chmod 644 /volume1/docker/r-apps/prowlarr/config/Definitions/Custom/*.yml
   ```

3. **Redémarrer Prowlarr** :
   ```bash
   docker restart prowlarr
   ```

4. **Vider le cache du navigateur** et recharger Prowlarr

---

### ❌ Erreur "Authentication failed"

**Cause :** Username/Password incorrect

**Solutions** :

1. Vérifiez vos identifiants YGG sur le site web
2. Prowlarr → Indexers → YggAPI → Edit
3. Rentrez à nouveau username/password
4. Save

---

### ❌ Pas de résultats de recherche

**Solutions** :

1. **Test manuel** :
   - Prowlarr → Search → `matrix`
   - YggAPI devrait retourner des résultats

2. **Vérifier les catégories** :
   - Prowlarr → Indexers → YggAPI → Edit
   - Categories : ✅ Movies, TV

3. **Vérifier les logs** :
   ```bash
   docker logs prowlarr | grep -i ygg
   ```

---

### ⚠️ Le script de mise à jour ne fonctionne pas

**Solutions** :

1. **Vérifier `jq` est installé** :
   ```bash
   which jq
   # Si vide, installer : opkg install jq
   ```

2. **Vérifier la connectivité Internet** :
   ```bash
   curl -s "https://api.github.com/gists/8bfded23ef23ec78f6678896f42a2b60"
   ```

3. **Exécuter le script manuellement** :
   ```bash
   sudo -i
   # Collez le script et exécutez-le
   ```

4. **Vérifier les logs DSM** :
   - Planificateur → Tâche YGG-API → Action → Afficher les résultats

---

## 🎯 Résumé

Si vous avez suivi ce guide :

✅ **Script de mise à jour** configuré (s'exécute tous les jours)  
✅ **YGG-API Download** actif dans Prowlarr  
✅ **Synchronisation** Prowlarr → Radarr/Sonarr  
✅ **Tests réussis** : Recherches et téléchargements

---

## 📚 Guides connexes

- **[YGGTorrent avec FlareSolverr](yggtorrent-setup.md)** — Solution alternative officielle
- **[Profils YGGTorrent](yggtorrent-profiles.md)** — 3 configurations de seed
- **[Prowlarr](../apps/02-prowlarr.md)** — Configuration complète Prowlarr

---

## ⚙️ Fonctionnement du script

Le script :
1. 📥 Récupère la liste des fichiers YAML depuis le [Gist GitHub](https://gist.github.com/Clemv95/8bfded23ef23ec78f6678896f42a2b60)
2. 📅 Compare les dates de dernière modification
3. ⬇️ Télécharge les mises à jour si nécessaires
4. 🔄 Renomme les IDs pour éviter les doublons (`ygg-api-download`, `ygg-api-magnet`)
5. 🔧 Fixe les permissions (PUID:PGID)
6. 🔄 Redémarre Prowlarr uniquement si changements détectés

**Avantages** :
- ✅ Future-proof : Nouveaux fichiers automatiquement détectés
- ✅ Intelligent : Ne redémarre que si nécessaire
- ✅ Minimal : Pas de redémarrage quotidien inutile

---

**🎉 YGG-API est maintenant configuré et se mettra à jour automatiquement !**

**Crédits :** Script basé sur le travail de [Clemv95](https://gist.github.com/Clemv95) et la communauté YGG-API.
