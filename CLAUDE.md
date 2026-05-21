# Projet : US Trends → Claude Affiliation → Multiplateforme

## Vue d'ensemble

Pipeline d'affiliation automatisé qui scrape les tendances US toutes les 4 heures, génère du contenu avec Claude AI, et publie sur 4 plateformes simultanément.

**Stack :** n8n (orchestration) · Claude Opus 4.7 (génération) · Twitter · WordPress · Facebook · Mailchimp · Slack

---

## Architecture du Pipeline (17 nœuds n8n)

```
[Scheduler 4h]
    ↓
[Reddit Hot US] → [Process Reddit]  ──┐
[Google Trends US] → [Process Google] ─┤
                                       ↓
                              [Fusionner Tendances]
                                       ↓
                              [Filtrer & Classer Top 5]
                                       ↓
                              [Loop sur chaque tendance]
                                       ↓
                              [Préparer Prompt Claude]
                                       ↓
                         [Claude API - claude-opus-4-7]
                                       ↓
                              [Parser Réponse JSON]
                         ┌─────────────┼──────────────┐
                         ↓             ↓               ↓
                   [Twitter]    [WordPress]      [Facebook]
                                                       ↓
                                              [Mailchimp Draft]
                                                       ↓
                                              [Rapport Slack]
```

**Critères de filtrage Reddit :** score ≥ 500, non-NSFW, top 12 par engagement
**Catégories à multiplicateur x2 :** tech, fitness, finance, beauté
**Contenu généré par tendance :** thread Twitter (7 tweets), article WordPress (HTML + SEO), post Facebook (≤480 chars), campagne Mailchimp, métadonnées SEO

---

## Variables d'Environnement Requises (13)

| Variable | Service |
|---|---|
| `ANTHROPIC_API_KEY` | Claude API |
| `TWITTER_API_KEY` | Twitter OAuth 1.0a |
| `TWITTER_API_SECRET` | Twitter OAuth 1.0a |
| `TWITTER_ACCESS_TOKEN` | Twitter OAuth 1.0a |
| `TWITTER_ACCESS_SECRET` | Twitter OAuth 1.0a |
| `WP_URL` | WordPress REST API |
| `WP_USERNAME` | WordPress Basic Auth |
| `WP_APP_PASSWORD` | WordPress Basic Auth |
| `FACEBOOK_PAGE_TOKEN` | Facebook Graph API v18 |
| `FACEBOOK_PAGE_ID` | Facebook Page ID |
| `MAILCHIMP_API_KEY` | Mailchimp API v3 |
| `MAILCHIMP_LIST_ID` | Mailchimp Audience ID |
| `MAILCHIMP_SERVER` | Mailchimp datacenter (ex: us14) |

> La variable `SLACK_WEBHOOK_URL` est optionnelle mais recommandée pour le monitoring.

---

## Commandes Clés

```bash
# Valider le workflow JSON avant import dans n8n
./scripts/validate-workflow.sh

# Vérifier que toutes les env vars sont configurées
./scripts/validate-workflow.sh --check-env

# Review headless des derniers changements via Claude
./scripts/claude-review.sh

# Obtenir des suggestions d'amélioration du workflow
./scripts/auto-improve.sh

# Configurer les git hooks locaux (à faire 1 seule fois)
./scripts/setup-hooks.sh
```

---

## Slash Commands Claude Code

| Commande | Action |
|---|---|
| `/validate-workflow` | Valide JSON n8n + structure des nœuds |
| `/improve-workflow` | Analyse et propose des améliorations |
| `/deploy-check` | Vérifie les 13 variables d'environnement |

---

## Conventions

- **Fichier workflow :** `workflows/n8n-affiliate-workflow.json` — JSON brut exporté depuis n8n
- **Ne jamais** formater/reformater le JSON sans valider avec `python3 -m json.tool` d'abord
- **Modèle Claude :** `claude-opus-4-7` (défini dans le nœud HTTP du workflow)
- **Tokens max :** 4096 (suffisant pour les 5 formats de contenu)
- **Température :** 0.7 (équilibre créativité/cohérence)

---

## CI/CD

- **Push sur n'importe quelle branche** → `.github/workflows/validate.yml` valide le JSON
- **PR vers main** → `.github/workflows/claude-review.yml` analyse les changements

## Git Hooks Locaux

Après `./scripts/setup-hooks.sh` :
- **pre-commit** → bloque le commit si le JSON n8n est invalide
- **post-commit** → génère une entrée CHANGELOG via Claude (si `claude` CLI installé)
