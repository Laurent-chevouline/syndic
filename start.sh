#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var /data/lucterios/conf /data/lucterios/static /data/lucterios/media

# 2. Trouver le vrai nom du module Diacamma
echo "--- Recherche du module Diacamma ---"
# On liste les dossiers dans site-packages qui contiennent 'diacamma' ou 'syndic'
SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])")
REAL_MODULE_NAME=$(find $SITE_PACKAGES -maxdepth 1 -type d -name "*syndic*" -o -name "*asso*" -o -name "*diacamma*" | xargs -n 1 basename | grep -v "dist-info" | grep -v "egg-info" | head -n 1)

if [ -z "$REAL_MODULE_NAME" ]; then
    echo "ATTENTION: Aucun module Diacamma trouvé ! On tente 'diacamma.syndic' par défaut."
    REAL_MODULE_NAME="diacamma.syndic"
else
    echo "Module trouvé : $REAL_MODULE_NAME"
fi

# 3. Settings.py dynamique
cat <<EOF > /app/local_settings.py
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SECRET_KEY = 'django-insecure-railway'
DEBUG = True
ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'lucterios.framework',
    'lucterios.framework.management',
    '$REAL_MODULE_NAME',  # On injecte le nom trouvé dynamiquement
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'lucterios.framework.urls'
WSGI_APPLICATION = 'lucterios.framework.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/data/lucterios/var/db.sqlite3',
    }
}

LANGUAGE_CODE = 'fr-fr'
TIME_ZONE = 'Pacific/Tahiti'
USE_I18N = True
USE_TZ = True
STATIC_URL = '/static/'
LUCTERIOS_ROOT = '/data/lucterios'

# Patch pour les templates
TEMPLATES = [{'BACKEND': 'django.template.backends.django.DjangoTemplates', 'APP_DIRS': True}]
EOF

echo "--- Migration DB avec module $REAL_MODULE_NAME ---"
export DJANGO_SETTINGS_MODULE=local_settings
python3 -c "import django; django.setup(); from django.core.management import call_command; call_command('migrate')" || echo "Erreur Migration"

echo "--- Démarrage Gunicorn ---"
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=local_settings
