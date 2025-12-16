# start.sh - Script de démarrage pour Railway

#!/bin/bash
set -e

echo "🚀 Starting Diacamma application..."

# Vérifier que le port est défini
PORT=${PORT:-8080}
echo "📍 Listening on port $PORT"

# Créer les répertoires nécessaires
mkdir -p /var/lucterios2/data

# Installer les dépendances Python (si setup.py existe)
if [ -f "setup.py" ]; then
    echo "📦 Installing Python dependencies..."
    pip install --no-cache-dir -e .
fi

# Si c'est une app Django/Diacamma, faire les migrations
if command -v python manage.py &> /dev/null 2>&1; then
    echo "🔄 Running database migrations..."
    python manage.py migrate --noinput || true
    
    echo "📁 Collecting static files..."
    python manage.py collectstatic --noinput || true
fi

# Démarrer Gunicorn
echo "✅ Starting Gunicorn server..."
exec gunicorn \
    --bind 0.0.0.0:$PORT \
    --workers 2 \
    --worker-class sync \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    diacamma.wsgi:application