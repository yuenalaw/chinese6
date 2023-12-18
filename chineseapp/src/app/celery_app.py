from celery import Celery
import os
def make_celery(app_name=__name__):
    redis_uri = "redis://redis:6379"
    celery_app = Celery(app_name, 
                        broker=redis_uri,
                        backend=redis_uri,
                        )
    celery_app.autodiscover_tasks(['src.app.tasks.tasks'])
    return celery_app 
celery = make_celery()
