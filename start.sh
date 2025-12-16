#!/bin/bash
set -e

echo "🚀 Starting Diacamma application..."

# Set port
PORT=${PORT:-8080}
echo "📍 Port: $PORT"

# Create directories
mkdir -p /var/lucterios2/data

# Install dependencies if setup.py exists
if [ -f "setup.py" ]; then
    echo "📦 Installing Python dependencies..."
    pip install --no-cache-dir -e .
fi

# Start gunicorn
echo "✅ Starting Gunicorn server..."
exec gunicorn \
    --bind 0.0.0.0:${PORT} \
    --workers 2 \
    --worker-class sync \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    diacamma.wsgi:application