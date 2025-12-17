#!/bin/bash

# Initialisation du dossier de données s'il est vide (premier lancement)
if [ ! -d "/data/lucterios/conf" ]; then
    echo "Initialisation des dossiers de configuration..."
    lucterios_init --root /data/lucterios
fi

# Configuration de la base de données (Hack pour forcer Postgres via env vars)
# On utilise un petit script python pour parser l'URL Railway et configurer Lucterios
python3 -c "
import os
import sys
from urllib.parse import urlparse
from lucterios.framework.database import DatabaseConfig

db_url = os.environ.get('DATABASE_URL')
if db_url:
    url = urlparse(db_url)
    # Note: Adapter selon l'API de config de Lucterios ou modifier le fichier .ini directement
    # Si l'API Python est complexe, on peut écrire directement le fichier de conf ici.
    print(f'Configuration DB détectée: Host={url.hostname}')
"

# Lancement du service web
# --port $PORT permet à Railway de mapper le trafic
# --interface 0.0.0.0 pour écouter à l'extérieur du conteneur
echo "Démarrage de Diacamma sur le port $PORT..."
exec lucterios_service --root /data/lucterios run --port $PORT --interface 0.0.0.0
