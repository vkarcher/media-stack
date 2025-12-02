# 🛡️ Guide Complet FlareSolverr

> Service de bypass Cloudflare pour vos indexers

**⏱️ Temps estimé :** 10 minutes  
**📊 Niveau :** Intermédiaire  
**🔗 Prérequis :** Docker installé, Prowlarr configuré

**🔗 Ressources officielles :**
- [GitHub FlareSolverr](https://github.com/FlareSolverr/FlareSolverr)
- [Documentation](https://github.com/FlareSolverr/FlareSolverr#readme)

---

## 📖 Table des matières

1. [Qu'est-ce que FlareSolverr ?](#quest-ce-que-flaresolverr-)
2. [Pourquoi en avez-vous besoin ?](#pourquoi-en-avez-vous-besoin-)
3. [Installation](#installation)
4. [Configuration dans Prowlarr](#configuration-dans-prowlarr)
5. [Utilisation avec YGGTorrent](#utilisation-avec-yggtorrent)
6. [Vérification et tests](#vérification-et-tests)
7. [Troubleshooting](#troubleshooting)
8. [FAQ](#faq)

---

## Qu'est-ce que FlareSolverr ?

**FlareSolverr** est un service qui **contourne automatiquement** les protections Cloudflare.

### Comment ça fonctionne ?

```
Sans FlareSolverr:
Prowlarr → YGGTorrent
         ❌ "Please complete this challenge" (Cloudflare)
         ❌ Access denied

Avec FlareSolverr:
Prowlarr → FlareSolverr → YGGTorrent
           (simule navigateur)
           ✅ Cloudflare bypassé
```

**FlareSolverr** :
- Simule un vrai navigateur (Chrome)
- Résout les challenges JavaScript de Cloudflare
- Retourne le contenu à Prowlarr

---

## Pourquoi en avez-vous besoin ?

### Sites utilisant Cloudflare

De nombreux trackers utilisent Cloudflare pour se protéger :

**Trackers français :**
- ✅ **YGGTorrent** (obligatoire)
- ✅ **Sharewood**
- ✅ **GKTorrent**

**Autres trackers :**
- ✅ **1337x**
- ✅ **RARBG** (archives)
- ✅ Et beaucoup d'autres...

### Sans FlareSolverr

Vous verrez ces erreurs dans Prowlarr :
```
❌ "FlareSolverr required for this indexer"
❌ "Cloudflare challenge detected"
❌ "HTTP 403 Forbidden"
```

---

## Installation

### Option A : Ajouter au docker-compose existant (recommandé)

**1. Éditez votre docker-compose**

```bash
ssh admin@<IP_NAS>
sudo -i
cd /volume1/docker
nano docker-compose.yml
```

**2. Ajoutez le service FlareSolverr**

Collez AVANT le dernier `}` (à la fin du fichier) :

```yaml
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=info
      - LOG_HTML=false
      - CAPTCHA_SOLVER=none
      - TZ=Europe/Paris
    ports:
      - 8191:8191
    restart: unless-stopped
```

**3. Sauvegardez**
- `Ctrl + O` → Écrire
- `Entrée` → Confirmer
- `Ctrl + X` → Quitter

**4. Démarrez FlareSolverr**

```bash
docker-compose up -d flaresolverr
```

**5. Vérifiez**

```bash
# Voir les logs
docker-compose logs -f flaresolverr

# Devrait afficher :
# "FlareSolverr is ready!"
```

✅ **Si vous voyez ce message, FlareSolverr est opérationnel !**

---

### Option B : Docker standalone

Si vous n'utilisez pas docker-compose :

```bash
docker run -d \
  --name flaresolverr \
  -p 8191:8191 \
  -e LOG_LEVEL=info \
  -e LOG_HTML=false \
  -e CAPTCHA_SOLVER=none \
  -e TZ=Europe/Paris \
  --restart unless-stopped \
  ghcr.io/flaresolverr/flaresolverr:latest
```

---

### Test de santé

**Vérifiez que FlareSolverr répond :**

```bash
curl http://localhost:8191/health
```

**Réponse attendue :**
```json
{"status":"ok"}
```

✅ Si vous voyez `"status":"ok"`, c'est parfait !

---

## Configuration dans Prowlarr

### Étape 1 : Créer un tag

**1. Prowlarr > Settings > Tags**

🌐 `http://<IP_NAS>:9696`

**2. Add Tag**

```
Tag Label: flaresolverr
```

**3. Save**

---

### Étape 2 : Configurer FlareSolverr

**1. Settings > Indexers**

**2. Section "FlareSolverr"** (faites défiler jusqu'en bas)

**3. Configuration**

| Paramètre | Valeur | Explication |
|-----------|--------|-------------|
| **Tags** | `flaresolverr` | Tag créé à l'étape 1 |
| **Host** | `http://flaresolverr:8191/` | URL du service ⚠️ Avec le `/` final |
| **Max Timeout** | `60` | Secondes (peut aller jusqu'à 120) |

**4. Test de connexion**

- Cliquez sur le bouton **Test** en bas
- ✅ "Connection successful"

Si erreur, vérifiez :
- FlareSolverr est bien démarré : `docker ps | grep flaresolverr`
- URL correcte : `http://flaresolverr:8191/` (avec le **/** à la fin)

**5. Save Settings**

---

## Utilisation avec YGGTorrent

### Assigner le tag FlareSolverr

**Important** : Chaque indexer protégé par Cloudflare doit avoir le tag `flaresolverr`.

**1. Prowlarr > Indexers > YGGTorrent**

**2. Edit (icône crayon)**

**3. Section "Tags"**

```yaml
Tags: flaresolverr
```

✅ Le tag **doit** être coché.

**4. Save**

---

### Vérification

**Test de recherche :**

1. Prowlarr > Search
2. Recherchez : `Matrix`
3. Cliquez **Search**

**Résultats attendus :**
- Vous devriez voir des résultats YGGTorrent 🟢
- Temps de réponse : 5-15 secondes (normal avec Cloudflare)

✅ **Si vous voyez des résultats YGG, FlareSolverr fonctionne parfaitement !**

---

## Vérification et tests

### Test 1 : Santé du service

```bash
curl http://localhost:8191/health
```

**Attendu :** `{"status":"ok"}`

---

### Test 2 : Logs en temps réel

```bash
docker-compose logs -f flaresolverr
```

**Ce que vous devriez voir lors d'une recherche :**
```
Handling request for: http://yggtorrent.top/...
Cloudflare challenge detected
Solving challenge...
✓ Challenge solved in 8.3s
Response sent to Prowlarr
```

---

### Test 3 : Recherche dans Prowlarr

**1. Prowlarr > Indexers > YGGTorrent > Test**

**2. Résultat attendu**

```
✅ All checks have passed
```

Si erreur :
- Vérifiez que le tag `flaresolverr` est bien assigné
- Voir section [Troubleshooting](#troubleshooting)

---

## Troubleshooting

### ❌ "Connection refused" ou "Cannot connect to FlareSolverr"

**Causes possibles :**

**1. FlareSolverr pas démarré**

```bash
docker ps | grep flaresolverr
```

Devrait montrer le container **running**.

Si absent, démarrez-le :
```bash
docker-compose up -d flaresolverr
```

**2. URL incorrecte dans Prowlarr**

Settings > Indexers > FlareSolverr
- ✅ Correct : `http://flaresolverr:8191/`
- ❌ Incorrect : `http://localhost:8191/` (si dans Docker)
- ❌ Incorrect : `http://flaresolverr:8191` (sans le `/`)

**3. Réseau Docker**

Vérifiez que Prowlarr et FlareSolverr sont sur le même réseau Docker.

```bash
docker inspect prowlarr | grep -i network
docker inspect flaresolverr | grep -i network
```

Doivent être identiques.

---

### ❌ "Timeout" ou "Challenge solving failed"

**Causes :**

**1. Timeout trop court**

Settings > Indexers > FlareSolverr
- Max Timeout : `90` ou `120` secondes

**2. Cloudflare a évolué**

FlareSolverr nécessite une mise à jour.

```bash
docker-compose pull flaresolverr
docker-compose up -d flaresolverr
```

**3. Captcha manuel requis**

Certains challenges Cloudflare sont trop complexes.

**Solution :** Activez le solver de captcha (avancé, non recommandé)

---

### ⚠️ FlareSolverr très lent (30+ secondes)

**C'est normal** pour Cloudflare complexe.

**Optimisations possibles :**

**1. Augmentez les ressources Docker**

Éditez `docker-compose.yml` :

```yaml
  flaresolverr:
    ...
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
```

**2. Réduisez le nombre d'indexers utilisant FlareSolverr**

Gardez seulement les essentiels (YGGTorrent).

---

### 🔴 Erreur "Browser crashed" ou "Chrome not responding"

**Cause :** Manque de mémoire ou problème Chrome headless.

**Solutions :**

**1. Redémarrez FlareSolverr**

```bash
docker-compose restart flaresolverr
```

**2. Augmentez la mémoire**

```yaml
  flaresolverr:
    ...
    deploy:
      resources:
        limits:
          memory: 2G  # Au lieu de 1G
```

**3. Nettoyez les logs**

```bash
docker-compose logs flaresolverr > /dev/null
```

---

### ❌ "Invalid JSON response"

**Cause :** FlareSolverr retourne une réponse invalide.

**Solutions :**

**1. Vérifiez la version**

```bash
docker inspect flaresolverr | grep Image
```

Devrait être : `ghcr.io/flaresolverr/flaresolverr:latest`

**2. Mettez à jour**

```bash
docker-compose pull flaresolverr
docker-compose up -d flaresolverr
```

---

## FAQ

<details>
<summary><strong>FlareSolverr consomme beaucoup de ressources ?</strong></summary>

**Ressources moyennes :**
- **CPU** : 5-10% au repos, 30-50% lors de résolution
- **RAM** : 200-500 MB
- **Disque** : ~200 MB

C'est **acceptable** pour un NAS Synology DS224+.
</details>

<details>
<summary><strong>Combien de temps met FlareSolverr pour résoudre Cloudflare ?</strong></summary>

**Temps moyens :**
- Challenge simple : 5-10 secondes
- Challenge complexe : 15-30 secondes
- Timeout après : 60-120 secondes (selon config)

**C'est normal** que ce soit plus lent qu'un tracker sans Cloudflare.
</details>

<details>
<summary><strong>Puis-je utiliser FlareSolverr pour plusieurs indexers ?</strong></summary>

**Oui !** FlareSolverr peut gérer plusieurs indexers simultanément.

Il suffit d'assigner le tag `flaresolverr` à chaque indexer protégé par Cloudflare.

**Exemples :**
- YGGTorrent
- Sharewood
- 1337x
- GKTorrent
</details>

<details>
<summary><strong>FlareSolverr fonctionne avec Usenet ?</strong></summary>

**Non.** FlareSolverr est uniquement pour les sites **web** protégés par Cloudflare.

Usenet n'utilise pas Cloudflare donc pas besoin de FlareSolverr.
</details>

<details>
<summary><strong>Est-ce légal d'utiliser FlareSolverr ?</strong></summary>

**FlareSolverr lui-même est légal** : c'est juste un outil pour automatiser la navigation web.

L'**usage** dépend du contenu téléchargé (voir législation locale).
</details>

<details>
<summary><strong>Cloudflare peut-il détecter FlareSolverr ?</strong></summary>

**Techniquement oui**, mais FlareSolverr simule un navigateur réel (Chrome).

En pratique :
- ✅ Fonctionne pour 99% des sites
- ⚠️ Certains sites très protégés peuvent nécessiter captcha manuel
- 🔄 FlareSolverr est régulièrement mis à jour pour contourner les nouvelles protections
</details>

---

## 📊 Résumé configuration

```yaml
# Docker
Service: flaresolverr
Image: ghcr.io/flaresolverr/flaresolverr:latest
Port: 8191
Status: ✅ Running

# Prowlarr
FlareSolverr Host: http://flaresolverr:8191/
Tag: flaresolverr
Timeout: 60-120s

# Indexers avec FlareSolverr
YGGTorrent: Tag flaresolverr ✅
Sharewood: Tag flaresolverr ✅
1337x: Tag flaresolverr ✅
```

---

## 📚 Guides connexes

- **[YGGTorrent Setup](../guides/yggtorrent-setup.md)** — Installation complète YGG
- **[Prowlarr](02-prowlarr.md)** — Configuration indexers
- **[Troubleshooting avancé](../guides/troubleshooting-advanced.md)** — Problèmes complexes

---

**✅ FlareSolverr est maintenant configuré et opérationnel !**

Vous pouvez maintenant utiliser YGGTorrent et autres trackers protégés par Cloudflare sans problème !
