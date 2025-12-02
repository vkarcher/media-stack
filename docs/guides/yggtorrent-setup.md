# 🇫🇷 Guide Complet YGGTorrent + FlareSolverr

> Configuration complète pour utiliser YGGTorrent (tracker privé français) avec votre stack média

**⏱️ Temps estimé :** 20-30 minutes  
**📊 Niveau :** Intermédiaire  
**⚠️ Prérequis :** Stack média installée, compte YGGTorrent actif

---

## 📖 Table des matières

1. [Qu'est-ce que YGGTorrent ?](#quest-ce-que-yggtorrent-)
2. [Pourquoi FlareSolverr est nécessaire](#pourquoi-flaresolverr-est-nécessaire)
3. [Étape 1 : Installer FlareSolverr](#étape-1--installer-flaresolverr)
4. [Étape 2 : Configurer FlareSolverr dans Prowlarr](#étape-2--configurer-flaresolverr-dans-prowlarr)
5. [Étape 3 : Récupérer votre Passkey YGG](#étape-3--récupérer-votre-passkey-ygg)
6. [Étape 4 : Ajouter YGGTorrent dans Prowlarr](#étape-4--ajouter-yggtorrent-dans-prowlarr)
7. [Étape 5 : Synchroniser avec Radarr/Sonarr](#étape-5--synchroniser-avec-radarrsonarr)
8. [Étape 6 : Test et validation](#étape-6--test-et-validation)
9. [Troubleshooting](#troubleshooting)
10. [FAQ](#faq)

---

## Qu'est-ce que YGGTorrent ?

**YGGTorrent** (anciennement Yggtorrent, T411, etc.) est le **plus grand tracker BitTorrent francophone**.

### Avantages
- ✅ **Contenu français** : Films, séries, documentaires VF/VOST
- ✅ **Releases rapides** : Nouveautés souvent dispo le jour même
- ✅ **Qualité** : Encodages de qualité (Bluray, WEB-DL, etc.)
- ✅ **Communauté active** : Aide, demandes, sous-titres

### Inconvénients
- ❌ **Tracker privé** : Inscription obligatoire (parfois fermée)
- ❌ **Ratio obligatoire** : Minimum 0.5, recommandé 1.0+
- ❌ **Protection Cloudflare** : Nécessite FlareSolverr
- ❌ **Hit & Run** : Pénalités si suppression avant 3 jours

### URL actuelle
🌐 **http://yggtorrent.top** (change régulièrement, vérifiez sur r/yggtorrent)

---

## Pourquoi FlareSolverr est nécessaire

YGGTorrent utilise **Cloudflare** pour se protéger contre les bots et le scraping.

### Sans FlareSolverr
```
Prowlarr → YGGTorrent
         ❌ "Cloudflare challenge detected"
         ❌ "Access denied"
```

### Avec FlareSolverr
```
Prowlarr → FlareSolverr → YGGTorrent
           (bypass Cloudflare)   ✅
```

**FlareSolverr** simule un vrai navigateur pour passer les vérifications Cloudflare.

---

## Étape 1 : Installer FlareSolverr

### Option A : Ajouter au docker-compose existant

**1. Ouvrez le fichier docker-compose**

```bash
ssh admin@<IP_NAS>
sudo -i
cd /volume1/docker
nano docker-compose.yml
```

**2. Ajoutez ce service à la fin** (avant la dernière ligne) :

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

**3. Sauvegardez** :
- `Ctrl + O` (Écrire)
- `Entrée` (Confirmer)
- `Ctrl + X` (Quitter)

**4. Démarrez FlareSolverr** :

```bash
docker-compose up -d flaresolverr
```

**5. Vérifiez que ça fonctionne** :

```bash
# Test de santé
curl http://localhost:8191/health

# Devrait retourner :
# {"status":"ok"}

# Voir les logs
docker-compose logs -f flaresolverr
```

✅ **Si vous voyez `FlareSolverr is ready!` dans les logs, c'est bon !**

---

### Option B : Docker standalone (si pas de docker-compose)

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

## Étape 2 : Configurer FlareSolverr dans Prowlarr

**1. Accédez à Prowlarr**

🌐 `http://<IP_NAS>:9696`

**2. Allez dans Settings**

- Cliquez sur **Settings** (icône ⚙️ en haut à droite)
- Onglet **Indexers**

**3. Section "FlareSolverr"**

Faites défiler jusqu'à trouver la section **FlareSolverr**.

**4. Créez un tag** (si pas déjà fait)

- Settings > Tags
- Add Tag : `flaresolverr` ou `cloudflare`
- Save

**5. Configurez FlareSolverr**

| Paramètre | Valeur |
|-----------|--------|
| **Tags** | `flaresolverr` *(tag créé à l'étape 4)* |
| **Host** | `http://flaresolverr:8191/` |
| **Max Timeout** | `60` (secondes) |

📸 **Exemple de configuration** :
```
Tags: [flaresolverr]
Host: http://flaresolverr:8191/
Max Timeout: 60
```

**6. Test de connexion**

- Cliquez sur le bouton **Test** en bas
- Devrait afficher ✅ **"Connection successful"**
- Si erreur, vérifiez :
  - FlareSolverr est bien démarré (`docker ps | grep flaresolverr`)
  - URL correcte : `http://flaresolverr:8191/` (avec le `/` à la fin)

**7. Save Settings**

---

## Étape 3 : Récupérer votre Passkey YGG

Votre **Passkey** est une clé unique qui vous identifie sur YGGTorrent.

### Comment obtenir votre Passkey

**1. Connectez-vous sur YGGTorrent**

🌐 http://yggtorrent.top

**2. Allez dans votre profil**

- Cliquez sur votre pseudo (en haut à droite)
- **Mon Compte** > **Profil**

**3. Trouvez votre Passkey**

Cherchez une section **"Passkey"** ou **"Clé personnelle"**.

📋 Exemple :
```
Passkey: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**⚠️ NE PARTAGEZ JAMAIS VOTRE PASSKEY !**

C'est comme un mot de passe. Si quelqu'un l'utilise, c'est **votre compte** qui sera banni.

**4. Copiez votre Passkey**

- Sélectionnez toute la chaîne
- Ctrl+C (copier)
- Gardez-la dans un fichier texte temporaire

---

## Étape 4 : Ajouter YGGTorrent dans Prowlarr

**1. Prowlarr > Indexers > Add Indexer**

🌐 `http://<IP_NAS>:9696`

**2. Recherchez "YGG"**

- Dans la barre de recherche, tapez `YGG`
- Sélectionnez **YGGTorrent**

**3. Configuration de base**

| Paramètre | Valeur | Explication |
|-----------|--------|-------------|
| **Name** | `YGGTorrent` | Nom affiché dans Prowlarr |
| **Enable** | ✅ Oui | Active l'indexer |
| **Redirect** | ❌ Non | Pas besoin de redirection |
| **Priority** | `25` | Priorité moyenne (1-50, plus haut = prioritaire) |
| **Tags** | `flaresolverr` | ⚠️ **IMPORTANT** : Tag créé précédemment |

**💡 Pourquoi le tag est important ?**

Le tag `flaresolverr` indique à Prowlarr : **"Utilise FlareSolverr pour cet indexer"**.

Sans ce tag, Prowlarr essaiera d'accéder directement à YGG → ❌ Erreur Cloudflare.

---

**4. Authentification**

| Paramètre | Valeur |
|-----------|--------|
| **Username** | Votre login YGG |
| **Password** | Votre mot de passe YGG |
| **Passkey** | *(Collé depuis l'étape 3)* |

**5. Options avancées**

| Paramètre | Valeur | Recommandation |
|-----------|--------|----------------|
| **Multi Languages** | ✅ Activé | Pour avoir VF + VOST |
| **Minimum Seeders** | `1` | Évite les torrents morts |
| **Seed Ratio** | `1.0` | Pour respecter les règles YGG |

**6. Catégories**

Cochez au minimum :
- ✅ **Movies** (Films)
- ✅ **TV** (Séries)
- ✅ **TV/Anime** (Animés, si vous en voulez)

**7. Test & Save**

- Cliquez sur **Test** en bas
- ✅ Devrait afficher "All checks have passed"
- Cliquez sur **Save**

### Résultat attendu

YGGTorrent devrait maintenant apparaître dans :
- Prowlarr > Indexers (avec icône verte 🟢)

---

## Étape 5 : Synchroniser avec Radarr/Sonarr

Prowlarr va automatiquement **pousser** YGGTorrent vers Radarr et Sonarr.

### Vérification automatique

**1. Allez dans Prowlarr > Settings > Apps**

Vous devriez déjà voir :
- **Radarr** (configuré précédemment)
- **Sonarr** (configuré précédemment)

**2. Cliquez sur "Sync App Indexers"**

Ou attendez 15 minutes (sync automatique toutes les 15min).

**3. Vérifiez dans Radarr**

🌐 `http://<IP_NAS>:7878`

- Settings > Indexers
- **YGGTorrent devrait apparaître** dans la liste !

**4. Vérifiez dans Sonarr**

🌐 `http://<IP_NAS>:8989`

- Settings > Indexers
- **YGGTorrent devrait apparaître** dans la liste !

✅ **Si YGGTorrent est présent dans les deux, c'est parfait !**

---

## Étape 6 : Test et validation

### Test 1 : Recherche manuelle dans Prowlarr

**1. Prowlarr > Search**

🌐 `http://<IP_NAS>:9696`

**2. Recherchez un film/série français**

Exemples :
- `Le Comte de Monte-Cristo 2024`
- `Lupin`
- `AKA`

**3. Cliquez sur Search**

**4. Résultats attendus**

Vous devriez voir des résultats de **YGGTorrent** avec :
- Logo YGG 🟢
- Seeders/Leechers
- Taille du fichier
- Langues (VF, VOST)

✅ **Si vous voyez des résultats YGG, FlareSolverr fonctionne !**

---

### Test 2 : Téléchargement automatique via Radarr

**1. Radarr > Movies > Add New Movie**

🌐 `http://<IP_NAS>:7878`

**2. Recherchez un film français récent**

Exemple : `Le Comte de Monte-Cristo`

**3. Ajoutez le film**

- Sélectionnez le film
- Quality Profile : Any (ou votre profil)
- Root Folder : `/movies`
- Monitor : Yes
- **Cliquez sur Add Movie**

**4. Lancez la recherche**

- Cliquez sur le film ajouté
- Bouton **Search** (icône 🔍)

**5. Vérifiez les résultats**

- Onglet **Activity** (en haut)
- Ou **Queue** pour voir les téléchargements

✅ **Si Radarr trouve des résultats YGG et commence à télécharger, tout fonctionne !**

---

### Test 3 : Téléchargement automatique via Sonarr

**1. Sonarr > Series > Add New Series**

🌐 `http://<IP_NAS>:8989`

**2. Recherchez une série française**

Exemple : `Lupin`

**3. Ajoutez la série**

- Root Folder : `/series`
- Monitor : All Episodes
- **Add Series**

**4. Recherchez un épisode**

- Cliquez sur la série
- Sélectionnez un épisode
- **Search** (icône 🔍)

✅ **Série trouvée et téléchargée = succès !**

---

## Troubleshooting

### ❌ Erreur "Cloudflare challenge failed"

**Cause :** FlareSolverr n'est pas utilisé ou ne fonctionne pas.

**Solutions :**

1. **Vérifier que FlareSolverr tourne** :
   ```bash
   docker ps | grep flaresolverr
   # Devrait montrer le container running
   ```

2. **Test direct de FlareSolverr** :
   ```bash
   curl http://localhost:8191/health
   # {"status":"ok"}
   ```

3. **Vérifier le tag dans Prowlarr** :
   - Prowlarr > Indexers > YGGTorrent > Edit
   - Tag `flaresolverr` bien coché ✅
   - Save

4. **Relancer FlareSolverr** :
   ```bash
   docker-compose restart flaresolverr
   docker-compose logs -f flaresolverr
   ```

5. **Augmenter le timeout** :
   - Prowlarr > Settings > Indexers > FlareSolverr
   - Max Timeout : `90` secondes
   - Save

---

### ❌ "Authentication failed" ou "Invalid credentials"

**Cause :** Login/mot de passe/Passkey incorrect.

**Solutions :**

1. **Vérifier vos identifiants** :
   - Connectez-vous manuellement sur http://yggtorrent.top
   - Username et password corrects ?

2. **Vérifier la Passkey** :
   - YGG > Mon Compte > Profil
   - Copiez à nouveau la Passkey
   - Collez dans Prowlarr (sans espaces)

3. **Recréer l'indexer** :
   - Prowlarr > Indexers > YGGTorrent
   - Delete
   - Add Indexer > YGGTorrent (recommencer depuis l'étape 4)

4. **Compte YGG banni/suspendu ?** :
   - Vérifiez votre ratio sur YGG
   - Hit & Run trop élevés ?
   - Contactez le support YGG

---

### ❌ Pas de résultats de recherche

**Cause :** Catégories mal configurées ou recherche trop spécifique.

**Solutions :**

1. **Test manuel dans Prowlarr** :
   - Prowlarr > Search
   - Cherchez quelque chose de simple : `matrix`
   - YGGTorrent devrait retourner des résultats

2. **Vérifier les catégories** :
   - Prowlarr > Indexers > YGGTorrent > Edit
   - Categories : ✅ Movies, TV, TV/Anime
   - Save

3. **Recherche trop spécifique** :
   - Essayez sans l'année : `Matrix` au lieu de `Matrix 2024`
   - Essayez en anglais : YGG a aussi du contenu VO

4. **Logs détaillés** :
   ```bash
   docker-compose logs -f prowlarr | grep -i ygg
   ```

---

### ⚠️ "Rate limit exceeded"

**Cause :** Trop de requêtes vers YGG en peu de temps.

**Solutions :**

1. **Attendez 5-10 minutes**
2. **Réduisez la fréquence de recherche** :
   - Radarr/Sonarr > Settings > Indexers
   - RSS Sync Interval : `30` minutes (au lieu de 15)

---

### ❌ FlareSolverr timeout

**Cause :** FlareSolverr met trop de temps à résoudre Cloudflare.

**Solutions :**

1. **Augmenter le timeout** :
   - Prowlarr > Settings > Indexers > FlareSolverr
   - Max Timeout : `120` secondes

2. **Redémarrer FlareSolverr** :
   ```bash
   docker-compose restart flaresolverr
   ```

3. **Vérifier les ressources** :
   ```bash
   docker stats flaresolverr
   ```
   - Si CPU/RAM à 100%, augmentez les ressources

---

## FAQ

<details>
<summary><strong>Combien de temps FlareSolverr met pour résoudre Cloudflare ?</strong></summary>

**Généralement 5-15 secondes** pour chaque requête.

C'est normal que ce soit plus lent qu'un tracker sans Cloudflare.
</details>

<details>
<summary><strong>FlareSolverr consomme beaucoup de ressources ?</strong></summary>

**Ressources moyennes :**
- CPU : 5-10% (pics à 50% lors des requêtes)
- RAM : 200-400 MB

C'est acceptable pour un NAS Synology DS224+.
</details>

<details>
<summary><strong>Puis-je utiliser FlareSolverr pour d'autres trackers ?</strong></summary>

**Oui !** FlareSolverr fonctionne avec tous les sites protégés par Cloudflare.

Exemples :
- Autres trackers français
- Sites de streaming (si vous avez des indexers)

Ajoutez simplement le tag `flaresolverr` à l'indexer dans Prowlarr.
</details>

<details>
<summary><strong>YGGTorrent change d'URL régulièrement, que faire ?</strong></summary>

**Prowlarr se met à jour automatiquement** dans la plupart des cas.

Si l'URL change et Prowlarr ne suit pas :
1. Prowlarr > Indexers > YGGTorrent > Edit
2. Cherchez un champ **"Base URL"**
3. Mettez à jour avec la nouvelle URL (ex: `http://yggtorrent.top`)
4. Save

Ou attendez une mise à jour de Prowlarr (généralement sous 24-48h).
</details>

<details>
<summary><strong>Mon ratio YGG est de 0.3, je vais être banni ?</strong></summary>

**Risque modéré.** YGGTorrent exige un ratio minimum de **0.5**.

**Solutions immédiates :**
1. **Seedez vos torrents** actuels plus longtemps
2. **Téléchargez des Freeleech** (ne comptent pas dans le download)
3. **Convertissez vos bonus points** en upload (600 points = 1 GB)
4. **Réduisez vos téléchargements** temporairement

**Voir aussi :** [Guide Profils YGGTorrent](yggtorrent-profiles.md)
</details>

<details>
<summary><strong>Puis-je utiliser YGGTorrent sans FlareSolverr ?</strong></summary>

**Non, pas via Prowlarr.**

YGGTorrent impose Cloudflare, donc FlareSolverr est **obligatoire**.

Alternatives (non recommandées) :
- Télécharger manuellement depuis le site YGG
- Utiliser Jackett (mais pose les mêmes problèmes)
</details>

---

## 🎯 Résumé : Configuration complète

Si vous avez suivi ce guide, vous devriez avoir :

✅ **FlareSolverr** installé et fonctionnel (port 8191)  
✅ **Prowlarr** configuré avec FlareSolverr (tag `flaresolverr`)  
✅ **YGGTorrent** ajouté dans Prowlarr (avec Passkey)  
✅ **Synchronisation** Prowlarr → Radarr/Sonarr  
✅ **Tests réussis** : Recherches manuelles et automatiques

---

## 📚 Guides connexes

- **[Profils YGGTorrent](yggtorrent-profiles.md)** — 3 configurations de seed (Légit / Équilibré / Risqué)
- **[FlareSolverr détaillé](../apps/07-flaresolverr.md)** — Guide complet FlareSolverr
- **[Prowlarr](../apps/02-prowlarr.md)** — Configuration complète Prowlarr
- **[Troubleshooting avancé](troubleshooting-advanced.md)** — Problèmes complexes

---

**🎉 Félicitations ! YGGTorrent est maintenant configuré et fonctionnel !**

Prochaine étape : [Choisir votre profil de seed](yggtorrent-profiles.md) (Légit / Équilibré / Risqué)
