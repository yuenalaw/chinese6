from celery import Celery
def make_celery(app_name=__name__):
    redis_broker = "redis://redis:6379" # read from flask config in the future :)
    celery_app = Celery(app_name, 
                        broker=redis_broker,
                        backend=redis_broker,
                        )
    celery_app.autodiscover_tasks(["src.tasks.example","src.tasks.youtube"])
    return celery_app 

celery = make_celery("chineseapp")
