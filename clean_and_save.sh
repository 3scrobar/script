#!/usr/bin/env bash
# auto_multi_repo_fclean_commit.sh
# Parcourt récursivement les dossiers, détecte les dépôts Git,
# exécute make fclean où il y a un Makefile, puis commit + push dans CHAQUE dépôt.

set -euo pipefail

DRY_RUN=false
if [[ "${1-}" == "--dry-run" ]]; then
DRY_RUN=true
echo "[Dry-run] Aucun make/git ne sera exécuté."
fi

ROOT="$(pwd)"
echo "Dossier racine de scan: $ROOT"
echo "Recherche des dépôts Git…"

# Trouver les racines de dépôts Git:
# - Un dépôt est reconnu si $dir/.git existe (fichier OU dossier, gère worktrees/submodules)
# - On évite de redescendre dans .git/*
mapfile -d '' REPOS < <(
find "$ROOT" -type d -not -path '*/.git/*' -print0 \
| while IFS= read -r -d '' dir; do
	if [[ -e "$dir/.git" ]]; then
		printf '%s\0' "$dir"
	fi
	done | sort -z -u
)

if (( ${#REPOS[@]} == 0 )); then
echo "Aucun dépôt Git trouvé sous: $ROOT"
exit 0
fi

echo "Dépôts trouvés: ${#REPOS[@]}"
echo "----------------------------------------"

for repo in "${REPOS[@]}"; do
echo "==> Dépôt: $repo"
(
	cd "$repo"

	# Vérifier que c'est bien un dépôt git exploitable
	if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	echo "  [Skip] Ce dossier n'est pas un dépôt Git valide."
	exit 0
	fi

	# Lister tous les dossiers contenant un Makefile/makefile (hors .git)
	mapfile -d '' MAKE_DIRS < <(
	find . -type f \( -iname 'Makefile' -o -iname 'makefile' \) \
		-not -path './.git/*' -printf '%h\0' | sort -z -u
	)

	if (( ${#MAKE_DIRS[@]} == 0 )); then
	echo "  Aucun Makefile trouvé dans ce dépôt."
	else
	echo "  Dossiers avec Makefile: ${#MAKE_DIRS[@]}"
	fi

	# make fclean dans chaque dossier concerné
	for d in "${MAKE_DIRS[@]:-}"; do
	echo "  → $d"
	(
		cd "$d"
		if make -n fclean >/dev/null 2>&1; then
		if $DRY_RUN; then
			echo "    [Dry-run] make fclean"
		else
			echo "    Exécution: make fclean"
			if ! make fclean; then
			echo "    [Warn] 'make fclean' a échoué (on continue)."
			fi
		fi
		else
		echo "    [Info] Cible 'fclean' introuvable, on passe."
		fi
	)
	done

	# Opérations Git pour CE dépôt
	if $DRY_RUN; then
	echo "  [Dry-run] git add -A"
	echo "  [Dry-run] git commit -m \"Auto clean: $(date '+%Y-%m-%d %H:%M:%S %z')\""
	echo "  [Dry-run] git push"
	else
	git add -A
	COMMIT_MSG="Auto clean: $(date '+%Y-%m-%d %H:%M:%S %z')"
	if git diff --cached --quiet; then
		echo "  Rien à committer."
	else
		if git commit -m "$COMMIT_MSG"; then
		echo "  Commit: $COMMIT_MSG"
		fi
	fi

	# Tenter un push uniquement si un remote existe
	if git remote >/dev/null 2>&1 && [[ -n "$(git remote)" ]]; then
		if ! git push; then
		echo "  [Warn] git push a échoué (remote/protection ?)."
		fi
	else
		echo "  [Info] Aucun remote configuré, push ignoré."
	fi
	fi
)
echo "----------------------------------------"
done

echo "Terminé."
