#!/bin/bash
set -e
echo "🚀 Starting Diacamma..."
PORT=${PORT:-8080}
mkdir -p /var/lucterios2/data
if [ -f "setup.py" ]; then
    pip install --no-cache-dir -e .
fi
cd /app
# Set Django settings module - Lucterios uses lucterios.settings
export DJANGO_SETTINGS_MODULE=lucterios.settings
# Use waitress with correct syntax
exec python -m waitress --listen=0.0.0.0:${PORT} diacamma.wsgi:application