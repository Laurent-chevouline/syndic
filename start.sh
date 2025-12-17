#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf
mkdir -p /data/lucterios/media
mkdir -p /data/lucterios/static

# 2. Création FORCÉE de la configuration minimale
# C'est ce fichier qui dit à Lucterios "Charge le module Diacamma Asso/Syndic"
if [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "Génération manuelle de lucterios.xml..."
    cat <<EOF > /data/lucterios/conf/lucterios.xml
<?xml version="1.0" encoding="UTF-8"?>
<lucterios>
    <database>
        <!-- Utilisation de SQLite par défaut pour le premier boot -->
        <!-- Vous pourrez changer ça pour Postgres via l'interface plus tard -->
        <engine>django.db.backends.sqlite3</engine>
        <name>/data/lucterios/var/db.sqlite3</name>
    </database>
    <general>
        <language>fr</language>
        <timezone>Pacific/Tahiti</timezone>
    </general>
    <modules>
        <!-- On active le module de base -->
        <!-- Si vous utilisez diacamma-asso, mettez 'diacamma.asso' -->
        <!-- Si vous utilisez diacamma-syndic, mettez 'diacamma.syndic' -->
        <module>lucterios.framework</module>
        <module>diacamma.syndic</module> 
    </modules>
</lucterios>
EOF
fi

# 3. Injection des variables d'environnement
export LUCTERIOS_ROOT=/data/lucterios
export DJANGO_SETTINGS_MODULE=lucterios.framework.settings
export PYTHONUNBUFFERED=1

# 4. Migration DB (Essentiel pour créer les tables auth/django)
echo "--- Tentative de migration DB ---"
# On utilise python -m car les binaires sont introuvables
python3 -m lucterios.framework.manage migrate --noinput || echo "Migration échouée, on continue..."

# 5. Démarrage
echo "--- Démarrage Gunicorn ---"
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=lucterios.framework.settings \
    --env LUCTERIOS_ROOT=/data/lucterios
