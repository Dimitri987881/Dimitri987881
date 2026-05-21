#!/usr/bin/env bash
set -euo pipefail

# Utilise Claude Code en mode headless pour analyser les derniers changements du workflow.
# Prérequis: claude CLI installé et authentifié

if ! command -v claude &> /dev/null; then
  echo "❌ Claude CLI introuvable. Installez-le avec: npm install -g @anthropic-ai/claude-code"
  exit 1
fi

WORKFLOW="workflows/n8n-affiliate-workflow.json"
OUTPUT_FILE="review-$(date +%Y%m%d-%H%M%S).md"

echo "🔍 Analyse des changements du workflow n8n via Claude..."
echo ""

# Récupère le diff des changements récents
if git diff HEAD~1 -- "$WORKFLOW" 2>/dev/null | grep -q '^[+-]'; then
  DIFF=$(git diff HEAD~1 -- "$WORKFLOW")
  CONTEXT="Voici le diff git du workflow n8n d'affiliation (Reddit/Google Trends → Claude API → Twitter/WordPress/Facebook/Mailchimp) :"
  INPUT="$CONTEXT\n\n\`\`\`diff\n$DIFF\n\`\`\`\n\nAnalyse ces changements et réponds en français :\n1. Résumé des modifications (2-3 phrases)\n2. Risques potentiels identifiés\n3. Recommandations avant mise en production"
else
  # Pas de diff — analyse le workflow complet
  echo "ℹ️  Pas de diff récent — analyse complète du workflow"
  WORKFLOW_CONTENT=$(cat "$WORKFLOW")
  INPUT="Analyse ce workflow n8n d'affiliation et réponds en français :\n1. Points forts de l'architecture\n2. Risques et fragilités identifiés\n3. Top 3 recommandations d'amélioration\n\nWorkflow:\n\`\`\`json\n$(echo "$WORKFLOW_CONTENT" | head -c 8000)\n\`\`\`"
fi

echo "$INPUT" | claude --print > "$OUTPUT_FILE"

echo "✅ Analyse terminée → $OUTPUT_FILE"
echo ""
cat "$OUTPUT_FILE"
