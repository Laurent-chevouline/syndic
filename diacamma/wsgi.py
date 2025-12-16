import os, sys, django
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'lucterios.settings')
django.setup()
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()