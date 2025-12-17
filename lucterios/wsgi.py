"""
Lucterios WSGI application
"""
import os
import django
from django.conf import settings

# Configure Django with Lucterios defaults
if not settings.configured:
    from lucterios.install import get_settings_django
    settings.configure(**get_settings_django())

django.setup()
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()