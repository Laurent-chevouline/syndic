FROM python:3.11-slim

# Installation des dépendances système (nécessaires pour Lucterios/GTK/Cairo)
RUN apt-get update && apt-get install -y \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf-2.0-0 \
    libffi-dev \
    shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Installation des dépendances Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Vérifier où sont les binaires (pour le debug, optionnel)
RUN find / -name lucterios_service

# Création des dossiers pour la persistance
RUN mkdir -p /data/lucterios
ENV LUCTERIOS_ROOT=/data/lucterios

# Copie du script de démarrage
COPY start.sh .
RUN chmod +x start.sh

# Port exposé par défaut (Railway injectera la variable PORT)
EXPOSE 8100

CMD ["./start.sh"]