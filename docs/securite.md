# 🔒 Sécurité

Ce qui protège réellement, et ce qui n'est que du théâtre.

---

## Le point de départ : vous êtes déjà scanné

Avant tout durcissement, voici ce qu'on trouve dans les journaux d'un serveur exposé depuis quelques jours :

```
[Client 198.51.100.14]       GET /p.php, /php.php        sondage PHP opportuniste
[Client 198.51.100.87]  GET /debug/…?panel=config   scanner automatisé
[Client 198.51.100.203]    Cortex Xpanse               scan Internet massif
```

Ce n'est pas une hypothèse. **Les attaques opportunistes vous trouvent sans passer par votre nom de domaine** : Shodan et Censys scannent l'IPv4 en continu. Un port 443 ouvert est indexé, que votre DNS pointe dessus ou non.

Corollaire utile : **choisir un domaine discret ne vous protège de rien** contre ce trafic-là. Ça ne joue que contre l'attention ciblée de quelqu'un qui vous connaît.

---

## Fermer le serveur par défaut

C'est la première chose à faire, et elle prend deux minutes.

Le port **443** de NPM est bien protégé d'office :

```nginx
ssl_reject_handshake on;
return 444;
```

Un `Host` inconnu n'obtient ni page, ni certificat, ni même la confirmation qu'un serveur écoute. Rien à améliorer.

**Le port 80, en revanche, sert une page dont le titre et le contenu annoncent nginx et proxy manager.** C'est l'empreinte exacte du logiciel à cibler, offerte à tout scanner — et c'est un port redirigé depuis Internet.

Le réglage « Default Site » de l'interface ne traite pas ce cas correctement. Ajoutez plutôt un serveur par défaut explicite dans `/data/nginx/custom/http_top.conf` :

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    access_log off;
    return 444;
}
```

Les vhosts déclarés conservent leur redirection 301 vers HTTPS — vérifiez-le après application.

⚠️ **Un seul `default_server` par adresse d'écoute.** Si une version future du proxy en déclare un, nginx refusera de démarrer sur un doublon. C'est le point à vérifier après chaque montée de version.

### Appliquer sans coupure

```bash
docker exec npm mkdir -p /data/nginx/custom
docker cp http_top.conf     npm:/data/nginx/custom/
docker cp server_proxy.conf npm:/data/nginx/custom/
docker exec npm nginx -t && docker exec npm nginx -s reload
```

`nginx -s reload` est **à chaud** : aucune connexion coupée. Testez toujours avec `nginx -t` avant.

*(Pourquoi `docker cp` plutôt qu'un bind mount : monter ces fichiers imposerait de recréer le conteneur, donc une coupure de service.)*

---

## CrowdSec : détection puis blocage

### Le prérequis que tout le monde rate

Nginx Proxy Manager journalise dans un format maison :

```
[02/Aug/2026:00:41:20] - 200 200 - GET https stream.exemple.com "/" [Client 1.2.3.4] [Sent-to jellyfin]
```

**Aucun parseur CrowdSec ne sait le lire.** L'agent démarre, annonce qu'il surveille le fichier, et ne détecte jamais rien. Panne parfaitement silencieuse.

Ajoutez un **second** journal au format nginx standard, sans toucher aux existants :

```nginx
# http_top.conf
log_format crowdsec '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

```nginx
# server_proxy.conf — inclus automatiquement dans CHAQUE proxy host
access_log /data/logs/crowdsec_access.log crowdsec;
```

Le second fichier est la clé : NPM l'inclut dans tous les vhosts, **présents et futurs**. Aucune action à refaire lors de l'ajout d'un service.

### Le whitelist, avant tout le reste

```yaml
whitelist:
  reason: "reseau local, VPN et plages privees"
  cidr:
    - "192.168.0.0/16"
    - "10.0.0.0/8"
    - "172.16.0.0/12"
```

**Sans cette liste, un faux positif peut vous couper l'accès à votre propre serveur.** Elle couvre aussi le NAT en épingle : une requête venue de votre réseau local vers un hôte public ressort et revient, apparaissant avec l'IP de votre box.

### Détecter le bruteforce sur l'authentification

Les scénarios nginx détectent le **sondage** : rafales de 404, chemins connus, agents suspects. Ils ne détectent **pas** un bruteforce lent sur un formulaire de connexion — qui ne produit ni 404 ni motif inhabituel.

Pour Jellyfin, la collection communautaire `LePresidente/jellyfin` lit ses journaux applicatifs et déclenche sur les échecs d'authentification et l'énumération de comptes. Elle exige de monter le dossier de journaux de Jellyfin dans le conteneur CrowdSec.

### Le bouncer : là où ça se joue

> **Le trafic vers un conteneur ne traverse JAMAIS `INPUT`.**

Il est routé (DNAT) et passe par `FORWARD`, puis `DOCKER-USER`. Or la configuration par défaut du bouncer ne cible qu'`INPUT`. Résultat : il tourne, s'authentifie, affiche ses règles, et **ne bloque rien**.

```yaml
iptables_chains:
  - INPUT
  - FORWARD
  - DOCKER-USER    # ← la chaîne décisive
```

**Testez le blocage.** C'est la seule façon de savoir :

```bash
docker exec crowdsec cscli decisions add --ip 203.0.113.42 --duration 2m
sleep 15
docker exec crowdsec-bouncer ipset list crowdsec-blacklists-0 | tail -5
# l'IP doit apparaître, avec son délai d'expiration
docker exec crowdsec cscli decisions delete --ip 203.0.113.42
```

### Déployez la détection avant le blocage

Recommandation, pas un détail de style : **n'activez pas le blocage automatique devant un service dont d'autres personnes dépendent sans avoir d'abord vu ce qu'il aurait bloqué.**

Quelques jours en détection seule, avec notifications, vous donnent le volume et la nature réelle des déclenchements. Ensuite vous calibrez sur **vos** données. Un scénario trop sensible, et une personne qui tape mal son mot de passe trois fois se retrouve bannie au niveau du pare-feu — vous ne le découvrirez qu'à son appel.

### Si un CDN est devant

Derrière un proxy CDN, toutes les requêtes semblent venir de ses adresses. **Sans correctif, CrowdSec bannit le CDN** et coupe l'accès à tous vos services d'un coup.

```nginx
set_real_ip_from <plages du CDN>;
real_ip_header CF-Connecting-IP;   # ou l'en-tête de votre CDN
```

`set_real_ip_from` ne fait confiance qu'à ces plages : le trafic direct conserve sa vraie IP source. Les deux cas cohabitent sans réglage supplémentaire.

⚠️ **Vérifiez ce point AVANT d'activer le blocage.** Et si vous n'avez pas de CDN, ce réglage est inutile : vérifiez-le plutôt que de le supposer.

```bash
# Que voit réellement le proxy ?
docker exec npm tail -3 /data/logs/crowdsec_access.log
```

---

## Authentification à deux facteurs sur Jellyfin

Jellyfin n'a pas de 2FA native. Plusieurs extensions existent, et **elles ne se valent pas** :

| Approche | Portée | Verdict |
|---|---|---|
| 2FA sur l'interface web seule | le formulaire web | **cosmétique** — un attaquant vise l'API, pas le formulaire |
| 2FA appliquée côté serveur | tous les clients | la seule qui protège réellement |

Pour un serveur exposé, seule la seconde compte. Vérifiez ce point avant de choisir : une extension qui laisse `/Users/AuthenticateByName` ouvert ne protège rien.

**Compatibilité des clients tiers** — le point qui bloque en pratique. Une extension sérieuse propose :

- les **sessions existantes préservées** *(le blocage porte sur les nouvelles authentifications)*
- un **mot de passe d'application** révocable, pour les clients incapables de saisir un code
- un **appairage avec approbation** pour les applications de télévision
- le **contournement par clé d'API**, pour que vos automatisations continuent de fonctionner
- une **exemption du réseau local**
- une **adhésion par utilisateur** — pour ne pas imposer la 2FA à des personnes non techniques

Le dernier point est celui qui rend la chose acceptable : vous protégez votre compte administrateur sans compliquer la vie des autres.

---

## Ce qui ne sert pas à grand-chose

**La limitation de débit sur le formulaire de connexion**, si CrowdSec détecte déjà le bruteforce. Il reste une fenêtre de quelques dizaines de secondes avant le bannissement effectif, mais un mot de passe fort ne tombe pas en vingt secondes. En face, le coût est réel : les applications clientes sollicitent l'API en rafale, et un seuil mal calibré les coupe.

**Choisir un domaine discret**, contre le trafic opportuniste. Voir plus haut.

**Un dépôt git local** comme protection. Sur le même disque que les données, il ne protège de rien.

---

## Les secrets

- **Jamais dans un compose** — il est versionné
- `.env` pour l'interpolation *(exclu de git)*, `secrets/` pour les fichiers montés *(chmod 600)*
- `.env.example` versionné avec les clés et des valeurs vides : c'est la documentation de ce qu'il faut fournir

### Ce que les journaux révèlent

Certains services journalisent leur URL de notification **en clair, mot de passe compris**, à chaque envoi. Ce n'est pas configurable.

La parade n'est pas de le cacher, c'est de **limiter la portée** : un compte de publication dédié, **en écriture seule sur un seul sujet**. S'il fuite, il ne permet que d'envoyer une fausse notification.

Et prévoyez la rotation : un même identifiant peut avoir **six consommateurs** *(un fichier de secrets, deux fichiers de configuration, trois API)*. Scriptez-la avant d'en avoir besoin.

### Le socket Docker

Tout conteneur qui monte `/var/run/docker.sock` dispose de **l'équivalent de root sur la machine** — il peut monter `/` dans un nouveau conteneur.

Ça concerne les interfaces de gestion Docker. Conséquence : réseau interne uniquement, accès en `.lan`, **jamais de proxy host public**. C'est le service à ne surtout pas se tromper.

Corollaire : appartenir au groupe `docker` équivaut à `sudo` sans mot de passe. Ce n'est pas un problème si vous êtes le seul administrateur, mais autant le savoir.

---

## Sans redondance ni sauvegarde : détecter

Si vous n'avez ni RAID ni sauvegarde, la surveillance devient votre seule protection. Elle ne remplace rien, mais elle donne du temps.

| | Rôle |
|---|---|
| **SMART** *(Scrutiny)* | secteurs réalloués, secteurs en attente, erreurs CRC. Les alertes précoces sont votre seul préavis avant une panne. |
| **`btrfs scrub`** *(si applicable)* | détecte la corruption silencieuse, ce que mdadm ne sait pas faire |
| **Disponibilité** *(Gatus)* | savoir qu'un service est tombé avant que vos utilisateurs vous appellent |

⚠️ **Un monitoring sans alerte n'est qu'un tableau de bord.** Sans notification, vous ne verrez un secteur réalloué que si vous pensez à ouvrir la page. Branchez les notifications le jour où vous déployez la surveillance, pas plus tard *(voir [notifications.md](notifications.md))*.

**Indicateur utile** : `UDMA_CRC_Error_Count` à 0 signifie que votre liaison SATA est saine — nappe, connecteur, fond de panier. C'est la première cause d'erreurs disque fantômes sur une machine assemblée.
