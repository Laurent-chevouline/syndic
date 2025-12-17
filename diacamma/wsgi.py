"""
WSGI config for Diacamma project using Lucterios framework.
"""
import os
import django

# Get settings module from environment or use default
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lucterios.settings')

# Setup Django
django.setup()

# Get the WSGI application
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()