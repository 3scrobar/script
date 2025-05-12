#!/bin/bash

# Récupère le répertoire parent
parent_dir=$(pwd)

# Parcours de chaque dossier dans le répertoire parent
for dir in */; do
# Vérifie si c'est un dossier et si un dépôt git est présent
if [ -d "$dir/.git" ]; then
	echo "Navigating to $dir"
	cd "$dir" || continue
	
	# Effectue un git add, git commit et git push
	echo "Running git add, commit, and push in $dir"
	git add .
	
	# Utilise l'heure actuelle pour le message du commit
	commit_message="Commit at $(date '+%Y-%m-%d %H:%M:%S')"
	git commit -m "$commit_message"
	
	# Effectue le push
	git push
	
	# Retourne au répertoire parent
	cd "$parent_dir" || exit
fi
done
