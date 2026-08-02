# ⚠️ Pièges

Tout ce qui a coûté du temps, avec la cause. Rangé par ordre de coût.

---

## 1. Les *arr copient au lieu de lier

Le plus cher, et le plus silencieux. → **[hardlinks.md](hardlinks.md)**

---

## 2. L'hôte du client de téléchargement est `gluetun`, pas `qbittorrent`

Quand qBittorrent tourne en `network_mode: "service:gluetun"`, il **n'a pas d'identité réseau propre** : il partage la pile de gluetun. Depuis un autre conteneur :

```
qbittorrent:8080  →  ne résout pas
gluetun:8080      →  répond
```

C'est aussi pour ça que les ports de qBittorrent sont publiés dans la section `ports:` de **gluetun** et non la sienne.

---

## 3. Radarr stocke des chemins absolus à quatre endroits

Si vous changez le chemin de votre bibliothèque, il ne suffit pas de mettre à jour le dossier racine. Radarr conserve des chemins absolus dans :

| Table | Contenu |
|---|---|
| `Movies.Path` | un par film |
| `RootFolders.Path` | les dossiers racine |
| **`Collections.RootFolderPath`** | **une ligne par collection** — facilement des dizaines |
| **`Config`, clé `recyclebin`** | la corbeille |

Oublier les deux derniers laisse des erreurs de santé permanentes : *« Missing root folder for movie collection »* et *« Unable to write to recycling bin »*.

**Sonarr est plus simple** : seul `Series.Path` est concerné.

Pour repérer les chemins absolus restants dans une base :

```sql
-- puis pour chaque colonne contenant "path" ou "folder"
SELECT DISTINCT <colonne> FROM <table> WHERE <colonne> LIKE '/%';
```

---

## 4. L'éditeur de masse peut ne rien appliquer

Changer le dossier racine de 300 films depuis l'éditeur de masse demande : cocher les éléments, choisir le dossier dans la barre d'actions **en bas de page**, puis **confirmer**. Sans ce dernier clic, rien n'est appliqué — et aucun message ne le signale.

Le symptôme trompeur : *« je n'ai pas eu la question sur le déplacement des fichiers »*. C'est justement le signe que l'opération n'a pas eu lieu.

> Si la question apparaît, **répondez NON**. Les fichiers sont déjà en place ; vous ne voulez mettre à jour que les chemins en base. Un « oui » distrait déclenche une réécriture de plusieurs téraoctets.

---

## 5. Seerr garde sa propre copie du dossier racine

**Symptôme :** une demande passe en « requested » côté Seerr, et n'arrive jamais dans Radarr.

Seerr stocke le dossier de destination **indépendamment** de Radarr. Changez-le dans Radarr sans le changer dans Seerr, et chaque demande échoue avec :

```
"rootFolderPath": "/movies"  →  "Root folder '/movies' does not exist"  (HTTP 400)
```

À corriger dans **Settings → Services**, pour Radarr *et* Sonarr *(qui a en plus un dossier anime séparé)*. Les demandes déjà en `FAILED` doivent être relancées manuellement.

---

## 6. Le reverse proxy journalise dans un format que CrowdSec ne lit pas

Nginx Proxy Manager utilise un format maison :

```
[02/Aug/2026:00:41:20 +0200] - 200 200 - GET https stream.exemple.com "/" [Client 1.2.3.4] [Sent-to jellyfin] "curl/8.7.1"
```

Aucun parseur CrowdSec ne sait le lire. L'agent démarre, annonce qu'il surveille le fichier, et **ne détecte jamais rien**. Une panne parfaitement silencieuse.

**Solution :** ajouter un **second** journal au format nginx standard, sans toucher aux journaux existants. Deux fichiers dans `/data/nginx/custom/` :

- `http_top.conf` → définit un `log_format` standard
- `server_proxy.conf` → une ligne `access_log`, **incluse automatiquement dans chaque proxy host, présent et futur**

Le second point compte : aucune action à refaire lors de l'ajout d'un service.

---

## 7. Le bouncer pare-feu bloque dans le vide

Le trafic vers un conteneur est **routé** (DNAT) et traverse la chaîne `FORWARD`, puis `DOCKER-USER`. **Il ne traverse jamais `INPUT`.**

Or la configuration par défaut du bouncer ne cible que `INPUT`. Résultat : il tourne, s'authentifie, affiche fièrement ses règles, et **ne bloque rien du tout**.

```yaml
iptables_chains:
  - INPUT
  - FORWARD
  - DOCKER-USER    # ← la chaîne décisive
```

**Testez toujours** : ajoutez une décision sur une IP de documentation et vérifiez qu'elle apparaît dans l'ensemble bloqué.

```bash
docker exec crowdsec cscli decisions add --ip 203.0.113.42 --duration 2m
sleep 15
docker exec crowdsec-bouncer ipset list crowdsec-blacklists-0 | tail -5
docker exec crowdsec cscli decisions delete --ip 203.0.113.42
```

---

## 8. Un compose monolithique empêche d'arrêter un seul service

La plupart des interfaces — y compris celle de certains NAS — traitent un projet compose comme un bloc indivisible. Avec un seul fichier pour toute la stack, impossible d'arrêter Sonarr sans arrêter Jellyfin.

**Un compose par unité** supprime le problème : arrêter un service revient à arrêter son projet, ce que toutes les interfaces savent faire.

Trois cas seulement doivent rester groupés, et par **contrainte technique** :

| Unité | Raison |
|---|---|
| gluetun + qbittorrent | `network_mode: "service:gluetun"` exige le même projet |
| une application + sa base | la base ne sert qu'à elle, elle vit et meurt avec |

---

## 9. Le `.env` partagé n'est pas lu

Compose ne lit le `.env` que dans le **répertoire du compose**, jamais dans un parent. Avec une arborescence à deux niveaux, `${DOMAIN}` reste non résolu — et **gluetun démarre sans clé VPN**, sans erreur visible.

**Solution :** un lien symbolique dans chaque dossier de service, versionné tel quel par git.

```bash
ln -s ../../../.env .env
```

⚠️ Et alors le `.gitignore` doit exclure **uniquement le `.env` racine** :

```gitignore
/.env      # ✅ avec le slash initial
# .env     # ❌ exclurait aussi tous les liens
```

Sinon, un clone de restauration arrive sans les liens et rien ne démarre correctement.

---

## 10. Un wildcard ne couvre qu'un seul niveau

`*.exemple.com` matche `stream.exemple.com` mais **pas** `sonarr.lan.exemple.com`.

On croit avoir tout couvert, et la moitié des services servent un certificat invalide. Il faut **deux certificats** : un pour `*.exemple.com`, un pour `*.lan.exemple.com`.

---

## 11. Le serveur par défaut du port 80 vous identifie

Le port 443 de NPM est bien protégé d'office : `ssl_reject_handshake on` + `return 444`. Un `Host` inconnu n'obtient ni page, ni certificat, ni confirmation qu'un serveur écoute.

**Le port 80, lui, sert une page dont le titre et le contenu annoncent nginx et proxy manager** — soit l'empreinte exacte du logiciel à cibler, offerte à tout scanner. Et c'est un port redirigé depuis Internet.

Le réglage « Default Site » de l'interface ne traite pas ce cas correctement. Un `default_server` explicite dans `http_top.conf` le ferme *(voir [securite.md](securite.md))*.

---

## 12. Un projet peut déménager sans que le tag bouge

Jellyseerr paraissait à jour en `2.7.3`. Il avait en réalité **une version majeure de retard** : le projet avait fusionné avec Overseerr sous le nom **Seerr** *(v3.0.0, février 2026)*, avec un nouveau dépôt et un nouveau registre. L'ancienne image Docker Hub était figée depuis des mois.

> **Un tag qui cesse de bouger n'est pas un projet stable, c'est parfois un projet déménagé.**

Activez `OnApplicationUpdate` sur Sonarr et Radarr : ils vous préviennent eux-mêmes. Et vérifiez les versions périodiquement, en **filtrant les préversions** — la première page de tags Docker Hub triée par date est majoritairement composée de `develop`, `nightly` et `sha-*`.

---

## 13. Recyclarr n'est pas additif, et ne fait presque rien par défaut

Deux surprises :

**Ce n'est pas sans effet sur l'existant.** La synchronisation modifie les **définitions de taille**, qui sont **globales** dans Radarr — donc partagées avec vos profils existants. Et elle **remplace** tout format personnalisé portant le même nom qu'un format TRaSH.

Vérifiez après la première synchro que vos scores sont intacts, et surveillez le nombre de films « sous le seuil » : une hausse brutale annoncerait une vague de remplacements.

**Et son intérêt demande du travail.** Les templates commentent des dizaines de groupes de formats par défaut. Ceux qu'on active demandent encore un réglage individuel : `select:` pour choisir les formats d'un groupe, `assign_scores_to` pour cibler un profil. Sans cette curation, Recyclarr crée un profil et synchronise des tailles — c'est tout.

Enfin, la directive `include:` s'appuie sur `includes.json`, **qui peut être vide** dans le dépôt officiel. Le mécanisme utilisable est alors `recyclarr config create -t <template>`, qui génère un fichier à compléter.

---

## 14. `rsync --delete` sur un dépôt git

Synchroniser un dossier local vers un dépôt distant avec `--delete` supprime tout ce qui n'existe pas côté source — **y compris `.git/`** et les liens symboliques absents localement.

Récupérable si le dépôt est poussé sur un remote *(recloner, déplacer le `.git`)*, mais c'est dix minutes perdues et une frayeur. N'utilisez pas `--delete` contre un répertoire versionné.

---

## 15. Tracker injoignable alors que le VPN fonctionne

Certains trackers ont un DNS instable ou filtré selon la sortie VPN. Le tunnel est bon, l'IP est bonne, et les annonces échouent.

`extra_hosts` sur gluetun force la résolution :

```yaml
extra_hosts:
  - "tracker.exemple.net:203.0.113.10"
```

⚠️ **Cette ligne doit suivre lors d'une migration.** Sans elle, les torrents ne peuvent plus annoncer et vous perdez le bénéfice du seed, sans message d'erreur explicite.

---

## 16. Les identifiants finissent dans les journaux

Certains services journalisent leur URL de notification **en clair, mot de passe compris**, à chaque envoi. Ce n'est pas configurable.

La parade n'est pas de le cacher, c'est de **limiter la portée** : créez un compte de publication dédié, en **écriture seule sur un seul sujet**. S'il fuite, il ne permet que d'envoyer une fausse notification — ni de lire vos alertes, ni de toucher au reste.

Et prévoyez la rotation : un mot de passe de notification peut avoir **six consommateurs** *(fichier de secrets, deux fichiers de configuration, trois API)*. Scriptez-la avant d'en avoir besoin.
