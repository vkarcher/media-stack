# 🌐 Reverse proxy, domaines et certificats

Comment exposer ce qui doit l'être, garder le reste privé, et n'avoir plus jamais à toucher au DNS.

---

## Le principe : « public » ≠ « ouvert à tous » ≠ « expose votre IP »

Trois notions distinctes, souvent confondues :

| Catégorie | Proxy CDN | Qui entre | Effet sur votre IP |
|---|---|---|---|
| **Produit public** | possible | tout le monde | masquée par le CDN |
| **Restreint** | + portail d'identité | invités uniquement | masquée |
| **Non proxifiable** | impossible | titulaires d'un compte | **révélée** |
| **Privé** | — | vous, via VPN | invisible |

**Le streaming vidéo relève de la troisième ligne.** Les conditions d'utilisation des principaux CDN interdisent d'y faire passer de la vidéo en volume : Jellyfin doit donc sortir en direct, et son enregistrement DNS pointe vers votre IP réelle.

> **Conséquence à assumer : dès qu'un service de streaming est public, votre IP l'est aussi.** Le masquage par CDN de vos autres services devient cosmétique — qui résout le nom du service de streaming obtient votre IP et peut tenter le proxy directement.

Ce que ça déplace : la défense ne repose plus sur la discrétion, mais sur le durcissement *(voir [securite.md](securite.md))*.

---

## Le schéma de nommage

Deux zones, une seule règle à retenir :

| Forme | Usage | DNS | Exposé ? |
|---|---|---|---|
| `stream.exemple.com` | streaming | A → **IP publique** | oui |
| `request.exemple.com` | portail de requêtes | A → **IP publique** | oui |
| `*.lan.exemple.com` | **tout le reste** | A → **IP privée** | **non** |

Le motif `.lan.` est ce qui rend le privé propre : l'enregistrement DNS est public, mais il pointe vers une **IP privée**, donc injoignable depuis Internet. Chez vous ou via votre VPN, le nom résout et le proxy répond avec un certificat valide.

Vous obtenez des URL HTTPS lisibles sur vos interfaces d'administration, **sans rien exposer et sans avertissement de sécurité**.

> **Un seul enregistrement générique `*.lan` suffit.** Ajouter un service ne demande alors **aucune action DNS** : uniquement un proxy host. `sonarr.lan`, `bazarr.lan`, `gatus.lan` résolvent automatiquement.

### La réserve à connaître

Certains résolveurs **bloquent** les réponses publiques contenant une IP privée, par protection contre le *DNS rebinding*. Testez avant de construire dessus :

```bash
dig +short A test.lan.exemple.com     # doit renvoyer votre IP privée
```

Si rien ne revient, votre résolveur filtre. Le repli est un résolveur local qui répond pour `*.lan` sans rien publier — les certificats wildcard fonctionnent quand même, le DNS-01 n'ayant besoin que d'un enregistrement TXT.

---

## Certificats : deux wildcards, en DNS-01

⚠️ **Un wildcard ne couvre qu'UN seul niveau.**

`*.exemple.com` matche `stream.exemple.com` mais **pas** `sonarr.lan.exemple.com`. C'est l'erreur classique : on croit avoir tout couvert et la moitié des services servent un certificat invalide.

| Certificat | Couvre |
|---|---|
| `exemple.com` + `*.exemple.com` | les services publics |
| `*.lan.exemple.com` | les services internes |

**Les deux en DNS-01**, et ce n'est pas un choix :

- Pour les hôtes `.lan`, la validation HTTP-01 est **impossible** : Let's Encrypt appellerait une IP privée qu'il ne peut pas atteindre.
- Pour les hôtes publics, HTTP-01 fonctionnerait, mais il **dépend du port 80 ouvert en permanence**. Le jour où vous le fermez, le renouvellement échoue **en silence** — et vous le découvrez quand vos utilisateurs voient un avertissement de sécurité.

### Pourquoi un wildcard plutôt qu'un certificat par service

Trois raisons cumulatives :

**Les logs de Certificate Transparency sont publics.** Chaque certificat émis y publie son nom d'hôte. Un certificat par service publierait `sonarr.`, `bazarr.`, `gatus.` — soit la cartographie complète de votre infrastructure, consultable par n'importe qui. Un wildcard ne publie que `*.lan.exemple.com`.

**Un seul renouvellement au lieu de N.** Chaque certificat se renouvelle indépendamment et peut échouer isolément.

**Ajouter un service ne demande aucune action côté certificat.**

---

## Redirections de ports : deux règles, pas plus

| WAN | LAN | Rôle |
|---|---|---|
| **443** | 443 | HTTPS |
| **80** | 80 *(ou autre)* | redirection HTTP→HTTPS |

⚠️ **Le côté WAN doit rester 80 et 443.** C'est ce que composent les navigateurs. Mettre `WAN 4443` rend le site injoignable : plus rien n'écoute sur le 443 public.

Seul le **port LAN** change si le 80 de l'hôte est déjà occupé — certains systèmes de NAS y placent leur propre interface. Dans ce cas : `WAN 80 → LAN 8180`, et le proxy publie `8180:80`.

### Faut-il garder le port 80 ?

**Oui**, si des utilisateurs non techniques tapent votre adresse sans préfixe. Sans le 80, `exemple.com` échoue simplement. Avec lui, le proxy renvoie une redirection 301 vers HTTPS.

La surface d'attaque est quasi nulle **à condition** de fermer le serveur par défaut *(voir [securite.md](securite.md))* : sinon le port 80 sert une page qui annonce le logiciel que vous utilisez.

### Ce qu'il ne faut jamais rediriger

- l'administration du reverse proxy *(port 81)*
- la WebUI de qBittorrent — **une compromission y donne l'exécution de code**, via la fonction « exécuter un programme à la fin d'un torrent »
- toute interface *arr, Bazarr, Prowlarr
- l'interface de gestion Docker — elle détient le socket, donc l'équivalent de root

Tout ça passe par le proxy en `.lan`, joignable de chez vous ou par VPN.

---

## Réglages des proxy hosts

Pour chaque service, onglet *Details* :

- **Scheme** : `http` — le chiffrement s'arrête au proxy, le réseau Docker est interne
- **Forward Hostname** : le **nom du conteneur**, jamais l'IP de l'hôte *(ces services ne publient aucun port)*
- **Block Common Exploits** : ✅
- **Websockets Support** : ✅ — **indispensable pour les *arr**, qui utilisent SignalR pour leurs mises à jour temps réel. Sans ça leur interface se figera ou restera muette.
- **Cache Assets** : ❌ — sur une interface applicative, ça sert du JavaScript périmé après une mise à jour

Onglet *SSL* :

- le wildcard correspondant, **Force SSL**, **HTTP/2**
- **HSTS : ✅**

> **Activez HSTS.** Après une seule visite en `https://`, le navigateur mémorise que l'hôte est en HTTPS uniquement et convertit automatiquement tout `http://` ultérieur. C'est ce qui évite de tomber sur l'interface d'un autre logiciel en tapant l'adresse sans préfixe.
>
> Seule contrainte : la première visite doit être en `https://` explicite.

---

## Le piège du HTTP sur le réseau local

Si le port 80 de l'hôte est occupé par autre chose, alors sur votre réseau local `http://sonarr.lan.exemple.com` tombera sur **cet autre logiciel**, pas sur votre proxy — qui écoute sur un port différent.

Le « Force SSL » ne peut rien y faire : la requête n'atteint jamais le proxy.

**Tapez toujours `https://`** sur les hôtes internes. Et activez HSTS pour que le problème ne se pose qu'une fois par hôte.
