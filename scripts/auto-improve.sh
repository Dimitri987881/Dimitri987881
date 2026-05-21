#!/usr/bin/env bash
set -euo pipefail

# Pipe le workflow n8n vers Claude pour obtenir des suggestions d'amélioration structurées.
# Les suggestions sont sauvegardées dans suggestions.md et affichées dans le terminal.
# Prérequis: claude CLI installé et authentifié

if ! command -v claude &> /dev/null; then
  echo "❌ Claude CLI introuvable. Installez-le avec: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

WORKFLOW="workflows/n8n-affiliate-workflow.json"
OUTPUT="suggestions.md"

if [[ ! -f "$WORKFLOW" ]]; then
  echo "❌ Workflow introuvable: $WORKFLOW"
  exit 1
fi

echo "🤖 Génération de suggestions d'amélioration via Claude..."
echo ""

WORKFLOW_SUMMARY=$(jq '{
  name: .name,
  node_count: (.nodes | length),
  node_types: [.nodes[].type] | unique,
  node_names: [.nodes[].name]
}' "$WORKFLOW")

PROMPT="Tu es un expert n8n et automatisation d'affiliation. Analyse ce workflow n8n et génère exactement 5 suggestions d'amélioration concrètes en français.

Résumé du workflow:
\`\`\`json
$WORKFLOW_SUMMARY
\`\`\`

Contexte: Pipeline d'affiliation automatisé qui scrape les tendances US (Reddit + Google Trends) toutes les 4h, génère du contenu avec Claude Opus 4.7, et publie sur Twitter, WordPress, Facebook et Mailchimp.

Format de réponse OBLIGATOIRE:

# Suggestions d'amélioration — $(date +%Y-%m-%d)

## 1. [HAUTE PRIORITÉ] Titre
**Problème:** ...
**Solution:** ...
**Effort:** Faible/Moyen/Élevé

## 2. [HAUTE PRIORITÉ] Titre
...

## 3. [MOYENNE PRIORITÉ] Titre
...

## 4. [MOYENNE PRIORITÉ] Titre
...

## 5. [BASSE PRIORITÉ] Titre
..."

echo "$PROMPT" | claude --print > "$OUTPUT"

echo "✅ Suggestions générées → $OUTPUT"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat "$OUTPUT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Pour implémenter une suggestion, lancez Claude Code et tapez:"
echo "   /improve-workflow"
