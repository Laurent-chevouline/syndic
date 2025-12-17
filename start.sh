#!/bin/bash

# 1. Création des dossiers
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf

# 2. On recrée un manage.py minimaliste pour lancer Lucterios
# C'est ce qui manque dans le package pip
cat <<EOF > /app/manage.py
#!/usr/bin/env python
import os
import sys

if __name__ == "__main__":
    # Configuration par défaut pour Lucterios
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "lucterios.framework.settings")
    
    # On force le chemin des fichiers de conf
    os.environ.setdefault("LUCTERIOS_ROOT", "/data/lucterios")

    from django.core.management import execute_from_command_line
    execute_from_command_line(sys.argv)
EOF

chmod +x /app/manage.py

echo "--- Initialisation ---"
# On tente d'initialiser via ce manage.py maison
# Si 'migrate' échoue, c'est que Lucterios utilise une commande custom 'lucterios_init'
# On essaie de l'importer si elle existe dans le module management
python3 /app/manage.py migrate --noinput || echo "Migration standard échouée, on continue..."

echo "--- Démarrage du serveur ---"
# On lance le serveur web via Gunicorn (plus robuste) ou runserver
# Gunicorn est installé via requirements.txt
# On pointe vers l'application WSGI de Lucterios
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --env LUCTERIOS_ROOT=/data/lucterios
