# Deploy Check

Vérifie que l'environnement est prêt pour déployer le workflow n8n en production.

Exécute les vérifications suivantes dans l'ordre :

**1. Validation du fichier workflow**
- Le JSON est valide
- Le fichier fait plus de 1000 caractères (non vide/tronqué)

**2. Vérification des variables d'environnement**
Vérifie si ces variables sont définies dans l'environnement courant :
- `ANTHROPIC_API_KEY`
- `TWITTER_API_KEY`, `TWITTER_API_SECRET`, `TWITTER_ACCESS_TOKEN`, `TWITTER_ACCESS_SECRET`
- `WP_URL`, `WP_USERNAME`, `WP_APP_PASSWORD`
- `FACEBOOK_PAGE_TOKEN`, `FACEBOOK_PAGE_ID`
- `MAILCHIMP_API_KEY`, `MAILCHIMP_LIST_ID`, `MAILCHIMP_SERVER`
- `SLACK_WEBHOOK_URL` (optionnel)

**3. Vérification git**
- Pas de changements non commités (`git status`)
- La branche actuelle est propre

**4. Rapport final**
Affiche un tableau récapitulatif avec ✅/❌/⚠️ pour chaque point.
Score global : X/13 variables configurées.

Si des variables manquent, explique où les configurer dans n8n (Settings → Environment Variables).
