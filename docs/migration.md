# 📦 Migration

Reprendre une installation existante sans perdre les comptes, l'historique de visionnage, les bibliothèques ni les seeds.

Rien de tout ça n'est fatalement perdu. Mais l'ordre compte, et deux ou trois détails décident du résultat.

---

## Le principe qui fait tout

> **Jellyfin et les *arr identifient leurs fichiers PAR CHEMIN.** Chemin changé = bibliothèque vide et suivi perdu.

Et le levier :

> **Jellyfin n'a aucun besoin de hardlink** — il ne fait que lire.

Donc rien ne l'oblige à partager le montage unique `/data` des *arr. **Montez-lui le média au chemin exact qu'utilisait l'ancienne installation**, et sa base reste entièrement valide : comptes, mots de passe, positions de lecture, « reprendre la lecture », séries en cours, statistiques.

Pendant ce temps, qBittorrent et les *arr adoptent le schéma propre. Les deux mondes cohabitent sans se gêner.

C'est la manœuvre qui transforme une migration douloureuse en un non-événement pour vos utilisateurs.

---

## Avant tout : relever la configuration source

Le fichier compose de l'ancienne installation contient l'essentiel. Notez :

| À relever | Pourquoi |
|---|---|
| **Chemin du média dans le conteneur Jellyfin** | à reproduire à l'identique — c'est le point critique |
| **Version exacte de Jellyfin** | ⚠️ ne jamais restaurer une base dans une version **antérieure** |
| **Chemin monté dans qBittorrent** | les `.fastresume` le contiennent en dur |
| Chemins des *arr, dossiers racine | pour mesurer l'écart |
| UID/GID utilisés | pour les permissions |
| Entrées `extra_hosts` | résolutions forcées de trackers, à ne pas perdre |

⚠️ **Attention aux secrets** dans ce fichier : clés VPN, identifiants de tracker, clés de chiffrement. Profitez de la migration pour les régénérer — et ne les recopiez pas dans un dépôt versionné.

---

## Arrêtez les conteneurs source avant de copier

**Une base SQLite copiée à chaud est corrompue.** Vous ne le découvrirez qu'au premier démarrage sur la nouvelle machine.

```bash
docker stop jellyfin seerr sonarr radarr prowlarr qbittorrent
```

Et arrêtez aussi tout mécanisme de mise à jour automatique **avant** : sinon la version de Jellyfin peut changer entre le relevé et la copie, et la base que vous restaurez ne correspondra plus.

---

## Copier les configurations

```bash
# Jellyfin — tout sauf le jetable
rsync -a --exclude={cache,log,transcodes} \
  /source/jellyfin/ $STACK_ROOT/appdata/jellyfin/

# Les *arr, qBittorrent, le portail — dossier de configuration complet
rsync -a /source/sonarr/     $STACK_ROOT/appdata/sonarr/
rsync -a /source/qbittorrent/ $STACK_ROOT/appdata/qbittorrent/
```

Puis les permissions, avec l'UID/GID de la nouvelle installation :

```bash
chown -R $PUID:$PGID $STACK_ROOT/appdata/
```

> **Faites une copie brute de l'intégralité de l'ancien dossier** avant de trier. Quelques gigaoctets, et ça vous détache de la survie de l'ancienne machine. On découvre souvent trois jours plus tard qu'un service qu'on croyait abandonné contenait quelque chose d'utile.

---

## Préserver les seeds sans revérification

Les fichiers `.fastresume` de qBittorrent contiennent le **chemin de sauvegarde en dur**. Deux options :

| | Méthode | Coût |
|---|---|---|
| **A** | Monter le pool au **chemin d'origine** dans le conteneur | aucun — les torrents reprennent instantanément |
| B | Nouveau chemin, puis « Set location » en masse + *force recheck* | une passe de lecture complète |

**L'option A est presque toujours la bonne.** Reproduisez les sous-dossiers à l'identique *(`complete`, `completed`, `incomplete`, peu importe leurs noms d'origine)* : les chemins résolvent, et vos torrents reprennent sans que le tracker voie autre chose qu'une courte interruption.

La structure interne de `torrents/` n'a **aucune incidence** sur les hardlinks — seul compte le fait qu'il soit sous la même racine que `media/`.

---

## Repointer les *arr

C'est la seule partie réellement manuelle.

### Sonarr

Une seule table contient des chemins absolus : `Series.Path`. Dans l'interface : Root Folders, puis l'éditeur de masse pour réaffecter les séries.

### Radarr — quatre endroits, pas un

| Table | Contenu |
|---|---|
| `Movies.Path` | un par film |
| `RootFolders.Path` | les dossiers racine |
| **`Collections.RootFolderPath`** | **une ligne par collection** — souvent des dizaines |
| **`Config`, clé `recyclebin`** | la corbeille |

Oublier les deux derniers laisse des erreurs de santé permanentes : *« Missing root folder for movie collection »* et *« Unable to write to recycling bin »*.

### Le client de téléchargement

⚠️ **L'hôte devient `gluetun`, pas `qbittorrent`.** Voir [pieges.md](pieges.md#2).

### Le mapping de chemin distant

Si qBittorrent garde son ancien chemin *(option A)* et que les *arr passent au montage unique `/data`, ils ne parlent plus le même langage. qBittorrent annonce `/torrents/…`, les *arr cherchent `/data/torrents/…`.

**Remote Path Mapping**, dans Settings → Download Clients :

| Champ | Valeur |
|---|---|
| Host | `gluetun` |
| Remote Path | `/torrents/` |
| Local Path | `/data/torrents/` |

Sans cette traduction, aucun téléchargement terminé n'est retrouvé.

### L'éditeur de masse

⚠️ **Il peut ne rien appliquer.** Cocher les éléments, choisir le dossier dans la barre d'actions **en bas de page**, puis **confirmer**. Sans ce dernier clic, rien ne se passe et rien ne le signale.

Le symptôme trompeur : *« je n'ai pas eu la question sur le déplacement des fichiers »*. C'est justement le signe que l'opération n'a pas eu lieu.

> Si la question apparaît : **répondez NON**. Les fichiers sont déjà en place.

---

## Le portail de requêtes garde sa propre copie

Après avoir changé les dossiers racine dans Radarr et Sonarr, **changez-les aussi dans le portail**. Sinon chaque demande passe en « requested » et n'arrive jamais dans Radarr.

Passez par son interface plutôt que par son fichier de configuration : les listes déroulantes sont peuplées depuis l'API des *arr, donc la valeur est garantie valide — et le service réécrit son fichier au démarrage, écrasant une édition manuelle.

---

## Rapatrier le média sans tout recopier

Si l'ancienne installation n'avait **pas** de hardlinks, vous avez des doublons à la source. Le réflexe est de tout transférer puis de dédoublonner : c'est un aller-retour inutile.

**Approche directe** : copiez `media/`, puis pour chaque fichier de `torrents/`, créez un **hardlink** vers son équivalent déjà présent localement, sous le nom attendu par le torrent.

L'appariement se fait par taille exacte, **vérifié par une empreinte partielle**. Un fichier renommé par un *arr n'est pas réencodé : il est identique à l'octet près.

Sur une bibliothèque réelle : **843 Gio sur 930 évités**, le reste étant des fichiers réellement absents de la bibliothèque *(sous-titres, bonus de Blu-ray, contenus jamais importés)*.

⚠️ **Vérifiez par empreinte, pas seulement par taille**, et faites un *force recheck* complet après coup. Un mauvais appariement ferait seeder des données corrompues. → [hardlinks.md](hardlinks.md)

---

## Vérifier avant de démanteler la source

Ne débranchez rien avant d'avoir coché tout ceci :

- [ ] **Comptes présents** — comptez-les en base, ne vous fiez pas à l'écran de connexion *(les comptes masqués n'y apparaissent pas)*
- [ ] **Historique de visionnage** intact sur un compte de test
- [ ] **Hardlinks vérifiés** — même inode, compteur à 2
- [ ] **Aucune fuite VPN** — l'IP vue par le client de téléchargement diffère de la vôtre
- [ ] **Tracker résolu**, si vous utilisez `extra_hosts`
- [ ] **Torrents en seed** — un *force recheck* complet a validé chaque pièce
- [ ] **Santé verte** sur tous les *arr, sans avertissement résiduel
- [ ] **Intégrité du média** contrôlée par échantillon de sommes de contrôle
- [ ] Les **données non-média** de l'ancienne machine récupérées
- [ ] **Utilisateurs migrés** et actifs sur la nouvelle installation

> **L'ancienne machine est votre seule copie de secours** tant que vous n'avez pas de sauvegarde. Gardez-la le temps de valider — et ne comptez pas dessus indéfiniment : un volume presque plein et sans redondance peut lâcher n'importe quand.

---

## Un projet peut avoir déménagé

Vérifiez les versions **avant** de reproduire l'ancienne configuration. Un tag figé depuis des mois n'indique pas un projet stable : il peut avoir changé de nom, de dépôt et de registre.

C'est arrivé à Jellyseerr, fusionné avec Overseerr sous le nom **Seerr** — nouveau dépôt, nouveau registre, migration automatique de la base, et deux changements cassants *(conteneur non-root, `init: true` requis)*. Reproduire l'ancien nom d'image aurait installé une version majeure de retard, sans aucun signal.
