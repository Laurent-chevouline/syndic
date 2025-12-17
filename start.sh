#!/bin/bash
set -e

echo "🚀 Starting Diacamma..."

PORT=${PORT:-8080}

mkdir -p /var/lucterios2/data

# Installer les dépendances
if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    pip install --no-cache-dir -e .
fi

# ALLER DANS LE BON RÉPERTOIRE D'ABORD
cd /app

# Vérifier que wsgi.py existe
if [ ! -f "wsgi.py" ]; then
    echo "ERROR: wsgi.py not found in /app"
    ls -la /app
    exit 1
fi

exec gunicorn wsgi:application --bind 0.0.0.0:${PORT} --workers 2 --timeout 60 --access-logfile - --error-logfile -