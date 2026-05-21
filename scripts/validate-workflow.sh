#!/usr/bin/env bash
set -euo pipefail

WORKFLOW="workflows/n8n-affiliate-workflow.json"
ERRORS=0
CHECK_ENV=false

[[ "${1:-}" == "--check-env" ]] && CHECK_ENV=true

echo "========================================"
echo " Validation n8n Workflow"
echo "========================================"
echo ""

# 1. Existence du fichier
if [[ ! -f "$WORKFLOW" ]]; then
  echo "❌ Fichier introuvable: $WORKFLOW"
  exit 1
fi
echo "✅ Fichier trouvé: $WORKFLOW"

# 2. Syntaxe JSON
if python3 -m json.tool "$WORKFLOW" > /dev/null 2>&1; then
  echo "✅ Syntaxe JSON valide"
else
  echo "❌ JSON invalide — vérifiez avec: python3 -m json.tool $WORKFLOW"
  exit 1
fi

# 3. Champs obligatoires n8n
for field in nodes connections settings; do
  if jq -e ".$field" "$WORKFLOW" > /dev/null 2>&1; then
    echo "✅ Champ requis présent: .$field"
  else
    echo "❌ Champ manquant: .$field"
    ((ERRORS++))
  fi
done

# 4. Nombre de nœuds
NODE_COUNT=$(jq '.nodes | length' "$WORKFLOW")
echo ""
echo "📊 Nœuds dans le workflow: $NODE_COUNT"
if [[ "$NODE_COUNT" -ge 10 ]]; then
  echo "✅ Nombre de nœuds correct ($NODE_COUNT)"
else
  echo "⚠️  Nombre de nœuds faible ($NODE_COUNT) — workflow peut-être incomplet"
fi

# 5. Nœud Schedule Trigger
if jq -e '.nodes[] | select(.type == "n8n-nodes-base.scheduleTrigger")' "$WORKFLOW" > /dev/null 2>&1; then
  echo "✅ Schedule Trigger présent"
else
  echo "❌ Schedule Trigger manquant"
  ((ERRORS++))
fi

# 6. Nœud Claude API
if jq -e '.nodes[] | select(.name | test("Claude"; "i"))' "$WORKFLOW" > /dev/null 2>&1; then
  echo "✅ Nœud Claude API présent"
else
  echo "⚠️  Nœud Claude API non détecté par nom"
fi

# 7. Vérification env vars (optionnel)
if [[ "$CHECK_ENV" == true ]]; then
  echo ""
  echo "========================================"
  echo " Vérification Variables d'Environnement"
  echo "========================================"
  echo ""

  REQUIRED_VARS=(
    "ANTHROPIC_API_KEY"
    "TWITTER_API_KEY"
    "TWITTER_API_SECRET"
    "TWITTER_ACCESS_TOKEN"
    "TWITTER_ACCESS_SECRET"
    "WP_URL"
    "WP_USERNAME"
    "WP_APP_PASSWORD"
    "FACEBOOK_PAGE_TOKEN"
    "FACEBOOK_PAGE_ID"
    "MAILCHIMP_API_KEY"
    "MAILCHIMP_LIST_ID"
    "MAILCHIMP_SERVER"
  )

  MISSING=0
  for var in "${REQUIRED_VARS[@]}"; do
    if [[ -n "${!var:-}" ]]; then
      echo "✅ $var"
    else
      echo "❌ $var — NON DÉFINI"
      ((MISSING++))
    fi
  done

  SLACK="${SLACK_WEBHOOK_URL:-}"
  if [[ -n "$SLACK" ]]; then
    echo "✅ SLACK_WEBHOOK_URL (optionnel)"
  else
    echo "⚠️  SLACK_WEBHOOK_URL non défini (optionnel)"
  fi

  echo ""
  echo "Score: $((13 - MISSING))/13 variables configurées"
  [[ "$MISSING" -gt 0 ]] && ((ERRORS += MISSING))
fi

echo ""
echo "========================================"
if [[ "$ERRORS" -eq 0 ]]; then
  echo " ✅ Validation réussie — workflow prêt"
else
  echo " ❌ $ERRORS erreur(s) détectée(s)"
fi
echo "========================================"

exit "$ERRORS"
