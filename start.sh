#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var /data/lucterios/conf /data/lucterios/static /data/lucterios/media

# 2. Création d'un module settings local qui surcharge tout
cat <<EOF > /app/local_settings.py
import os
from lucterios.framework.settings import *

# On force la configuration qui manque
ROOT_URLCONF = 'lucterios.framework.urls'
WSGI_APPLICATION = 'lucterios.framework.wsgi.application'

# Configuration DB forcée (SQLite pour commencer)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/data/lucterios/var/db.sqlite3',
    }
}

# Configuration Lucterios forcée
LUCTERIOS_ROOT = '/data/lucterios'
INSTALLED_APPS += ['diacamma.syndic'] # ou diacamma.asso
ALLOWED_HOSTS = ['*']
DEBUG = True # Pour voir les erreurs détaillées à l'écran
EOF

echo "--- Démarrage avec Settings Forcés ---"

# 3. Migration (si possible)
export DJANGO_SETTINGS_MODULE=local_settings
python3 -c "import django; django.setup(); from django.core.management import call_command; call_command('migrate')" || echo "Migrate failed"

# 4. Lancement Gunicorn
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=local_settings
