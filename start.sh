#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var /data/lucterios/conf /data/lucterios/static /data/lucterios/media

# 2. Settings.py Complet et Patché
cat <<EOF > /app/local_settings.py
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SECRET_KEY = 'django-insecure-railway-patch'
DEBUG = True
ALLOWED_HOSTS = ['*']

# --- Variables spécifiques Lucterios (CRITIQUE) ---
APPLIS_MODULE = 'diacamma' # Nom interne utilisé par le framework
LUCTERIOS_ROOT = '/data/lucterios'
# --------------------------------------------------

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    'lucterios.framework',
    'lucterios.framework.management',
    # On ajoute le module lucterios lui-même qui semble contenir la logique métier
    'lucterios', 
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

TEMPLATES = [{'BACKEND': 'django.template.backends.django.DjangoTemplates', 'APP_DIRS': True}]
EOF

echo "--- Migration DB ---"
export DJANGO_SETTINGS_MODULE=local_settings
# On ignore les erreurs de migration pour l'instant pour forcer le boot
python3 -c "import django; django.setup(); from django.core.management import call_command; call_command('migrate')" || true

echo "--- Démarrage Gunicorn ---"
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=local_settings
