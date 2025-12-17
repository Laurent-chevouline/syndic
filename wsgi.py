"""
Diacamma WSGI application for Railway deployment
"""
import os
import sys
import django

sys.path.insert(0, '/app')

from django.conf import settings
from lucterios.install import get_settings_django

if not settings.configured:
    settings.configure(**get_settings_django())

django.setup()

from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()