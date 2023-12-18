import eventlet
eventlet.monkey_patch()

from src.app import factory
import src.app as app
from flask_socketio import SocketIO
from flask_socketio import join_room
from flask import jsonify
from .database import db
from src.app.models import MySqlModel

app = factory.create_app(celery=app.celery)
# Database config
db.init_app(app)

with app.app_context():
    db.create_all()
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

socketio.run(app)

if __name__ == '__main__':
    socketio.run(app)