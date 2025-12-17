# Dockerfile pour Diacamma sur Railway
# Railway utilisera ce Dockerfile au lieu de Railpack

FROM python:3.11-slim

WORKDIR /app

# Installer les dépendances système nécessaires pour Diacamma
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2 \
    libxslt1.1 \
    libjpeg62-turbo \
    libpng16-16 \
    libtiff6 \
    giflib-tools \
    tcl \
    tk \
    curl \
    postgresql-client \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copier les fichiers du projet
COPY setup.py setup.cfg MANIFEST.in README.rst wsgi.py ./
COPY diacamma/ ./diacamma/

# Installer Diacamma et ses dépendances
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -e .

# Installer Gunicorn pour servir l'app
RUN pip install --no-cache-dir gunicorn==21.2.0

# Créer les répertoires nécessaires
RUN mkdir -p /var/lucterios2/data && chmod 755 /var/lucterios2/data

# Copier le script de démarrage
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Port (DOIT être 8080 pour Railway)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080 || exit 1

# Variables d'environnement
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV LUCTERIOS_INSTALL=/var/lucterios2/data

# Démarrer l'application
CMD ["/app/start.sh"]