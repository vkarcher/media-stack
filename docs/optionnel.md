# ➕ Services optionnels

Non déployés par défaut, mais présents dans `compose/`. Chacun répond à un besoin précis — inutile de tout installer.

---

## `autobrr` — le plus gros levier sur un tracker privé

**Ce qu'il fait :** il écoute les canaux d'annonce IRC des trackers et récupère une release **quelques secondes** après sa publication, là où un cycle RSS attend des minutes.

**Pourquoi c'est disproportionné par rapport au reste :** sur un tracker privé, être premier sur un torrent signifie être **seeder de référence** pour des dizaines de leechers. Vous distribuez pendant que personne d'autre ne le peut. L'effet sur le ratio n'a aucune commune mesure avec quoi que ce soit d'autre dans cette stack.

**Prérequis :** votre tracker doit avoir un canal d'annonce IRC, et vous devez y avoir accès *(clé d'annonce fournie par le tracker)*. Sans ça, autobrr n'a rien à écouter.

**Configuration**, après démarrage :

1. Settings → Indexers → ajoutez votre tracker et sa clé d'annonce
2. Settings → Download Clients → qBittorrent, **hôte `gluetun`** *(voir [pieges.md](pieges.md#2))*
3. Filters → définissez ce qui doit être récupéré

⚠️ **Commencez par des filtres restrictifs.** Un filtre trop large sur un tracker actif remplit un disque en une nuit. Limitez par taille, qualité et catégorie avant d'élargir.

```bash
cd compose/10-media/autobrr && docker compose up -d
```

---

## `wizarr` — invitations Jellyfin

**Ce qu'il fait :** génère des liens d'invitation. La personne clique, crée son compte, reçoit automatiquement les bonnes bibliothèques.

**Quand ça devient utile :** dès une dizaine d'utilisateurs. Vous cessez de créer les comptes à la main et d'expliquer par message comment se connecter.

Gère aussi les invitations à durée limitée et les comptes temporaires — pratique pour un accès ponctuel.

⚠️ **C'est le seul service optionnel qui doit être public** : il est fait pour être partagé. Donnez-lui un sous-domaine public *(`invite.votre-domaine`)* et non un `.lan`.

```bash
cd compose/10-media/wizarr && docker compose up -d
```

---

## `cross-seed` — du ratio sans télécharger

**Ce qu'il fait :** il scanne votre bibliothèque et trouve, sur d'autres trackers, les torrents correspondant **aux fichiers que vous possédez déjà**. Vous seedez les mêmes données sur plusieurs sources sans télécharger un octet.

**Le gain est direct** : sur un tracker à économie de points, c'est du volume distribué gratuit.

⚠️ **Demande au moins deux trackers pour avoir un sens.** Avec un seul, il n'y a rien à croiser. Beaucoup de trackers privés ayant fermé ou étant en inscription fermée, cette condition n'est pas toujours réunie — d'où l'absence de compose ici.

Si vous avez plusieurs trackers, c'est le premier service à ajouter après autobrr.

---

## `Tdarr` — transcodage de masse

**Ce qu'il fait :** réencode votre bibliothèque, typiquement vers H.265, pour récupérer de l'espace. Sur des remux ou du Blu-ray, le gain peut atteindre 50 %.

> ⚠️ **Il réécrit vos fichiers.** Un profil mal réglé, un job interrompu, une coupure de courant — et l'original est perdu.

**À n'envisager que dans un de ces deux cas :**

- vous avez une **sauvegarde** de votre média, ou vous acceptez de le reperdre
- vous configurez Tdarr pour **conserver les originaux** — ce qui annule le gain d'espace pendant la durée de vérification

Si vous y allez malgré tout : mode **sélectif** *(une bibliothèque ciblée, pas tout)*, filtres stricts *(par exemple uniquement les fichiers au-delà d'une certaine taille)*, et **planification nocturne** pour ne pas concurrencer le transcodage à la volée de Jellyfin sur le même GPU.

Pas de compose fourni : ce n'est pas un service à déployer sans avoir lu sa documentation.

---

## Ce qui ne vaut probablement pas le détour

Pour être complet, et pour vous éviter de les évaluer :

| | Pourquoi |
|---|---|
| **Jellystat** | statistiques de visionnage. Sympa, sans effet sur le fonctionnement. |
| **Suggestarr** | demandes automatiques selon l'historique. Remplit le disque à votre place. |
| **Huntarr** | recherche en continu les contenus manquants. Redondant avec la recherche des *arr, et bavard. |
| **Decluttarr** | recouvre ce que fait déjà Cleanuparr. |
| **Profilarr** | recouvre ce que fait déjà Recyclarr. |
| **Watchtower** | mises à jour automatiques. **À éviter** : c'est ainsi qu'on prend une migration de base irréversible sans l'avoir décidé *(voir [pieges.md](pieges.md#12))*. |
