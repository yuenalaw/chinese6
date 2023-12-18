
import os
import logging.config

from flask import Flask
from flask_cors import CORS

from src.app.blueprint.youtubebp import youtubebp
from src.app.blueprint.example_bp import example_bp
from src.app.blueprint.dbbp import db_bp
from src.app.exception_handler import init_exception_handler

from src.app.celery_utils import init_celery

def create_app(app_name=__name__, **kwargs):
    
    app = Flask(app_name)
    app.config.from_object(os.environ['APP_SETTINGS'])

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

    return app