#!/usr/bin/env bash
# Teste chaque connexion API avant de lancer le workflow
# Identifie exactement ce qui fonctionne et ce qui bloque

set -euo pipefail

ENV_FILE=".env"
[[ -f "$ENV_FILE" ]] && source "$ENV_FILE"

OK=0; FAIL=0; SKIP=0

check() {
  local name="$1" result="$2"
  if [[ "$result" == "ok" ]]; then
    echo "  ✅ $name"
    ((OK++))
  elif [[ "$result" == "skip" ]]; then
    echo "  ⏭️  $name — non configuré (optionnel)"
    ((SKIP++))
  else
    echo "  ❌ $name — $result"
    ((FAIL++))
  fi
}

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   🔌 TEST DES CONNEXIONS API                ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# 1. Anthropic / Claude
if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    "https://api.anthropic.com/v1/models" 2>/dev/null || echo "000")
  [[ "$HTTP" == "200" ]] && check "Claude API (Anthropic)" "ok" || check "Claude API (Anthropic)" "HTTP $HTTP — clé invalide ?"
else
  check "Claude API (Anthropic)" "skip"
fi

# 2. WordPress
if [[ -n "${WP_URL:-}" && -n "${WP_USERNAME:-}" && -n "${WP_APP_PASSWORD:-}" ]]; then
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "${WP_USERNAME}:${WP_APP_PASSWORD}" \
    "${WP_URL}/wp-json/wp/v2/posts?per_page=1" 2>/dev/null || echo "000")
  [[ "$HTTP" == "200" ]] && check "WordPress REST API" "ok" || check "WordPress REST API" "HTTP $HTTP — vérifiez l'URL et le mot de passe d'application"
else
  check "WordPress REST API" "skip"
fi

# 3. Facebook
if [[ -n "${FACEBOOK_PAGE_TOKEN:-}" && -n "${FACEBOOK_PAGE_ID:-}" ]]; then
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    "https://graph.facebook.com/v18.0/${FACEBOOK_PAGE_ID}?access_token=${FACEBOOK_PAGE_TOKEN}" 2>/dev/null || echo "000")
  [[ "$HTTP" == "200" ]] && check "Facebook Graph API" "ok" || check "Facebook Graph API" "HTTP $HTTP — token expiré ?"
else
  check "Facebook Graph API" "skip"
fi

# 4. Mailchimp
if [[ -n "${MAILCHIMP_API_KEY:-}" && -n "${MAILCHIMP_SERVER:-}" ]]; then
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -u "anystring:${MAILCHIMP_API_KEY}" \
    "https://${MAILCHIMP_SERVER}.api.mailchimp.com/3.0/ping" 2>/dev/null || echo "000")
  [[ "$HTTP" == "200" ]] && check "Mailchimp API" "ok" || check "Mailchimp API" "HTTP $HTTP — clé ou serveur invalide ?"
else
  check "Mailchimp API" "skip"
fi

# 5. Twitter (optionnel)
if [[ -n "${TWITTER_API_KEY:-}" ]]; then
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer ${TWITTER_ACCESS_TOKEN:-}" \
    "https://api.twitter.com/2/users/me" 2>/dev/null || echo "000")
  [[ "$HTTP" == "200" ]] && check "Twitter API v2" "ok" || check "Twitter API v2" "HTTP $HTTP"
else
  check "Twitter API v2 (optionnel — 100\$/mois)" "skip"
fi

# 6. Slack (optionnel)
if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
  HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST -H "Content-Type: application/json" \
    -d '{"text":"🔌 Test connexion OK — système d affiliation prêt !"}' \
    "${SLACK_WEBHOOK_URL}" 2>/dev/null || echo "000")
  [[ "$HTTP" == "200" ]] && check "Slack Webhook" "ok" || check "Slack Webhook" "HTTP $HTTP"
else
  check "Slack Webhook (optionnel)" "skip"
fi

# 7. Amazon Associates (vérifie juste que le tag est configuré)
if [[ -n "${AMAZON_AFFILIATE_TAG:-}" ]]; then
  check "Amazon Associates Tag (${AMAZON_AFFILIATE_TAG})" "ok"
else
  check "Amazon Associates Tag" "skip"
fi

# 8. Reddit (accès public, pas de clé)
HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "User-Agent: AffiliateBot/1.0" \
  "https://www.reddit.com/r/all/hot.json?limit=1" 2>/dev/null || echo "000")
[[ "$HTTP" == "200" ]] && check "Reddit API (public)" "ok" || check "Reddit API (public)" "HTTP $HTTP"

# 9. Google Trends (accès public)
HTTP=$(curl -s -o /dev/null -w "%{http_code}" \
  "https://trends.google.com/trends/trendingsearches/daily/rss?geo=US" 2>/dev/null || echo "000")
[[ "$HTTP" == "200" ]] && check "Google Trends (public)" "ok" || check "Google Trends (public)" "HTTP $HTTP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Résultat : ✅ $OK OK  |  ❌ $FAIL erreur(s)  |  ⏭️  $SKIP ignoré(s)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "  🚀 Toutes les connexions actives sont OK !"
  echo "     Tu peux lancer le workflow dans n8n."
else
  echo "  ⚠️  Corrige les ❌ avant de lancer le workflow."
fi
echo ""
