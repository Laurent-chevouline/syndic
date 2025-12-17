FROM python:3.11-slim

WORKDIR /app

# Copier les fichiers du projet
COPY . .

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Définir les variables d'environnement Django
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Commande de démarrage
CMD ["python", "-m", "lucterios.runserver", "0.0.0.0:$PORT"]