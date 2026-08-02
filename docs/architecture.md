# 🏗️ Architecture

Conventions de nommage, découpage des réseaux et des compose. Rien ici n'est cosmétique : chaque règle évite un problème concret.

---

## La règle qui gouverne tout

> **Un service = un nom, répété à l'identique partout.**
> Dossier compose, dossier appdata, `container_name`, alias réseau, sous-domaine, entrée de supervision.

Nom officiel du projet, en minuscules : `bazarr`, `prowlarr`, `seerr`. Jamais de traduction mentale entre « le conteneur `pprls` » et « `docs.exemple.com` ».

⚠️ **Fixez toujours `container_name`.** Sans lui, Docker génère `10-media-sonarr-1` — un nom qui change si vous renommez le dossier, et qui casse vos règles de proxy et de supervision.

---

## Arborescence

```
$STACK_ROOT/
├── compose/                  ← dépôt git, la seule source de vérité
│   ├── .env                  #   secrets d'interpolation (ignoré)
│   ├── common.env            #   PUID / PGID / TZ / UMASK
│   ├── 00-core/              #   proxy, sécurité
│   ├── 10-media/             #   la stack média
│   └── 90-monitoring/        #   supervision
│
├── appdata/<service>/        ← état persistant · À SAUVEGARDER
├── cache/<service>/          ← jetable, régénérable · EXCLU des sauvegardes
├── secrets/                  ← clés, chmod 600 · jamais dans git
└── backups/                  ← dumps avant envoi hors machine
```

### Pourquoi `appdata/` et `cache/` séparés

La règle de sauvegarde devient triviale et ne se discute plus :

> **Sauvegarder `appdata/` + `secrets/` + `compose/`. Ignorer `cache/` et le pool média.**

Sans cette séparation, les métadonnées de Jellyfin *(plusieurs gigaoctets d'affiches retéléchargeables)* polluent chaque sauvegarde. Sur une installation réelle, le tri donne **200 Mo d'irremplaçable pour 5,5 Go de régénérable** — soit un facteur 27.

### Le préfixe numérique

`00-core` → `90-monitoring` encode le **niveau de dépendance**, pas une préférence esthétique : c'est l'ordre de démarrage après un redémarrage ou une restauration, et `ls` le trie tout seul.

```bash
# Restauration complète, dans le bon ordre
for f in compose/*/*/compose.yml; do docker compose -f "$f" up -d; done
```

---

## Découpage : un compose par unité

> **Une unité = un service + ses dépendances privées.** Ni un compose géant, ni un compose par conteneur.

Un compose monolithique rend impossible l'arrêt d'un seul service depuis une interface. Un compose par unité supprime le problème à la racine.

**Ce qui doit rester groupé** — trois cas, par contrainte technique :

| Unité | Pourquoi indissociable |
|---|---|
| `download/` = gluetun + qbittorrent | `network_mode: "service:gluetun"` **exige** le même projet compose |
| une application + sa base | la base ne sert qu'à elle, elle vit et meurt avec |
| un service + son cache dédié | idem |

Tout le reste : un service, un dossier, un `compose.yml`.

---

## Réseaux

### Le média : un réseau plat

```bash
docker network create media
```

Plat parce que ces services **doivent** se parler : Seerr interroge Jellyfin, Sonarr et Radarr ; les *arr interrogent Prowlarr et qBittorrent. Ils forment un cluster de confiance équivalente.

### La supervision : séparée

```bash
docker network create monitoring
```

Rien n'oblige Scrutiny à pouvoir joindre Sonarr.

### Les services publics : un réseau par service

```bash
docker network create web-ntfy
docker network create web-<projet>
```

> **Le reverse proxy est le SEUL conteneur présent dans plusieurs réseaux.** Chaque service public ne voit que lui, jamais ses voisins.

Un réseau public unique et plat serait le maillon faible dès qu'on héberge plusieurs projets : un service compromis atteindrait les autres, dont certains détiennent des clés d'API. Isolés, ils ne peuvent parler à personne.

Ajouter un projet public = créer son réseau + une ligne dans le compose du proxy. Ce changement est committé, donc tracé.

**Aucun conteneur ne touche à la fois un réseau `web-*` et le réseau interne.**

---

## Ports

> **Seul le reverse proxy publie des ports.** Tout le reste utilise `expose:`.

Les services se joignent par nom de conteneur (`http://sonarr:8989`). Conséquences :

- plus aucun port à mémoriser ni à documenter
- `ss -tlnp` sur l'hôte reste presque vide — surface d'attaque minimale
- aucun conflit de port possible entre services

**Exceptions**, à justifier en commentaire : le port d'écoute torrent *(via gluetun)*, et l'administration du proxy *(jamais redirigée depuis Internet)*.

---

## Chemins internes aux conteneurs

Identiques partout, quel que soit le service :

| Montage | Rôle |
|---|---|
| `/config` | configuration et base du service |
| `/data` | **racine du pool média**, jamais un sous-dossier |

**`/data` doit être un montage unique** — c'est la condition des hardlinks *(voir [hardlinks.md](hardlinks.md))*.

**Exception documentée : Jellyfin.** Il ne fait que lire, donc n'a aucun besoin de hardlink. Lui laisser un chemin différent est ce qui permet de préserver sa base lors d'une migration *(voir [migration.md](migration.md))*.

---

## Images

> **Tag figé, jamais `:latest`.**

Et **pas de mise à jour automatique**. Un notificateur suffit : vous êtes prévenu, vous bumpez le tag, vous committez. La mise à jour devient une décision tracée dans l'historique git — et vous savez toujours quelle version tournait.

---

## Git, et pourquoi c'est votre plan de reprise

Le dossier `compose/` est un dépôt git avec un remote privé. Sur un système où seule la partition de données survit à une réinstallation, **c'est ce qui décrit votre serveur**.

`.gitignore` :

```gitignore
/.env        # ⚠️ le slash initial : n'exclut QUE le .env racine
common.env
secrets/
appdata/
backups/
```

⚠️ Les liens `.env` de chaque service **doivent** être versionnés. Un `.env` sans slash les exclurait, et un clone de restauration ne démarrerait pas *(voir [pieges.md](pieges.md#9))*.

**Reconstruction complète** = cloner le dépôt, remplir `.env` depuis `.env.example`, restaurer `appdata/`, puis démarrer dans l'ordre `00` → `90`.

⚠️ **Un dépôt local sur le même disque que les données ne protège de rien.** La protection vient du remote, ou d'une sauvegarde hors machine. Le dépôt local ne sert qu'à `git diff` et à revenir en arrière.

---

## Check-list avant d'ajouter un service

- [ ] Nom officiel choisi, identique partout
- [ ] Son propre dossier d'unité — sauf dépendance privée
- [ ] `ln -s ../../../.env .env` dans le dossier
- [ ] `container_name` fixé
- [ ] Tag d'image figé
- [ ] `expose:` et non `ports:` — sinon justifier en commentaire
- [ ] Un seul réseau, et jamais public + interne
- [ ] Secrets dans `.env` ou `secrets/`, clés ajoutées à `.env.example`
- [ ] Enregistrement DNS *(couvert d'office par le wildcard `*.lan`)* + proxy host
- [ ] Entrée dans la supervision
- [ ] Commit
