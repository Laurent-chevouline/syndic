#!/bin/bash
set -e
echo "🚀 Starting Diacamma..."
PORT=${PORT:-8080}
mkdir -p /var/lucterios2/data
if [ -f "setup.py" ]; then
    pip install --no-cache-dir -e .
fi
cd /app
exec python -m waitress --listen=0.0.0.0:${PORT} diacamma.wsgi:application
