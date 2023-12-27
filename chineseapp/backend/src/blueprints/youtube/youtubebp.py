from flask import Blueprint, request
from ...shared.helper.ModelService import ModelService
from ...celery_app import celery

youtubebp = Blueprint('youtubebp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

model_service = ModelService()

@youtubebp.route('/vid/<id>', methods=['GET'])
def process_video(id):
    try:
        # enqueue celery task
        print(f"trying to enqueue with video... {id}")

        sig = celery.signature("execute_transcript_tasks")
        task = sig.delay(id)
        task_id = task.id
        
        print(f"Task ID:{task_id}") # send this to the client for them to check below method
        return {'message': 'Video task has been added to the queue', 'task_id': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to enqueue video task'}, 500

@youtubebp.route('/posttranscript', methods=['POST'])
def add_full_transcript():
    request_data = request.get_json()
    try:
        sig = celery.signature("execute_transcript_tasks_non_youtube")
        task = sig.delay(request_data['id'], request_data['transcript'])
        task_id = task.id 
        print(f"Task ID:{task_id}") # send this to the client for them to check below method
        return {'message': 'Full transcript task has been added to the queue', 'task_id': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to enqueue transcript task'}, 500

@youtubebp.route('/updatesentence', methods=['POST'])
def update_user_sentence():
    request_data = request.get_json()
    try:
        sig = celery.signature("execute_new_sentence")
        task = sig.delay(request_data['video_id'], request_data['line_changed'], request_data['sentence'])
        task_id = task.id
        print(f"Task ID:{task_id}") # send this to the client for them to check below method
        return {'message': 'Sentence task has been added to the queue', 'task_id': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update user sentence'}, 500
