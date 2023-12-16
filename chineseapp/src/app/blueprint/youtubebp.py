from flask import Blueprint, request
from src.app.tasks.tasks import execute_transcript_tasks
from celery.result import AsyncResult
from src.app.helpers.ModelHelper import ModelService

youtubebp = Blueprint('youtubebp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

model_service = ModelService()

@youtubebp.route('/vid') #/vid?v=<id>
def process_video():
    id=request.args.get('v')
    try:
        # enqueue celery task
        print(f"trying to enqueue with video... {id}")

        # check if video already exists in the db
        if (model_service.video_exists(id)):
            return {'message': 'Video exists in our db!', 'task_id': task_id}, 200

        result = execute_transcript_tasks(id)
        task_id = result.id
        print(f"Task ID:{task_id}") # send this to the client for them to check below method
        return {'message': 'Task has been added to the queue', 'task_id': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to enqueue task'}, 500

@youtubebp.route('/status/<task_id>')
def task_status(task_id):
    result = AsyncResult(task_id)
    return {'status': result.status, 'result': result.result}, 200