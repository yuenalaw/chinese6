from flask import Blueprint, request

from ...celery_app import celery

example_bp = Blueprint('example_bp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

@example_bp.route('/example/')
def example_delay_task():

    sig = celery.signature("example_task")
    running = sig.delay(10,10)

    print("Applied signature")

    return "SUBMITTED " + str(running)

