FROM nonobis/diacamma:latest

# Définir les variables d'environnement
ENV DIACAMMA_TYPE=syndic
ENV DIACAMMA_ORGANISATION=aplh
ENV DIACAMMA_DATABASE=postgresql
ENV PORT=8100

RUN pip install psycopg2-binary

# Créer les dossiers de données
RUN mkdir -p /var/lucterios2/aplh/var && \
    mkdir -p /var/lucterios2/aplh/backups && \
    mkdir -p /var/lucterios2/aplh/data && \
    chmod -R 777 /var/lucterios2/aplh

# Exposer le port
EXPOSE 8100

# Laisser la commande de démarrage par défaut de l'image
CMD ["gunicorn", "lucterios.framework.wsgi:application", "--bind", "0.0.0.0:8100", "--workers", "2"]