#!/bin/bash

# On s'assure que les dossiers existent (pour le volume persistant)
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf

# Si c'est le premier lancement, on initialise
# Note: lucterios_init peut demander de l'interactif, il faut parfois le forcer ou le skipper si la conf existe déjà
if [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "Initialisation de la configuration..."
    # Cette commande crée les fichiers de base
    lucterios_init --root /data/lucterios
fi

echo "Démarrage du serveur Lucterios..."
# Lancement du serveur web sur le port 8100 (ou $PORT)
# Important: 0.0.0.0 est vital pour Docker/Railway
exec lucterios_service --root /data/lucterios run --port ${PORT:-8100} --interface 0.0.0.0

