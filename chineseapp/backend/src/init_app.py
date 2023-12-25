import os

from flask import Flask
from flask_cors import CORS
import logging.config
from .blueprints.example.example_bp import example_bp
from .blueprints.db.dbbp import db_bp
from .blueprints.youtube.youtubebp import youtubebp
from .shared.model.models import db

from flask import jsonify
from . import celery_app as app_module


def init_celery(celery, app):
    celery.conf.update(app.config)
    TaskBase = celery.Task 
    class ContextTask(TaskBase):
        def __call__(self, *args, **kwargs):
            with app.app_context():
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

    # Logger config
    logging.config.dictConfig(app.config["DICT_LOGGER"])

    # celery
    if kwargs.get("celery"):
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
    with app.app_context():
            db.create_all()

    return app

if __name__ == "__main__":
    app = create_app(celery=app_module.celery)
    app.run()