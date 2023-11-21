from flask import Blueprint, request

from src.app.tasks.tasks import example_task

example_bp = Blueprint('example_bp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

# @youtubebp.route('/example/', methods=['POST'])
@example_bp.route('/example/')
def example_delay_task():

    request_data = request.form

    task = example_task.delay('hi')

    return "celery task initiated!"

