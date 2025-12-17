#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var /data/lucterios/conf /data/lucterios/static /data/lucterios/media

# 2. Enquête sur le nom du module
echo "--- INSPECTION DU CONTENU PYTHON ---"
SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])")

# On cherche où se cache le module métier
# Hypothèse 1 : lucterios.diacamma...
if [ -d "$SITE_PACKAGES/lucterios/diacamma" ]; then
    REAL_MODULE_NAME="lucterios.diacamma.syndic" # ou asso
    echo "Trouvé dans lucterios/diacamma !"
# Hypothèse 2 : dossier racine 'syndic' ou 'asso'
elif [ -d "$SITE_PACKAGES/syndic" ]; then
    REAL_MODULE_NAME="syndic"
    echo "Trouvé module racine 'syndic'"
# Hypothèse 3 : On liste tout ce qui est gros
else
    echo "Module introuvable au jugé. Listing des dossiers candidats :"
    find $SITE_PACKAGES -maxdepth 1 -type d | grep -v "__pycache__" | grep -v "dist-info"
    # Fallback générique qui a le plus de chance de marcher avec Lucterios standard
    REAL_MODULE_NAME="lucterios" 
fi

# 3. Settings.py
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
    # On commente le module métier pour l'instant si on ne le trouve pas
    # Cela permettra au moins à l'interface de base de démarrer
    # '$REAL_MODULE_NAME', 
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
TEMPLATES = [{'BACKEND': 'django.template.backends.django.DjangoTemplates', 'APP_DIRS': True}]
EOF

echo "--- Migration DB (Module de base uniquement) ---"
export DJANGO_SETTINGS_MODULE=local_settings
python3 -c "import django; django.setup(); from django.core.management import call_command; call_command('migrate')" || echo "Erreur Migration"

echo "--- Démarrage Gunicorn ---"
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=local_settings
