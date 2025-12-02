# 🤝 Contributing to Media Stack

Merci de votre intérêt pour contribuer à ce projet ! Toute aide est la bienvenue.

---

## 📋 Types de contributions acceptées

- 🐛 **Bug reports** — Signaler des erreurs ou problèmes
- 💡 **Feature requests** — Proposer de nouvelles fonctionnalités
- 📝 **Documentation** — Améliorer/corriger la documentation
- 🔧 **Code** — Corrections de bugs, nouvelles features
- 🌍 **Traductions** — Traduire la documentation

---

## 🐛 Signaler un bug

### Avant de créer une issue

1. ✅ Vérifiez que le bug n'a pas déjà été signalé
2. ✅ Consultez [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
3. ✅ Vérifiez les [guides détaillés](docs/)

### Créer une issue

**Incluez :**
- 📌 Description claire du problème
- 📌 Étapes pour reproduire
- 📌 Comportement attendu vs comportement actuel
- 📌 Logs (si applicable)
- 📌 Environnement :
  - NAS : Modèle Synology + version DSM
  - Docker : Version
  - Images : Versions (radarr, sonarr, etc.)

---

## 💡 Proposer une fonctionnalité

### Template Feature Request

```markdown
**Fonctionnalité demandée**
Description claire de la feature

**Problème résolu**
Quel problème cette feature résout-elle ?

**Solution proposée**
Comment devrait-elle fonctionner ?

**Alternatives considérées**
Autres approches envisagées ?
```

---

## 📝 Contribuer à la documentation

### Setup

```bash
git clone https://github.com/vkarcher/media-stack.git
cd media-stack
```

### Guidelines

1. **Markdown** : Utilisez GitHub Flavored Markdown
2. **Langue** : Français (ce projet)
3. **Style** :
   - Titres clairs et hiérarchiques
   - Exemples concrets
   - Code blocks avec syntaxe
   - Tables pour comparaisons

### Structure

```
docs/
├─ apps/          # Guides par application
├─ guides/        # Guides thématiques
└─ README.md      # Index documentation
```

### Soumettre

```bash
git checkout -b doc/ma-contribution
# Faites vos modifications
git add .
git commit -m "docs: amélioration guide Radarr"
git push origin doc/ma-contribution
```

Puis créez une Pull Request.

---

## 🔧 Contribuer au code

### Prérequis

- Git
- Docker
- Synology NAS (ou VM de test)

### Workflow

**1. Fork le projet**

Cliquez sur "Fork" sur GitHub

**2. Clone votre fork**

```bash
git clone https://github.com/vkarcher/media-stack.git
cd media-stack
```

**3. Créez une branche**

```bash
git checkout -b feature/ma-nouvelle-feature
```

**4. Faites vos modifications**

```bash
# Testez localement
./setup.sh
```

**5. Commit**

Format de commit :
```
type(scope): description courte

[Corps optionnel plus détaillé]
```

**Types :**
- `feat:` — Nouvelle fonctionnalité
- `fix:` — Correction bug
- `docs:` — Documentation
- `style:` — Formatage, pas de changement code
- `refactor:` — Refactoring
- `test:` — Ajout tests
- `chore:` — Maintenance

**Exemples :**
```
feat(setup): ajout support QNAP
fix(docker): correction permissions volumes
docs(radarr): mise à jour guide profils qualité
```

**6. Push**

```bash
git push origin feature/ma-nouvelle-feature
```

**7. Pull Request**

Sur GitHub, créez une Pull Request vers `main`.

---

## ✅ Checklist avant PR

- [ ] Code testé localement
- [ ] Documentation mise à jour (si nécessaire)
- [ ] Commit messages clairs
- [ ] Pas de fichiers sensibles (API keys, passwords)
- [ ] Respect style existant

---

## 🎨 Style Guide

### Shell scripts

```bash
# Bonnes pratiques
set -e  # Arrêt si erreur
set -u  # Erreur si variable non définie

# Variables en MAJUSCULES
DOCKER_PATH="/volume1/docker"

# Fonctions nommées clairement
function create_folders() {
    ...
}
```

### Docker Compose

```yaml
# Indentation 2 espaces
services:
  radarr:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr
    environment:
      - PUID=1026
      - PGID=100
```

### Documentation Markdown

```markdown
# Titre H1

## Titre H2

### Titre H3

**Gras** pour emphase
`code` pour commandes
```

---

## 🧪 Tests

### Tester localement

```bash
# Setup complet
./setup.sh

# Vérifier tous services running
docker ps

# Tester accès WebUI
curl http://localhost:7878  # Radarr
curl http://localhost:8989  # Sonarr
```

---

## 📜 Code of Conduct

### Nos valeurs

- ✅ **Respectueux** — Envers tous les contributeurs
- ✅ **Constructif** — Feedback bienveillant
- ✅ **Inclusif** — Tous niveaux bienvenus
- ✅ **Collaboratif** — Entraide et partage

### Comportements inacceptables

- ❌ Harcèlement, insultes
- ❌ Discrimination
- ❌ Spam, trolling
- ❌ Partage d'informations privées

---

## 💬 Questions ?

- 💡 **Issues GitHub** — Pour bugs/features
- 📖 **Discussions GitHub** — Pour questions générales
- 📚 **Documentation** — [docs/](docs/)

---

## 📄 Licence

En contribuant, vous acceptez que vos contributions soient sous licence MIT.

Voir [LICENSE](LICENSE) pour détails.

---

**Merci de contribuer à améliorer ce projet ! 🎉**
