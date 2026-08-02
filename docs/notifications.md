# 🔔 Notifications

Savoir ce que fait la stack **sans être connecté au serveur**. C'est ce qui transforme une installation qu'on surveille en une installation qui vous prévient.

---

## Pourquoi auto-héberger ntfy

Un service tiers *(Telegram, Discord, Pushover)* marche très bien et ne demande aucune infrastructure. Si ça vous convient, prenez-le.

`ntfy` auto-hébergé a un intérêt précis : **le contenu de vos alertes ne quitte pas votre machine**.

### La contrainte iOS, qu'aucun choix ne contourne

Sur iPhone, toute notification passe **obligatoirement** par les serveurs push d'Apple. Aucune solution auto-hébergée ne change ça.

Ce que ntfy fait de mieux : avec `upstream-base-url`, ce qui transite par ntfy.sh est un **ping de réveil sans contenu**. Votre iPhone est réveillé, puis vient chercher le message **sur votre serveur**.

```yaml
upstream-base-url: "https://ntfy.sh"
```

⚠️ **Sans cette ligne, aucune notification n'arrive sur iOS** depuis un serveur auto-hébergé.

Sur Android, le client peut se connecter directement à votre serveur en WebSocket — aucun tiers du tout.

*(Une alternative auto-hébergée courante, Gotify, n'a pas d'application iOS. À savoir si vous êtes sur Apple.)*

---

## Public ou privé : la décision

Pour qu'une alerte vous atteigne **hors de chez vous**, votre téléphone doit pouvoir joindre ntfy après le réveil push.

| | Portée | Exposition |
|---|---|---|
| `ntfy.exemple.com` public, authentifié | notifications partout | un service public de plus |
| `ntfy.lan.exemple.com` | LAN ou VPN connecté uniquement | rien de plus exposé |

La seconde option paraît plus sûre, mais elle a un défaut qui la vide de son sens : si votre VPN est en « connexion à la demande », il est inactif la plupart du temps. Une alerte « disque en train de mourir » arriverait quand vous ouvririez autre chose.

**Public avec authentification** est le choix qui rend les alertes utiles. La surface est minuscule *(un binaire Go)*, et l'accès anonyme est refusé d'office :

```yaml
auth-default-access: "deny-all"
enable-signup: false
```

---

## Le compte de publication : écriture seule

Ne faites pas publier vos services avec votre compte administrateur. Créez un compte dédié, **restreint à l'écriture sur un seul sujet** :

```bash
docker exec -it ntfy ntfy user add --role=admin vous       # votre compte
docker exec -i  ntfy ntfy user add publisher               # compte de service
docker exec ntfy ntfy access publisher homelab write-only
```

Vérification :

```
user publisher (role: user)
- write-only access to topic homelab
user * (role: anonymous)
- no access to any topics
```

**Pourquoi ça compte :** certains services journalisent leurs identifiants de notification en clair à chaque envoi. Avec un compte en écriture seule sur un sujet unique, une fuite ne permet que d'envoyer une fausse notification — ni de lire vos alertes, ni de toucher au reste.

C'est du confinement de dégâts, pas de la prévention. Mais c'est ce qui rend la fuite acceptable.

---

## Un seul sujet pour tout

Utilisez **un sujet unique** — `homelab` — pour toute la stack. Un seul abonnement sur le téléphone, et chaque service se distingue par son titre et ses tags.

Multiplier les sujets multiplie les abonnements à gérer, sans bénéfice.

---

## Un format unifié, lisible d'un coup d'œil

L'espace d'affichage d'une notification est court. Le format retenu tient en deux lignes :

```
🔴 Sonarr    Tous les indexeurs sont indisponibles suite à des échecs
             ↳ IndexerStatusCheck
```

**Titre = pastille + application.** Rien d'autre. La gravité est portée par la couleur, pas répétée en mots.

| Pastille | Sens | Priorité ntfy | Effet sur le téléphone |
|---|---|---|---|
| 🔴 | panne | 4 | perce le mode silencieux |
| 🟠 | avertissement | 3 | sonnerie normale |
| 🟢 | résolu | 2 | **sans bruit** — une résolution n'a pas à réveiller |
| 🔵 | information | 3 | normale |

⚠️ **Le connecteur Ntfy natif des *arr ne permet pas ce format.** Il impose un titre du type `Sonarr - Health Check Failure` et des tags statiques : impossible de faire varier la pastille selon la gravité.

Passez par leur connecteur **Custom Script**, qui reçoit le type d'événement et le niveau en variables d'environnement. Un script partagé suffit pour les trois applications — voir `compose/10-media/_scripts/notify-ntfy.sh`.

Montez-le en lecture seule, avec les identifiants ntfy :

```yaml
- ../_scripts/notify-ntfy.sh:/scripts/notify-ntfy.sh:ro
- ${STACK_ROOT}/secrets/ntfy-publisher.env:/run/secrets/ntfy.env:ro
```

Les identifiants passent par un fichier monté plutôt que par l'environnement du conteneur : ils n'apparaissent alors pas dans un `docker inspect`.

---

## Brancher chaque service

### Sonarr, Radarr

Ils ont un connecteur **Ntfy natif**. Settings → Connect → Ntfy.

Événements à activer — **les pannes, pas les succès** :

| Événement | Pourquoi |
|---|---|
| `On Health Issue` / `On Health Restored` | indexeur mort, client de téléchargement injoignable |
| `On Manual Interaction Required` | un import bloqué qui attend une décision |
| **`On Application Update`** | **le seul moyen de ne pas prendre une version majeure de retard** |
| `Include Health Warnings` | à activer, puis à désactiver si trop bavard |

**N'activez pas** `On Grab` ni `On Import` : sur une bibliothèque active, vous cesseriez de lire les notifications au bout d'une semaine. Le portail de requêtes couvre déjà le suivi de ce qui arrive.

### Le portail de requêtes (Seerr)

⚠️ **Son agent ntfy natif ne gère pas l'authentification.** Il stocke les champs identifiant/mot de passe sans jamais les envoyer : résultat, **403 systématique**, sans message explicite côté interface.

Passez par l'agent **Webhook**, avec un gabarit au format JSON de ntfy :

```json
{
  "topic": "homelab",
  "title": "Seerr - {{event}}",
  "message": "{{subject}}\n\nDemandé par {{requestedBy_username}}",
  "priority": 3,
  "tags": ["clapper"]
}
```

Et l'en-tête d'authentification dans `customHeaders`. ⚠️ **Le seul format accepté est un tableau d'objets** :

```json
[{"key": "Authorization", "value": "Basic <base64 de user:password>"}]
```

Un objet JSON simple provoque `customHeaders.forEach is not a function` — erreur peu explicite pour un problème de format.

**Événements** : demandes en attente, approuvées, disponibles, échouées, et problèmes signalés. C'est le suivi que vous voulez vraiment — chaque demande d'un utilisateur vous arrive.

### Surveillance SMART

Le connecteur passe par une URL de type `ntfy://utilisateur:motdepasse@hote/sujet`.

⚠️ Certaines implémentations **journalisent cette URL en clair** à chaque envoi. Rien à faire côté configuration : c'est le compte en écriture seule qui limite la portée.

### Supervision de disponibilité

Réglez des **seuils**, pas une alerte immédiate :

```yaml
default-alert:
  failure-threshold: 3      # trois échecs consécutifs
  success-threshold: 2      # deux succès pour annoncer le retour
  send-on-resolved: true
```

Sans seuil, un hoquet réseau de dix secondes vous réveille. Avec, seules les vraies indisponibilités remontent — et vous recevez aussi le message de résolution, ce qui évite de se demander si c'est reparti.

### Détection d'intrusion

CrowdSec dispose d'un système de plugins de notification. Un plugin HTTP suffit pour publier vers ntfy. Le gabarit ci-dessous tient en deux lignes et remonte surtout **le nom du compte visé** — l'information qui sépare un robot d'un attaquant renseigné.

```yaml
# appdata/crowdsec/config/notifications/ntfy.yaml
type: http
name: ntfy
format: |
  {{range . -}}
  {{- $alert := . -}}
  {{- $user := "" -}}
  {{- range $alert.Events -}}{{- range .Meta -}}{{- if eq .Key "user" -}}{{- $user = .Value -}}{{- end -}}{{- end -}}{{- end -}}
  {{- range .Decisions -}}
  {{.Type}} {{.Value}} pendant {{.Duration}}
  ↳ {{.Scenario}}{{if $user}} · compte « {{$user}} »{{end}}{{if $alert.Source.Cn}} · {{$alert.Source.Cn}}{{end}}{{if $alert.Source.AsName}} {{$alert.Source.AsName}}{{end}}
  {{end -}}
  {{end -}}
url: https://ntfy.exemple.com/homelab
method: POST
headers:
  Authorization: Basic <base64 de "publisher:MOTDEPASSE">
  Title: 🔴 CrowdSec
  Priority: "4"
```

Ce qui arrive sur le téléphone :

```
🔴 CrowdSec
ban 203.0.113.42 pendant 24h
↳ LePresidente/jellyfin-bf · compte « admin » · FR OVH SAS
```

Un `admin` ou un `root` trahit un robot qui devine, et vous pouvez l'ignorer. **Le nom d'un de vos vrais utilisateurs signifie qu'on vous connaît** — et là il y a quelque chose à faire.

Trois détails qui coûtent du temps :

- Le préfixe du scénario *(`LePresidente/`)* est **l'auteur de la collection sur le Hub**, pas un nom d'utilisateur. Il est permanent, ce n'est pas un artefact de test.
- Les gardes `{{if}}` sur le pays et l'opérateur ne sont pas cosmétiques : certaines IP n'ont **aucune donnée GeoIP**, et sans elles la ligne se termine par un séparateur orphelin.
- Sur une **énumération** de comptes, seul le dernier nom essayé s'affiche : un gabarit Go ne sait pas dédoublonner une liste. Le scénario signale déjà le cas *(`_user-enum`)*.

⚠️ Pensez à **activer la notification dans le profil** *(`profiles.yaml`)*, pas seulement à écrire le fichier de plugin. Les deux sont nécessaires.

**Ce fichier contient un mot de passe.** Gardez-le hors du dépôt, en `600`, comme les autres fichiers de plugin livrés par CrowdSec — le dépôt ne porte qu'un `.example`.

#### Valider sans casser le service

Un gabarit malformé **empêche CrowdSec de démarrer**. Or `cscli` relit la configuration à froid : on peut donc tester **avant** de redémarrer l'agent.

```bash
docker exec crowdsec cscli notifications test ntfy       # compile le gabarit et envoie
docker exec crowdsec cscli notifications reinject <id>   # rejoue une VRAIE alerte
```

`reinject` est le plus utile des deux : il rejoue une alerte existante **avec ses métadonnées**, et montre donc le rendu final, nom de compte compris. Il ne crée aucune décision et ne bannit personne. Récupérez un identifiant avec `cscli alerts list`.

---

## Tester avant de compter dessus

Chaque service a un bouton ou un point d'API de test. **Utilisez-les tous.** Une notification qu'on croit configurée et qui ne part pas est pire que pas de notification : vous vous reposez sur un filet inexistant.

```bash
# Publication directe, pour valider la chaîne complète
curl -u "publisher:MOTDEPASSE" \
     -H "Title: Test" -H "Priority: high" \
     -d "Si vous lisez ceci, la chaîne fonctionne." \
     https://ntfy.exemple.com/homelab
```

Et vérifiez que ça arrive **sur le téléphone**, pas seulement que l'API renvoie 200.

---

## Prévoir la rotation

Le mot de passe de publication finit par avoir beaucoup de consommateurs :

| Consommateur | Où |
|---|---|
| fichier de secrets | source de vérité |
| surveillance SMART | fichier de configuration |
| détection d'intrusion | en-tête base64 dans un fichier de plugin |
| Sonarr, Radarr | via leur API |
| portail de requêtes | via son API |
| supervision | variable d'environnement, redémarrage requis |

Six endroits. **Écrivez le script de rotation le jour où vous montez tout ça**, pas le jour où vous en avez besoin en urgence.
