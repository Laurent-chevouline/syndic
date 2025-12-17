#!/bin/bash

# 1. Dossiers
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf
mkdir -p /data/lucterios/media
mkdir -p /data/lucterios/static

# 2. Variables d'environnement CRITIQUES pour Lucterios
export LUCTERIOS_ROOT=/data/lucterios
export DJANGO_SETTINGS_MODULE=lucterios.framework.settings
export PYTHONUNBUFFERED=1

# 3. Création d'un fichier de configuration DB minimal si absent
# Lucterios a besoin de savoir où taper. Par défaut il utilise souvent SQLite dans var/
# On force un fichier de config lucterios.ini si besoin, mais normalement l'env suffit.

echo "--- Initialisation ---"
# On tente l'init via le module lucterios.framework.manage directement via python -m
# C'est souvent plus fiable que via un manage.py recréé
python3 -m lucterios.framework.manage migrate --noinput || echo "Migrate via module échoué (normal si first run)"

echo "--- Démarrage Gunicorn ---"
# Lancement avec TOUTES les variables d'env explicitement passées
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=lucterios.framework.settings \
    --env LUCTERIOS_ROOT=/data/lucterios
