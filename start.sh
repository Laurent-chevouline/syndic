#!/bin/bash

# 1. Préparation des dossiers
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf
mkdir -p /data/lucterios/media
mkdir -p /data/lucterios/static

# 2. Génération de lucterios.xml (Si absent)
CONF_FILE="/data/lucterios/conf/lucterios.xml"
if [ ! -f "$CONF_FILE" ]; then
    echo "Création du fichier de configuration par défaut..."
    cat <<EOF > $CONF_FILE
<?xml version="1.0" encoding="UTF-8"?>
<lucterios>
    <database>
        <engine>django.db.backends.sqlite3</engine>
        <name>/data/lucterios/var/db.sqlite3</name>
    </database>
    <general>
        <language>fr</language>
        <timezone>Europe/Paris</timezone>
        <url_root>/</url_root>
    </general>
    <modules>
        <module>lucterios.framework</module>
        <module>diacamma.syndic</module>
    </modules>
</lucterios>
EOF
fi

# 3. Patch critique pour l'erreur ROOT_URLCONF
# On crée un petit script Python qui va initialiser Django correctement avant de lancer Gunicorn
# Ce script force le chargement de la conf Lucterios
cat <<EOF > /app/wsgi_launcher.py
import os
import sys
from django.core.wsgi import get_wsgi_application

# Configuration de l'environnement
os.environ.setdefault("LUCTERIOS_ROOT", "/data/lucterios")
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "lucterios.framework.settings")

# On force l'import du gestionnaire de config Lucterios
try:
    from lucterios.framework.database import DatabaseConfig
    # On force le rechargement de la config depuis le XML
    db_conf = DatabaseConfig('/data/lucterios')
    if not os.path.exists(db_conf.config_filename):
        print("Attention: Fichier de conf introuvable à", db_conf.config_filename)
except ImportError:
    print("Impossible d'importer DatabaseConfig")

application = get_wsgi_application()
EOF

echo "--- Démarrage Gunicorn via Launcher Custom ---"
# On lance Gunicorn sur notre launcher custom plutôt que sur le module framework direct
# Cela garantit que nos hacks d'initialisation sont exécutés
exec gunicorn wsgi_launcher:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120
