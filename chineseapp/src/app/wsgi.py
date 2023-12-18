# from src.app import factory
# import src.app as app_module

# if __name__ == "__main__":
#     app = factory.create_app(celery=app_module.celery)
#     app.run()

from src.app import factory
import src.app.celery_app as app_module

if __name__ == "__main__":
    app = factory.create_app(celery=app_module.celery)
    app.run()