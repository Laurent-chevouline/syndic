#!/bin/bash

echo "--- DIAGNOSTIC STRUCTURE ---"
# On cherche où python installe ses paquets
SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])")
echo "Dossier site-packages : $SITE_PACKAGES"

echo "Listing du contenu de lucterios :"
# On liste tout ce qui ressemble à lucterios pour trouver le vrai nom du dossier
find $SITE_PACKAGES -maxdepth 2 -name "*lucterios*" 

echo "--- Listing récursif rapide ---"
# On regarde la structure pour trouver le fichier service.py
find $SITE_PACKAGES -name "service.py"
find $SITE_PACKAGES -name "manage.py"

echo "--- TENTATIVE DE LANCEMENT ---"
# Si on trouve un fichier service.py, on essaie de le lancer
SERVICE_FILE=$(find $SITE_PACKAGES -name "service.py" | grep lucterios | head -n 1)

if [ -n "$SERVICE_FILE" ]; then
    echo "Fichier service trouvé : $SERVICE_FILE"
    export PYTHONPATH=$PYTHONPATH:$(dirname $(dirname $SERVICE_FILE))
    echo "PYTHONPATH mis à jour : $PYTHONPATH"
    
    mkdir -p /data/lucterios/var /data/lucterios/conf
    
    # On tente l'exécution directe
    exec python3 "$SERVICE_FILE" --root /data/lucterios run --port ${PORT:-8100} --interface 0.0.0.0
else
    echo "ERREUR: Aucun fichier service.py trouvé. Contenu du dossier :"
    ls -R $SITE_PACKAGES/lucterios* 2>/dev/null
    sleep 30 # Pour vous laisser le temps de lire les logs avant le crash
fi