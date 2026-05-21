# Système d'Affiliation Automatisé — Claude Code + n8n

Pipeline d'affiliation entièrement automatisé : scraping des tendances US → génération de contenu IA → publication multiplateforme, piloté par **Claude Code CLI** et **n8n**.

---

## Architecture

```
[Tendances US — toutes les 4h]
      ↓
 Reddit Hot  +  Google Trends
      ↓
 Filtrage & Scoring Top 5
      ↓
 Claude Opus 4.7 (génération)
      ↓
Twitter  WordPress  Facebook  Mailchimp
      ↓
 Rapport Slack
```

**17 nœuds n8n** · **13 intégrations API** · **5 formats de contenu par tendance**

---

## Automatisation Claude Code

Ce projet exploite la **pleine puissance de Claude Code CLI** comme co-pilote permanent :

| Fonctionnalité | Usage |
|---|---|
| `CLAUDE.md` | Contexte projet chargé à chaque session |
| Hooks `.claude/settings.json` | Validation JSON automatique après chaque modification |
| Slash commands | `/validate-workflow` `/improve-workflow` `/deploy-check` |
| Mode headless `claude --print` | Claude dans les pipelines shell |
| Piping `echo ... \| claude` | Claude comme filtre Unix |
| Git hooks | Validation pre-commit + CHANGELOG auto post-commit |
| GitHub Actions CI | Validation JSON + review Claude sur PR |

---

## Installation

```bash
# 1. Cloner le dépôt
git clone https://github.com/Dimitri987881/Dimitri987881.git
cd Dimitri987881

# 2. Configurer les git hooks locaux
./scripts/setup-hooks.sh

# 3. Valider le workflow
./scripts/validate-workflow.sh

# 4. Vérifier l'environnement (avec vos clés API)
./scripts/validate-workflow.sh --check-env
```

---

## Slash Commands (dans Claude Code)

```
/validate-workflow   — Valide le JSON n8n et la structure des nœuds
/improve-workflow    — Analyse et propose 5 améliorations concrètes
/deploy-check        — Vérifie les 13 variables d'environnement
```

---

## Variables d'Environnement

Configurez ces 13 variables dans n8n (Settings → Environment Variables) :

`ANTHROPIC_API_KEY` · `TWITTER_API_KEY` · `TWITTER_API_SECRET` · `TWITTER_ACCESS_TOKEN` · `TWITTER_ACCESS_SECRET` · `WP_URL` · `WP_USERNAME` · `WP_APP_PASSWORD` · `FACEBOOK_PAGE_TOKEN` · `FACEBOOK_PAGE_ID` · `MAILCHIMP_API_KEY` · `MAILCHIMP_LIST_ID` · `MAILCHIMP_SERVER`

---

## CI/CD

Chaque push sur `workflows/` déclenche automatiquement la validation JSON.
Les PR incluent une analyse Claude du diff (nécessite le secret `ANTHROPIC_API_KEY`).
