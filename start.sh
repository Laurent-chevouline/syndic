#!/bin/bash

mkdir -p /data/lucterios/var
mkdir -p /data/lucterios/conf

echo "--- Démarrage via Entry Points Python ---"

# 1. Initialisation
if [ ! -f "/data/lucterios/conf/lucterios.xml" ]; then
    echo "Initialisation de la configuration..."
    python3 -c "
import sys
from lucterios.framework.manage import manage_main
sys.argv = ['manage.py', 'init', '--root', '/data/lucterios']
manage_main()
"
fi

echo "Lancement du service..."

# 2. Lancement du serveur
# On simule l'appel à la ligne de commande via python
exec python3 -c "
import sys
from lucterios.framework.service import service_main
# On configure les arguments comme si on était en ligne de commande
sys.argv = ['service.py', 'run', '--root', '/data/lucterios', '--port', '${PORT:-8100}', '--interface', '0.0.0.0']
service_main()
"