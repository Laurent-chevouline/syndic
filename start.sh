#!/bin/bash

# 1. Préparation des dossiers persistants
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf

# 2. Localisation dynamique des exécutables (Car on ne sait pas où pip les a mis)
# On cherche le fichier 'lucterios_init' dans tout le système
INIT_CMD=$(find /usr /home -name "lucterios_init" -type f -executable | head -n 1)
SERVICE_CMD=$(find /usr /home -name "lucterios_service" -type f -executable | head -n 1)

# Fallback : Si non trouvés, on tente via python -m si le package est 'lucterios' tout court
if [ -z "$INIT_CMD" ]; then
    echo "Exécutables non trouvés via find, essai via module python..."
    # Note: On essaie 'lucterios' tout court car 'lucterios.framework' semble incorrect
    INIT_CMD="python3 -m lucterios init"
    SERVICE_CMD="python3 -m lucterios run"
fi

echo "Commande d'init trouvée : $INIT_CMD"
echo "Commande de service trouvée : $SERVICE_CMD"

# 3. Initialisation (si conf absente)
if [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "Initialisation de la configuration..."
    $INIT_CMD --root /data/lucterios
fi

# 4. Lancement du serveur
echo "Démarrage du serveur Lucterios sur le port ${PORT:-8100}..."
# On utilise 'exec' pour que le processus prenne le PID 1
exec $SERVICE_CMD --root /data/lucterios run --port ${PORT:-8100} --interface 0.0.0.0
