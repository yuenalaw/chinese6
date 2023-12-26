from .shared.model.models import db
import os

from flask import Flask, jsonify
from flask_cors import CORS
import logging.config

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

        # Register exception handlers
        init_exception_handler(app)

        # Add CORS
        CORS(app)
        db.init_app(app)
        db.create_all()

    return app