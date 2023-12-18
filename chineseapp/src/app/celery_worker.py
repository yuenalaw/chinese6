from src.app.celery_app import celery
from src.app.factory import create_app
from src.app.celery_utils import init_celery

app = create_app()
init_celery(celery, app)