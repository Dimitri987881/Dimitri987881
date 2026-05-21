#!/usr/bin/env bash
# Injecte les liens Amazon dans le workflow et génère la version n8n-ready
# Le workflow n8n lira les clés API via ses propres variables d'environnement

set -euo pipefail

ENV_FILE=".env"
WORKFLOW_SRC="workflows/n8n-affiliate-workflow.json"
WORKFLOW_OUT="workflows/n8n-affiliate-workflow.ready.json"

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   🔗 INJECTION DES LIENS AMAZON             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Charge les variables d'environnement
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Lance d'abord : ./scripts/setup-first-revenue.sh"
  exit 1
fi
source "$ENV_FILE"

TAG="${AMAZON_AFFILIATE_TAG:-}"
if [[ -z "$TAG" ]]; then
  echo "❌ AMAZON_AFFILIATE_TAG non défini dans .env"
  echo "   Lance ./scripts/setup-first-revenue.sh"
  exit 1
fi

echo "  Tag Amazon détecté : $TAG"
echo "  Génération des liens d'affiliation..."
echo ""

# Génère des liens Amazon réels par catégorie de tendance
declare -A LINKS=(
  [AFFILIATE_LINK_1]="https://www.amazon.com/s?k=trending+products+2024&tag=${TAG}"
  [AFFILIATE_LINK_2]="https://www.amazon.com/s?k=best+sellers&tag=${TAG}"
  [AFFILIATE_LINK_3]="https://www.amazon.com/s?k=top+rated+products&tag=${TAG}"
  [AFFILIATE_LINK_4]="https://www.amazon.com/s?k=deals+of+the+day&tag=${TAG}"
  [AFFILIATE_LINK_5]="https://www.amazon.com/s?k=budget+picks&tag=${TAG}"
  [AFFILIATE_LINK_6]="https://www.amazon.com/s?k=new+releases&tag=${TAG}"
  [AFFILIATE_LINK_7]="https://www.amazon.com/s?k=amazon+choice&tag=${TAG}"
  [AFFILIATE_LINK_8]="https://www.amazon.com/s?k=limited+time+deals&tag=${TAG}"
  [AFFILIATE_LINK_9]="https://www.amazon.com/s?k=flash+sale&tag=${TAG}"
  [AFFILIATE_LINK_MAIN]="https://www.amazon.com/deals?tag=${TAG}"
)

# Copie le workflow source
cp "$WORKFLOW_SRC" "$WORKFLOW_OUT"

# Remplace chaque placeholder
for placeholder in "${!LINKS[@]}"; do
  url="${LINKS[$placeholder]}"
  # Échappe les caractères spéciaux pour sed
  escaped_url=$(printf '%s\n' "$url" | sed 's/[[\.*^$()+?{|]/\\&/g')
  sed -i "s|\[${placeholder}\]|${url}|g" "$WORKFLOW_OUT"
  echo "  ✅ [${placeholder}] → ${url:0:60}..."
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Valide le JSON généré
if python3 -m json.tool "$WORKFLOW_OUT" > /dev/null 2>&1; then
  echo "  ✅ JSON valide : $WORKFLOW_OUT"
else
  echo "  ❌ Erreur JSON dans le fichier généré"
  exit 1
fi

SIZE=$(wc -c < "$WORKFLOW_OUT")
echo "  📦 Taille du workflow : ${SIZE} octets"
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║   ✅ Workflow prêt à importer dans n8n !    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  1. Va sur ton instance n8n"
echo "  2. Workflows → Import from file"
echo "  3. Sélectionne : $WORKFLOW_OUT"
echo "  4. Configure les variables d'environnement dans n8n"
echo "  5. Active le workflow !"
echo ""
