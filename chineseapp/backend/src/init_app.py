import os

from flask import Flask, jsonify
from flask_cors import CORS
import logging.config
from .blueprints.example.example_bp import example_bp
from .blueprints.db.dbbp import db_bp
from .blueprints.youtube.youtubebp import youtubebp
from .shared.model.models import db

from . import celery_app as app_module

def init_celery(celery, app):
    celery.conf.update(app.config)
    TaskBase = celery.Task 
    class ContextTask(TaskBase):
        # defines custom task class (contextTask) that pushes a flask app context whenever task is called
        def __call__(self, *args, **kwargs): 
            with app.app_context():
                print(f"Current app: {app}")
                return TaskBase.__call__(self, *args, **kwargs)
    
    celery.Task = ContextTask


def init_exception_handler(app):
    app.register_error_handler(RuntimeError, handle_runtime_error)

def handle_runtime_error(error):
    response = jsonify({'message': "Internal server error"})
    response.status_code = 500
    return response

def create_app(app_name=__name__, **kwargs):
    
    app = Flask(app_name)
    app.config.from_object(os.environ.get('APP_SETTINGS'))

    with app.app_context():

        # Logger config
        logging.config.dictConfig(app.config["DICT_LOGGER"])

        # celery
        if kwargs.get("celery"):
            print(f"I'M INITIALISING CELERY!!")
            init_celery(kwargs.get("celery"),app)

        # Enable CORS on blueprints
        CORS(youtubebp)
        CORS(example_bp)
        CORS(db_bp)

        # Register blueprints
        app.register_blueprint(example_bp, url_prefix='/')
        app.register_blueprint(youtubebp, url_prefix='/')
        app.register_blueprint(db_bp, url_prefix='/')

        # Register exception handlers
        init_exception_handler(app)

        # Add CORS
        CORS(app)
        db.init_app(app)
        db.create_all()

    return app

from werkzeug.serving import WSGIRequestHandler

if __name__ == "__main__":
    app = create_app(celery=app_module.celery)

    #delete this
    WSGIRequestHandler.protocol_version = "HTTP/1.1"
    app.run()