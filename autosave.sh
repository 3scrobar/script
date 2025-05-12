#!/bin/bash

while true; do
	echo "Auto save a $(date "+%Y-%m-%d %H:%M:%S")"
	echo "Accee au dossier Personelle"
	# cd /home/tle-saut/Gitperso
	git add .  # Ajoute tous les fichiers modifiés au staging area
	echo "Tout a ete add "
	# Utilisation de 'date' pour formater l'heure et la date
	# $(date "+%Y-%m-%d %H:%M:%S") : format personnalisé pour inclure année, mois, jour, heure, minute et seconde
	git commit -m "AutoSave $(date "+%Y-%m-%d %H:%M:%S")"
	echo "Le commit a ete fait"
	git push  # Pousser les changements vers le dépôt distant
	clear
	echo "Tout a ete mise a jour"
	echo " 5 minute avant la prochaine auto save............"
	sleep 60
	clear
	echo " 4 minute avant la prochaine auto save............"
	sleep 60	
	clear
	echo " 3 minute avant la prochaine auto save............"
	sleep 60	
	clear
	echo " 2 minute avant la prochaine auto save............"
	sleep 60
	clear
	echo " 1 minute avant la prochaine auto save............"
	sleep 60
done
