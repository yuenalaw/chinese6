import os
from celery import Celery

celery_app = Celery(
    broker=os.environ.get('CELERY_BROKER_URL'),
    backend=os.environ.get('CELERY_RESULT_BACKEND'),
)

celery_app.conf.update(
    task_track_started=True,
)

celery_app.autodiscover_tasks(['src.app.tasks.tasks'])