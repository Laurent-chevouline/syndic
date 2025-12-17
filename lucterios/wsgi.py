"""
Lucterios WSGI application for Railway deployment
"""
import os
import sys
sys.path.insert(0, '/app')

# Configure Django
from django.conf import settings
from lucterios.install import get_settings_django

if not settings.configured:
    settings.configure(**get_settings_django())

import django
django.setup()

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()