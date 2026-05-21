#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Configuration des git hooks locaux..."
echo ""

# Vérifie qu'on est dans un dépôt git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Pas dans un dépôt git"
  exit 1
fi

# Configure git pour pointer vers .githooks/
git config core.hooksPath .githooks
echo "✅ core.hooksPath → .githooks/"

# Rend les hooks exécutables
chmod +x .githooks/pre-commit .githooks/post-commit
echo "✅ Permissions +x appliquées aux hooks"

# Vérifie l'installation
echo ""
echo "📋 Hooks installés :"
echo "   pre-commit  → validation JSON n8n avant chaque commit"
echo "   post-commit → entrée CHANGELOG via Claude (si claude CLI disponible)"
echo ""

# Vérifie si claude CLI est disponible pour le post-commit hook
if command -v claude &> /dev/null; then
  echo "✅ claude CLI détecté — post-commit hook pleinement opérationnel"
else
  echo "⚠️  claude CLI non trouvé — le post-commit hook sera silencieux"
  echo "   Installez Claude Code : npm install -g @anthropic-ai/claude-code"
fi

echo ""
echo "✅ Setup terminé. Testez avec : git commit --allow-empty -m 'test hooks'"
