#!/bin/bash

# 1. Dossiers & Variables d'environnement
mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf
export LUCTERIOS_ROOT=/data/lucterios
export DJANGO_SETTINGS_MODULE=lucterios.framework.settings
export PYTHONUNBUFFERED=1

# 2. Localiser et exécuter l'initialisation
# Le paquet Diacamma/Lucterios installe plusieurs binaires.
# On va trouver le bon et l'exécuter.
INIT_COMMAND=$(find /usr/local/bin -name "lucterios_init" -o -name "diacamma_init" | head -n 1)

if [ -n "$INIT_COMMAND" ] && [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "--- Initialisation via $INIT_COMMAND ---"
    # Lance la commande d'init, qui va créer lucterios.xml et potentiellement la DB
    "$INIT_COMMAND" --root /data/lucterios
fi

# 3. Lancement du serveur Gunicorn
echo "--- Démarrage Gunicorn ---"
# Lancement avec TOUTES les variables d'env explicitement passées
exec gunicorn lucterios.framework.wsgi:application \
    --bind 0.0.0.0:${PORT:-8100} \
    --workers 2 \
    --timeout 120 \
    --env DJANGO_SETTINGS_MODULE=lucterios.framework.settings \
    --env LUCTERIOS_ROOT=/data/lucterios
