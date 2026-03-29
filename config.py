"""
Score_app configuration for standalone scores deployment.
"""

import os
from pathlib import Path

BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / 'data'
LOGS_DIR = BASE_DIR / 'logs'
STATIC_DIR = BASE_DIR / 'static'
TEMPLATES_DIR = BASE_DIR / 'templates'

DATA_DIR.mkdir(exist_ok=True)
LOGS_DIR.mkdir(exist_ok=True)

SECRET_KEY = os.getenv('SECRET_KEY', 'score-app-prod-secret-change-me')
DEBUG = str(os.getenv('DEBUG', 'false')).strip().lower() in {'1', 'true', 'yes'}
