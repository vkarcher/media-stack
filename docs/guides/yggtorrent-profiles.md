# 🎚️ Profils YGGTorrent : 3 Configurations

> Choisissez votre profil de seed selon vos priorités : sécurité du compte, bande passante, ou prise de risque

**⚠️ AVERTISSEMENT IMPORTANT**

YGGTorrent est un **tracker privé** avec des règles strictes. Ne pas les respecter peut entraîner :
- 🚨 Avertissements multiples
- 🚫 Suspension du compte
- ❌ **Ban permanent** (impossible de recréer un compte)

**Ce guide présente 3 profils avec leurs risques clairement indiqués.**

---

## 📖 Table des matières

1. [Comparaison des 3 profils](#-comparaison-des-3-profils)
2. [🟢 Profil 1 : "Légit" (Recommandé)](#-profil-1--légit-recommandé)
3. [🟡 Profil 2 : "Équilibré" (Compromis)](#-profil-2--équilibré-compromis)
4. [🔴 Profil 3 : "Risqué" (À vos risques)](#-profil-3--risqué-à-vos-risques)
5. [Tableau récapitulatif](#-tableau-récapitulatif)
6. [FAQ](#-faq)

---

## 📊 Comparaison des 3 profils

| Critère | 🟢 Légit | 🟡 Équilibré | 🔴 Risqué |
|---------|----------|--------------|-----------|
| **Ratio YGG** | 1.0+ | 0.6 | 0.0-0.3 |
| **Seed time** | Illimité | 3 jours min | 0-1 jour |
| **Risque ban** | ❌ Aucun | ⚠️ Faible | 🚨 **ÉLEVÉ** |
| **Hit & Run** | Jamais | Rare | Fréquent |
| **Bande passante** | ⚠️ Élevée | ✅ Modérée | ✅ Minimale |
| **Upload requis** | Important | Modéré | Minimal/Nul |
| **Compte sécurisé** | ✅ Oui | ✅ Oui | ❌ **Non** |
| **Niveau technique** | ⭐ Facile | ⭐⭐ Moyen | ⭐⭐⭐ Avancé |

---

## 🟢 Profil 1 : "Légit" (Recommandé)

### 🎯 Pour qui ?

- ✅ Vous voulez un compte YGG **pérenne** et sécurisé
- ✅ Vous avez une **bonne connexion** (fibre, ADSL illimité)
- ✅ Vous voulez respecter les règles de la communauté
- ✅ Vous **ne voulez aucun risque** de ban

### 📊 Objectifs

- **Ratio YGG :** 1.0 ou plus
- **Seed time :** Illimité (ou très long)
- **Hit & Run :** Aucun
- **Statut YGG :** Contributeur actif

---

### ⚙️ Configuration qBittorrent

**1. Options > BitTorrent > Seeding Limits**

```yaml
When ratio reaches: 2.0
  Then: Pause torrent (ne pas supprimer)

When seeding time reaches: DÉSACTIVÉ
  (ou 30 jours minimum)

When inactive seeding time reaches: DÉSACTIVÉ
```

**Explication :**
- Ratio 2.0 = Vous uploadez **2x** ce que vous téléchargez
- Pause (pas supprimer) = Évite les Hit & Run
- Temps illimité = Seedez aussi longtemps que possible

**2. Options > Connection**

```yaml
Upload Rate Limit: Unlimited
  (ou au moins 5 MB/s si fibre)

Max Connections: 500
Max Uploads Slots: 50
```

**Explication :**
- Upload illimité = Maximum de contribution
- Connexions élevées = Seedez vers plus d'utilisateurs

**3. Options > Advanced**

```yaml
Always announce to all trackers: ✅ Enabled
```

---

### ⚙️ Configuration Radarr

**Settings > Download Clients > qBittorrent > Edit**

```yaml
Remove Completed: ❌ Disabled
  (ne jamais supprimer automatiquement)

Remove Failed: ❌ Disabled

Initial State: Start
Priority: Normal
```

**Explication :**  
Radarr ne supprimera JAMAIS les torrents, même après import.

---

### ⚙️ Configuration Sonarr

**Identique à Radarr :**

```yaml
Remove Completed: ❌ Disabled
Remove Failed: ❌ Disabled
```

---

### 📈 Résultats attendus

Après 1 mois d'utilisation :
- **Ratio YGG :** 1.5 - 3.0+
- **Bonus points :** Accumulation constante
- **Hit & Run :** 0
- **Statut compte :** Excellent contributeur

### 💡 Astuces pour maximiser le ratio

1. **Seedez les Freeleech** :
   - Ne comptent pas dans votre download
   - Parfait pour booster le ratio

2. **Gardez les vieux torrents** :
   - Films/séries populaires
   - Vous seederez toujours un peu

3. **Utilisez les bonus points** :
   - YGG : 600 points = 1 GB d'upload gratuit
   - Convertissez régulièrement

4. **Privilégiez les petits fichiers** :
   - Plus facile d'atteindre ratio 2.0 sur 2 GB que 20 GB

---

### ⚠️ Inconvénients

- ❌ Bande passante upload importante
- ❌ Espace disque occupé (torrents jamais supprimés)
- ❌ qBittorrent toujours actif en arrière-plan

---

## 🟡 Profil 2 : "Équilibré" (Compromis)

### 🎯 Pour qui ?

- ✅ Vous voulez un compte YGG **sûr** sans ban
- ✅ Vous avez une **bande passante limitée**
- ✅ Vous acceptez de seeder **le minimum requis**
- ✅ Vous voulez un **bon compromis** sécurité/performance

### 📊 Objectifs

- **Ratio YGG :** 0.6 - 1.0
- **Seed time :** 3 jours minimum (règle YGG)
- **Hit & Run :** Rare (si upload rapide)
- **Statut YGG :** Membre en règle

---

### ⚙️ Configuration qBittorrent

**1. Options > BitTorrent > Seeding Limits**

```yaml
When ratio reaches: 0.6
  OR
When seeding time reaches: 4320 minutes (3 jours)
  Then: Pause torrent (ne pas supprimer)

Whichever comes first
```

**Explication :**
- Ratio 0.6 = Juste au-dessus du minimum YGG (0.5)
- **OU** 3 jours = Respecte la règle anti-Hit & Run
- Pause = Le torrent reste dans qBittorrent mais ne seed plus

**2. Options > Connection**

```yaml
Upload Rate Limit: 1 MB/s
  (ou 500 KB/s si connexion faible)

Max Connections: 200
Max Uploads Slots: 20
```

**Explication :**
- Upload limité = Économise bande passante
- Mais assez pour atteindre ratio 0.6 en 3 jours

**3. Options > Downloads**

```yaml
Keep incomplete torrents in: /torrents/incomplete
Delete .torrent files afterwards: ❌ No
Preallocate disk space: ✅ Yes
```

---

### ⚙️ Configuration Radarr

**Settings > Download Clients > qBittorrent > Edit**

```yaml
Remove Completed: ❌ Disabled
  (laisser qBittorrent gérer via ses propres règles)

Remove Failed: ✅ Enabled
  (supprimer seulement les échecs)

Initial State: Start
Priority: Normal

Client Priority: 1
```

**Explication :**
- qBittorrent mettra en pause automatiquement après 3 jours
- Radarr ne supprime rien, evite les Hit & Run

---

### ⚙️ Configuration Sonarr

Identique à Radarr.

---

### 📈 Résultats attendus

Après 1 mois d'utilisation :
- **Ratio YGG :** 0.6 - 0.9
- **Bonus points :** Accumulation lente mais régulière
- **Hit & Run :** 0-2 (acceptable)
- **Statut compte :** Membre en règle

### 💡 Astuces pour ce profil

1. **Surveillez votre ratio YGG** régulièrement
   - Si < 0.5 → Seedez plus longtemps ou téléchargez moins

2. **Priorité aux Freeleech** quand possible
   - Ne comptent pas dans le download
   - Boostent le ratio gratuitement

3. **Nettoyez les torrents en pause** (occasionnellement)
   - qBittorrent > Filtres > Paused
   - Supprimez ceux de +6 mois (garde-fous)

4. **Convertissez vos bonus points** si ratio < 0.6
   - 600 points = 1 GB upload gratuit

---

### ⚠️ Inconvénients

- ⚠️ Ratio limite (0.6) = Moins de priorité sur nouveaux torrents
- ⚠️ Nécessite surveillance mensuelle du compte YGG
- ⚠️ Quelques Hit & Run possibles si mauvaise connexion

---

## 🔴 Profil 3 : "Risqué" (À vos risques)

### 🚨 AVERTISSEMENT CRITIQUE

**CE PROFIL VIOLE LES RÈGLES DE YGGTORRENT**

**Conséquences probables :**
- 🚨 **Hit & Run multiples** détectés
- ⚠️ -10 points par Hit & Run
- 🚫 **Suspension après 5 Hit & Run**
- ❌ **Ban permanent** du compte YGG
- 💔 **Impossible de recréer un compte** (IP/email blacklistés)

**Utilisation à vos risques et périls. Ce guide est fourni à titre informatif uniquement.**

---

### 🎯 Pour qui ?

- ⚠️ Vous acceptez le **risque de ban permanent**
- ⚠️ Vous avez une **bande passante très limitée**
- ⚠️ Vous voulez **minimiser l'upload**
- ❌ **Vous comprenez et acceptez les conséquences**

### 📊 "Objectifs"

- **Ratio YGG :** 0.0 - 0.3 (mauvais)
- **Seed time :** Minimal (0-24h)
- **Hit & Run :** Fréquent (⚠️ DÉTECTÉ PAR YGG)
- **Statut YGG :** ❌ À risque imminent

---

### ⚙️ Configuration qBittorrent

**1. Options > BitTorrent > Seeding Limits**

```yaml
When ratio reaches: 0.1
  OR
When seeding time reaches: 1440 minutes (24h)
  Then: ⚠️ Remove torrent

Whichever comes first
```

**⚠️ Explication :**
- Ratio 0.1 = Upload quasi-nul
- 24h = Très court (règle YGG = 3 jours minimum)
- **Remove = SUPPRESSION → Hit & Run garanti**

**2. Options > Connection**

```yaml
Upload Rate Limit: 50 KB/s
  (upload minimal)

Max Connections: 50
Max Uploads Slots: 5
```

**⚠️ Explication :**
- Upload volontairement bridé
- Connexions limitées

---

### ⚙️ Configuration Radarr

**Settings > Download Clients > qBittorrent > Edit**

```yaml
Remove Completed: ✅ Enabled
Remove Failed: ✅ Enabled

Initial State: Start
Priority: Normal
```

**⚠️ Explication :**
- Radarr supprime automatiquement après import
- **CECI CRÉE DES HIT & RUN**

---

### ⚙️ Configuration Sonarr

Identique à Radarr.

---

### 📉 Résultats attendus

Après 1 semaine d'utilisation :
- **Ratio YGG :** 0.1 - 0.3
- **Hit & Run :** 5-10+
- **Avertissements YGG :** Multiples
- **Ban :** ⚠️ **IMMINENT** (2-4 semaines max)

---

### 🛡️ "Stratégies" pour retarder le ban (non garanties)

**1. Alterner téléchargements/pause**
- Téléchargez 2-3 fichiers
- Attendez 1 semaine
- Répétez

**2. Seedez quelques Freeleech**
- Compensez partiellement le ratio
- Accumul

ez des bonus points

**3. Utilisez un compte "sacrificiel"**
- ⚠️ Compte secondaire pour tester
- Si ban, pas de perte majeure

**4. Surveillez les avertissements**
- YGG envoie des emails
- Si 3+ avertissements → ARRÊTEZ immédiatement

---

### ❌ Pourquoi ce profil est une MAUVAISE IDÉE

1. **Ban quasi-garanti** en 2-4 semaines
2. **Impossible de recréer un compte** YGG (IP/email bloqués)
3. **Perte d'accès** au meilleur tracker francophone
4. **Mauvaise réputation** dans la communauté
5. **Alternatives meilleures existent** (voir ci-dessous)

---

### 💡 Alternatives recommandées au Profil 3

Au lieu de risquer le ban, considérez :

**1. Seedbox externe (5-10€/mois)**
- Seed 24/7 avec ratio excellent
- Aucun impact sur votre bande passante
- Exemples : Seedboxco, Ultra.cc, Whatbox

**2. Profil Équilibré + Freeleech**
- Téléchargez **uniquement** des Freeleech
- Ratio ne descend jamais
- Seedez juste 3 jours

**3. Usenet (alternative à BitTorrent)**
- Pas de ratio requis
- Téléchargements très rapides
- ~10€/mois (Newshosting, Eweka)

**4. Trackers publics** (pas de ratio)
- YTS, EZTV, The Pirate Bay
- Moins de contenu français
- Mais aucun risque de ban

---

## 📊 Tableau récapitulatif

| Aspect | 🟢 Légit | 🟡 Équilibré | 🔴 Risqué |
|--------|----------|--------------|-----------|
| **Ratio cible** | 1.0 - 2.0+ | 0.6 - 1.0 | 0.0 - 0.3 |
| **Seed time** | Illimité | 3 jours min | 0-24h |
| **Upload limit** | Unlimited | 500 KB - 1 MB/s | 50 KB/s |
| **Remove torrent** | Jamais (pause) | Jamais (pause) | Après 24h ❌ |
| **Hit & Run** | 0 | 0-2 | 5-10+ |
| **Risque ban** | 0% | <5% | **80-100%** |
| **Durée vie compte** | Illimitée | Illimitée | 2-4 semaines |
| **Bande passante** | Élevée | Modérée | Minimale |
| **Recommandation** | ✅ **OUI** | ✅ Acceptable | ❌ **NON** |

---

## 🎯 Quelle configuration choisir ?

### Vous avez la fibre / bonne connexion ?
→ **🟢 Profil Légit** (aucun souci de ban, compte pérenne)

### Vous avez une connexion limitée mais stable ?
→ **🟡 Profil Équilibré** (bon compromis, compte sécurisé)

### Vous avez une très mauvaise connexion ?
→ ⚠️ **Seedbox externe** ou **Usenet** (évitez le Profil Risqué)

### Vous voulez vraiment le Profil Risqué ?
→ ❌ **Reconsidérez**. Les alternatives ci-dessus sont meilleures.

---

## ❓ FAQ

<details>
<summary><strong>Puis-je changer de profil après installation ?</strong></summary>

**Oui, à tout moment !**

1. qBittorrent > Options > BitTorrent > Seeding Limits
2. Modifiez ratio et seed time
3. Save

Effet immédiat sur les **nouveaux** torrents.  
Les torrents en cours conservent leurs règles actuelles.
</details>

<details>
<summary><strong>Mon ratio YGG est à 0.4, je vais être banni ?</strong></summary>

**Pas immédiatement**, mais vous êtes en danger.

**Actions immédiates :**
1. **Arrêtez de télécharger** temporairement
2. **Seedez vos torrents actuels** jusqu'à ratio 0.6+
3. **Téléchargez des Freeleech** et seedez-les
4. **Convertissez bonus points** en upload (600 pts = 1 GB)

YGG donne généralement des **avertissements par email** avant de bannir.
</details>

<details>
<summary><strong>Combien de Hit & Run avant le ban ?</strong></summary>

**Seuil YGGTorrent :**
- **1-2 Hit & Run** : Avertissement email
- **3-4 Hit & Run** : Avertissement sévère
- **5+ Hit & Run** : Suspension temporaire (quelques jours)
- **10+ Hit & Run** : Ban permanent probable

**Chaque Hit & Run = -10 points** sur votre compte.
</details>

<details>
<summary><strong>Qu'est-ce qu'un Hit & Run exactement ?</strong></summary>

Un **Hit & Run** se produit quand :
1. Vous téléchargez un torrent YGG
2. **ET** vous le supprimez avant d'avoir :
   - Ratio 1.0 sur ce torrent
   - **OU** Seedé pendant 3 jours minimum

**Exemple de Hit & Run :**
```
Téléchargement : Film 5 GB
Upload : 2 GB (ratio 0.4)
Seed time : 1 jour
Action : Suppression du torrent
→ ❌ HIT & RUN détecté
```

**Exemple OK :**
```
Téléchargement : Film 5 GB
Upload : 3 GB (ratio 0.6)
Seed time : 3 jours
Action : Pause ou suppression
→ ✅ Pas de Hit & Run
```
</details>

<details>
<summary><strong>Mettre en PAUSE = Supprimer ?</strong></summary>

**Non !**

- **Pause** : Le torrent reste dans qBittorrent, ne seed plus, mais n'est pas supprimé → ✅ Pas de Hit & Run
- **Supprimer** : Le torrent disparaît complètement → ❌ Hit & Run si conditions non remplies

**Recommandation :** Toujours **PAUSER** au lieu de supprimer.
</details>

<details>
<summary><strong>Puis-je utiliser plusieurs profils en même temps ?</strong></summary>

**Non directement**, qBittorrent a des règles globales.

**Mais vous pouvez :**
1. Utiliser **2 instances qBittorrent** (avancé)
2. Utiliser **des tags** dans qBittorrent
3. **Gérer manuellement** certains torrents (clic droit > Propriétés > Seeding Limits)

**Exemple :**
- Profil Équilibré global
- Films/séries importants : règles manuelles "Légit" (ratio 2.0)
</details>

<details>
<summary><strong>Seedbox : ça vaut le coup ?</strong></summary>

**Oui, si votre connexion est limitée.**

**Avantages :**
- ✅ Ratio YGG excellent (généralement 5.0+)
- ✅ Aucun impact sur votre bande passante
- ✅ Téléchargements ultra-rapides
- ✅ Seed 24/7 automatique

**Prix :** 5-15€/mois

**Recommandations :**
- Seedboxco (entrée de gamme)
- Whatbox (meilleur rapport qualité/prix)
- Ultra.cc (premium)

**Alternative :** VPS + auto-setup script (plus technique)
</details>

---

## 📚 Guides connexes

- **[Guide YGGTorrent complet](yggtorrent-setup.md)** — Installation FlareSolverr + YGG
- **[qBittorrent détaillé](../apps/01-qbittorrent.md)** — Toutes les options expliquées
- **[Prowlarr](../apps/02-prowlarr.md)** — Gestion des indexers
- **[Troubleshooting](troubleshooting-advanced.md)** — Problèmes avancés

---

## 🎯 Conclusion

### Recommandation générale

**Pour 99% des utilisateurs :**
- 🟢 **Profil Légit** si bonne connexion
- 🟡 **Profil Équilibré** si connexion limitée
- ❌ **Évitez le Profil Risqué** à tout prix

**Le meilleur investissement :**
Une **seedbox à 5€/mois** > Risquer un ban permanent YGG

---

**🚀 Bon téléchargement, et respectez la communauté !**
