#!/bin/bash

# Préparation
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf

echo "--- Debuggage des chemins ---"
# On demande à python où est installé lucterios
LOCATION=$(python3 -c "import lucterios; import os; print(os.path.dirname(lucterios.__file__))")
echo "Lucterios est installé dans : $LOCATION"

# On construit le chemin vers le script de service
# La structure classique est lucterios/framework/service.py
SERVICE_SCRIPT="$LOCATION/framework/service.py"
INIT_SCRIPT="$LOCATION/framework/manage.py"

echo "Script de service cible : $SERVICE_SCRIPT"

if [ ! -f "$SERVICE_SCRIPT" ]; then
    echo "ERREUR CRITIQUE: Impossible de trouver le script service.py dans $LOCATION"
    # Plan C : chercher n'importe quel fichier service.py dans le dossier lucterios
    SERVICE_SCRIPT=$(find $LOCATION -name "service.py" | head -n 1)
    echo "Recherche alternative trouvée : $SERVICE_SCRIPT"
fi

# Initialisation
if [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "Initialisation de la configuration..."
    # On appelle le script python directement
    python3 "$INIT_SCRIPT" init --root /data/lucterios
fi

echo "Démarrage du serveur..."
# Lancement direct du fichier python
exec python3 "$SERVICE_SCRIPT" --root /data/lucterios run --port ${PORT:-8100} --interface 0.0.0.0
