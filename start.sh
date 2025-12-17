#!/bin/bash
set -e
echo "🚀 Starting Diacamma..."
PORT=${PORT:-8080}
mkdir -p /var/lucterios2/data

# Install project
if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
    pip install --no-cache-dir -e .
fi

cd /app

# Start with gunicorn
exec gunicorn lucterios.wsgi:application \
    --bind 0.0.0.0:${PORT} \
    --workers 2 \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -