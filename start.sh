#!/bin/bash
set -e
echo "🚀 Starting Diacamma..."
PORT=${PORT:-8080}
mkdir -p /var/lucterios2/data
if [ -f "setup.py" ]; then
    pip install --no-cache-dir -e .
fi
echo "✅ Starting Gunicorn..."
exec gunicorn --bind 0.0.0.0:${PORT} --workers 2 --worker-class sync --timeout 120 --access-logfile - --error-logfile - wsgi:application