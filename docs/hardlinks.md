# 🔗 Hardlinks — le piège n°1

Si vous ne lisez qu'un document de ce dépôt, c'est celui-là.

**Symptôme :** votre disque se remplit deux fois plus vite que prévu. Vous découvrez le problème à saturation, quand plusieurs téraoctets sont déjà perdus.

**Cause :** vos *arr copient au lieu de créer des liens, et vous n'avez rien vu.

---

## Le mécanisme

Un torrent terminé doit rester en place pour être seedé. Mais Jellyfin veut le même fichier, renommé proprement, dans une arborescence de bibliothèque.

Deux façons de satisfaire les deux besoins :

| | Espace consommé | Seed préservé |
|---|---|---|
| **Copie** | **2×** la taille du fichier | oui |
| **Hardlink** | **1×** — un seul bloc de données, deux noms | oui |

Un hardlink, c'est deux entrées de répertoire pointant vers le **même inode**. Le fichier n'existe qu'une fois sur le disque. Supprimer l'un des deux noms ne libère rien : les données disparaissent au dernier lien.

C'est exactement ce qu'on veut. Et c'est gratuit.

---

## La condition, et comment on la casse

> **Un hardlink ne peut exister qu'à l'intérieur d'un même système de fichiers.**

Sur l'hôte, si `media/` et `torrents/` sont sur le même disque, tout va bien. **Le problème vient de Docker.**

```yaml
# ❌ Ce que fait la majorité des tutoriels
volumes:
  - /pool/media/movies:/movies
  - /pool/torrents:/downloads
```

Deux montages distincts. Le conteneur voit **deux périphériques différents** — même si sur l'hôte c'est le même disque. Radarr tente le lien, échoue, et **retombe silencieusement sur la copie**.

```yaml
# ✅ Un seul montage, la racine commune
volumes:
  - /pool:/data
```

Le conteneur voit `/data/media/movies` et `/data/torrents` comme un seul système de fichiers. Le lien fonctionne.

---

## L'arborescence qui marche

```
/pool/                        ← LE point de montage, monté en /data
├── media/
│   ├── movies/
│   ├── series/
│   └── anime/
└── torrents/
    ├── complete/
    └── incomplete/
```

Et dans **tous** les conteneurs qui déplacent ou lient des fichiers — Sonarr, Radarr, Bazarr :

```yaml
- ${POOL_ROOT}:/data
```

**Jellyfin est l'exception** : il ne fait que lire, il n'a aucun besoin de hardlink. Il peut donc garder un chemin différent — ce qui est précieux lors d'une migration, où préserver son chemin d'origine préserve toute sa base *(voir [migration.md](migration.md))*.

---

## Vérifier — la seule étape non négociable

Un hardlink cassé est **invisible**. Rien dans les journaux, aucune erreur, l'import réussit. Vous ne le découvrez qu'à disque plein, des mois plus tard.

### Test 1 — le conteneur voit-il un seul système de fichiers ?

```bash
docker exec radarr df -h | grep /data
```

`/data` doit apparaître **une seule fois**. Deux lignes = deux montages = hardlinks impossibles.

### Test 2 — le fichier est-il réellement partagé ?

Après un import, comparez les deux chemins :

```bash
ls -li /pool/torrents/complete/Film.2024.1080p.mkv \
       /pool/media/movies/"Film (2024)"/"Film (2024) - Bluray-1080p.mkv"
```

```
1234567 -rw-rw-r-- 2 user group 8547829043 ... Film.2024.1080p.mkv
1234567 -rw-rw-r-- 2 user group 8547829043 ... Film (2024) - Bluray-1080p.mkv
   ▲                ▲
   │                └── compteur de liens = 2
   └── MÊME numéro d'inode
```

**Même inode + compteur à 2** = hardlink effectif, un seul bloc de données.

Deux inodes différents et un compteur à 1 sur chacun = **vous copiez**. Corrigez le montage avant d'aller plus loin.

### Test 3 — l'espace réellement consommé

```bash
du -sh /pool          # compte les hardlinks DEUX fois : trompeur
df -h /pool           # la vérité
```

C'est une propriété utile à connaître : après avoir hardlinké une bibliothèque, `du` annonce le double de la réalité. Seul `df` compte juste.

---

## Ce que ça change à l'usage

Une fois les hardlinks en place, deux comportements surprennent au début :

**Supprimer un torrent et ses données ne touche pas la bibliothèque.** Et supprimer un film de la bibliothèque ne casse pas le seed. Le fichier ne disparaît qu'au dernier lien. C'est le comportement normal d'une installation correcte.

**Un `rsync` de sauvegarde sans `-H` recrée les doublons.** Votre sauvegarde pèsera le double de la source. Pensez-y en montant la sauvegarde.

---

## Réparer une installation déjà dupliquée

Si vous découvrez que vous copiez depuis des mois, tout n'est pas perdu — les fichiers sont identiques, il suffit de remplacer les doublons par des liens.

`jdupes` et `rmlint` savent le faire : ils identifient les fichiers identiques par contenu et remplacent les copies par des hardlinks, en place.

```bash
# Aperçu, sans rien modifier
jdupes -r -L --print /pool

# Application
jdupes -r -L /pool
```

⚠️ **Corrigez d'abord le montage.** Sinon vous dédoublonnez pour re-dupliquer au prochain import.

---

## Cas particulier : migrer sans recopier

Si vous rapatriez une bibliothèque depuis un serveur où les hardlinks n'étaient **pas** actifs, vous avez des doublons à la source : le même contenu sous deux noms, un dans `torrents/`, l'autre renommé dans `media/`.

Le réflexe est de tout recopier puis de dédoublonner. C'est un aller-retour inutile.

**Approche plus directe :** copiez d'abord `media/`. Puis, pour chaque fichier de `torrents/`, cherchez son équivalent **déjà présent localement** et créez un hardlink sous le nom attendu par le torrent — au lieu de le transférer.

L'appariement se fait par **taille exacte**, vérifié par une empreinte partielle *(premier et dernier mégaoctet)* pour écarter toute collision. Un fichier renommé par un *arr n'est pas réencodé : il est identique à l'octet près.

Sur une bibliothèque réelle, cette méthode a évité **843 Gio de transfert sur 930** — le reste étant des fichiers réellement absents de la bibliothèque *(sous-titres, bonus, contenus non importés)*.

⚠️ **Vérifiez toujours par empreinte, pas seulement par taille.** Un mauvais appariement ferait seeder des données corrompues, ce que les trackers privés sanctionnent. Et faites un *force recheck* complet dans qBittorrent après coup : c'est la seule preuve définitive.
