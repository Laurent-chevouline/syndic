#!/bin/bash

# On s'assure que les dossiers existent (pour le volume persistant)
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf


echo "Démarrage du serveur Diacamma..."
# Utiliser simplement la commande diacamma qui est installée par pip
exec diacamma --port ${PORT:-8100} --host 0.0.0.0

