import eventlet
eventlet.monkey_patch()

import os
import logging.config

from flask import Flask, jsonify
from flask_cors import CORS
from flask_socketio import SocketIO
from flask_socketio import join_room
from .database import db

from celery import Celery, Task

from src.app.blueprint.youtubebp import youtubebp
from src.app.blueprint.example_bp import example_bp
from src.app.blueprint.dbbp import db_bp
from src.app.exception_handler import init_exception_handler
from src.app.models import MySqlModel

app = Flask(__name__)
app.config.from_object(os.environ['APP_SETTINGS'])

# Logger config
logging.config.dictConfig(app.config["DICT_LOGGER"])

# Database config
db.init_app(app)
with app.app_context():
    db.create_all()

# celery
app.config.from_mapping(
    CELERY=dict(
        broker_url=os.environ.get('CELERY_BROKER_URL'),
        result_backend=os.environ.get('CELERY_RESULT_BACKEND'),
        task_ignore_result = False
    )
)

def celery_init_app(app: Flask) -> Celery:
    class FlaskTask(Task):
        def __call__(self, *args:object, **kwargs:object) -> object:
            with app.app_context():
                return self.run(*args, **kwargs)
        
    celery_app = Celery(app.name, task_cls=FlaskTask)
    celery_app.config_from_object('src.app.config.DevelopmentConfig')
    celery_app.set_default()
    app.extensions["celery"] = celery_app
    return celery_app

celery_app = celery_init_app(app)

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

# Init websockets
socketio = SocketIO(app, cors_allowed_origins="*",\
                    message_queue=app.config['REDIS_BROKER_URL'])


@app.errorhandler(404)
def page_not_found(e):
    response = jsonify({'message': "Not found"})
    response.status_code = 404
    return response

@app.route('/hello/<name>')
def hello_name(name):
    return "Hello {}!".format(name)

@socketio.on('connect')
def test_connect():
    # Client connected via socketio
    pass

@socketio.on('join')
def on_join(room_name):
    # Client joined room via socketio
    join_room(room_name)

if __name__ == '__main__':
    socketio.run(app)
