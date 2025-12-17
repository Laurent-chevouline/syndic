#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var /data/lucterios/conf /data/lucterios/static /data/lucterios/media

# 2. Settings.py ROBUSTE (sans import * hasardeux)
cat <<EOF > /app/local_settings.py
import os

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SECRET_KEY = 'django-insecure-railway-deploy-key-change-me'
DEBUG = True
ALLOWED_HOSTS = ['*']

# Applications installées minimales pour Lucterios
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Modules Lucterios essentiels
    'lucterios.framework',
    'lucterios.framework.management', # Contient les commandes comme migrate
    
    # Votre module métier
    'diacamma.syndic', # ou 'diacamma.asso'
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

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

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
STATIC_ROOT = '/data/lucterios/static/'
MEDIA_URL = '/media/'
MEDIA_ROOT = '/data/lucterios/media/'

# Configuration spécifique Lucterios
LUCTERIOS_ROOT = '/data/lucterios'
EOF

echo "--- Migration DB ---"
export DJANGO_SETTINGS_MODULE=local_settings
python3 -c "import django; django.setup(); from django.core.management import call_command; call_command('migrate')" || echo "Erreur Migration (ignorable si DB déjà init)"

echo "--- Démarrage Gunicorn ---"
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=local_settings
