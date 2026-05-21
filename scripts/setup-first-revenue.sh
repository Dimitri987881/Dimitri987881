#!/usr/bin/env bash
# Configuration interactive du système d'affiliation
# Lance ce script UNE FOIS après avoir obtenu tes clés API

set -euo pipefail

ENV_FILE=".env"
WORKFLOW="workflows/n8n-affiliate-workflow.json"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   🚀 SETUP PREMIER REVENU — AFFILIATION     ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Vérifie que jq est installé
command -v jq >/dev/null || { echo "❌ jq requis: sudo apt install jq"; exit 1; }

# Crée le fichier .env s'il n'existe pas
touch "$ENV_FILE"
chmod 600 "$ENV_FILE"

save_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" "$ENV_FILE" 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${val}|" "$ENV_FILE"
  else
    echo "${key}=${val}" >> "$ENV_FILE"
  fi
}

ask() {
  local key="$1" label="$2" current
  current=$(grep "^${key}=" "$ENV_FILE" 2>/dev/null | cut -d= -f2- || echo "")
  if [[ -n "$current" ]]; then
    echo "  ↳ $label [déjà configuré, Entrée pour garder]"
    read -r -p "    Valeur : " val
    [[ -z "$val" ]] && val="$current"
  else
    read -r -p "  → $label : " val
  fi
  [[ -n "$val" ]] && save_env "$key" "$val"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 1 : Claude API (Anthropic)"
echo "  👉 https://console.anthropic.com → API Keys"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ask "ANTHROPIC_API_KEY" "Clé API Anthropic (commence par sk-ant-)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 2 : WordPress"
echo "  👉 Tableau de bord WP → Utilisateurs → Profil → Mots de passe d'application"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ask "WP_URL" "URL de ton site (ex: https://monsite.com)"
ask "WP_USERNAME" "Nom d'utilisateur WordPress"
ask "WP_APP_PASSWORD" "Mot de passe d'application WordPress"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 3 : Facebook"
echo "  👉 developers.facebook.com → Graph API Explorer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ask "FACEBOOK_PAGE_ID" "ID de ta Page Facebook"
ask "FACEBOOK_PAGE_TOKEN" "Token de Page Facebook"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 4 : Mailchimp"
echo "  👉 mailchimp.com → Account → Extras → API Keys"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
ask "MAILCHIMP_API_KEY" "Clé API Mailchimp"
ask "MAILCHIMP_LIST_ID" "ID de liste (Audience ID)"
ask "MAILCHIMP_SERVER" "Serveur datacenter (ex: us14)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 5 : Twitter/X (OPTIONNEL — coûte 100$/mois)"
echo "  Appuie Entrée pour ignorer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -r -p "  → Tu as un accès Twitter API Basic ? (o/N) : " has_twitter
if [[ "${has_twitter,,}" == "o" ]]; then
  ask "TWITTER_API_KEY" "Twitter API Key"
  ask "TWITTER_API_SECRET" "Twitter API Secret"
  ask "TWITTER_ACCESS_TOKEN" "Twitter Access Token"
  ask "TWITTER_ACCESS_SECRET" "Twitter Access Token Secret"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 6 : Slack (OPTIONNEL — pour les notifications)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -r -p "  → Tu as un Slack webhook URL ? (o/N) : " has_slack
if [[ "${has_slack,,}" == "o" ]]; then
  ask "SLACK_WEBHOOK_URL" "URL Webhook Slack"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ÉTAPE 7 : Liens d'affiliation Amazon"
echo "  👉 affiliate-program.amazon.com → Obtenir ton tag"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -r -p "  → Ton Amazon Associates Tag (ex: montag-20) : " amazon_tag
if [[ -n "$amazon_tag" ]]; then
  save_env "AMAZON_AFFILIATE_TAG" "$amazon_tag"
  echo "  ✅ Tag Amazon sauvegardé"
  echo ""
  echo "  🔗 Tes liens seront générés automatiquement :"
  echo "     https://www.amazon.com/s?k=trending&tag=${amazon_tag}"
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ Configuration sauvegardée dans .env    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  Prochaine étape : ./scripts/inject-env-to-workflow.sh"
echo "  Pour voir ce qui est configuré : ./scripts/validate-workflow.sh --check-env"
echo ""
