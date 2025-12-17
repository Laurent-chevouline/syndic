#!/bin/bash

# On s'assure que les dossiers existent (pour le volume persistant)
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf

export PATH=$PATH:/usr/local/bin:/root/.local/bin

# Si c'est le premier lancement, on initialise
# Note: lucterios_init peut demander de l'interactif, il faut parfois le forcer ou le skipper si la conf existe déjà
if [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "Initialisation de la configuration..."
    # Remplacer lucterios_init par :
    python3 -m lucterios.framework.manage init --root /data/lucterios
fi

echo "Démarrage du serveur Lucterios..."
# Remplacer lucterios_service par :
exec python3 -m lucterios.framework.service --root /data/lucterios run --port ${PORT:-8100} --interface 0.0.0.0

