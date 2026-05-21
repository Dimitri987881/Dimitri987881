# Validate n8n Workflow

Valide le fichier `workflows/n8n-affiliate-workflow.json` en vérifiant :

1. La syntaxe JSON (bien formé)
2. La présence des champs obligatoires n8n (`nodes`, `connections`, `settings`)
3. Le nombre de nœuds (doit être 17)
4. Que tous les nœuds ont un `id`, `name`, et `type`
5. Que les connexions référencent des nœuds existants
6. Que le nœud Schedule Trigger est présent
7. Que le nœud Claude API pointe vers `claude-opus-4-7`

Utilise les commandes bash avec `jq` et `python3 -m json.tool` pour chaque vérification. Affiche un rapport clair avec ✅ ou ❌ pour chaque point.
