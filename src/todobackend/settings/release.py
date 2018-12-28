from todobackend.settings.base import *
import os

# Disable debug
if os.environ.get('DEBUG'):
    DEBUG = True
else:
    DEBUG = False

# Must specify allowed-hosts when debug is disabled
ALLOWED_HOSTS = [os.environ.get('ALLOWED_HOSTS', '*')]

# Use mySQL
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('MYSQL_DATABASE', 'todobackend'),
        'USER': os.environ.get('MYSQL_USER', 'todo'),
        'PASSWORD': os.environ.get('MYSQL_PASSWORD', 'password'),
        'HOST': os.environ.get('MYSQL_HOST', 'localhost'),
        'PORT': os.environ.get('MYSQL_PORT', '3306')
    }
}

# files served by web app
STATIC_ROOT = os.environ.get('STATIC_ROOT', '/var/www/todobackend/static')
# files or images uploaded to the web app
MEDIA_ROOT = os.environ.get('MEDIA_ROOT', '/var/www/todobackend/media')
