# Politique de Sécurité

## Versions supportées

| Version | Supportée          |
| ------- | ------------------ |
| main    | :white_check_mark: |

## Signaler une vulnérabilité

Si vous découvrez une faille de sécurité, **ne créez PAS d'issue publique**.

**Procédure :**
1. Envoyez un email privé ou contactez via GitHub Security Advisories
2. Décrivez la vulnérabilité en détail
3. Incluez les étapes pour reproduire le problème
4. Fournissez toute information pertinente (versions affectées, impact potentiel)
5. Nous vous répondrons sous 48 heures

**GitHub Security Advisories :**
Vous pouvez également utiliser la fonctionnalité GitHub Security Advisories pour signaler une vulnérabilité de manière privée.

## Bonnes pratiques de sécurité

### Pour les utilisateurs

- 🔒 **Changez tous les mots de passe par défaut** immédiatement après installation
- 🔐 **Utilisez HTTPS** via un reverse proxy (Nginx Proxy Manager, Traefik)
- 🛡️ **N'exposez pas Overseerr directement** sur Internet sans authentification forte
- 📦 **Gardez Docker et les images à jour** régulièrement (`docker-compose pull`)
- 💾 **Sauvegardez régulièrement** vos configurations (`/volume1/docker/r-apps/*/config`)
- 🔑 **Utilisez des API Keys fortes** (ne partagez jamais vos clés)
- 🌐 **Limitez l'accès réseau** aux ports essentiels seulement
- 🔐 **Activez le VPN** (WireGuard) pour qBittorrent

### Pour les contributeurs

- ❌ **Ne committez jamais** de secrets (API keys, passwords, tokens)
- ✅ **Utilisez .gitignore** pour exclure les fichiers sensibles
- ✅ **Reviewez les dépendances** avant de les ajouter
- ✅ **Validez les entrées utilisateur** dans les scripts
- ✅ **Documentez** les implications de sécurité des changements

## Vulnérabilités connues

Aucune vulnérabilité connue actuellement.

Les mises à jour de sécurité seront documentées dans [CHANGELOG.md](CHANGELOG.md).

## Remerciements

Nous remercions les chercheurs en sécurité qui signalent de manière responsable les vulnérabilités.
