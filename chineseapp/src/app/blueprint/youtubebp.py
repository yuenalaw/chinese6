from flask import Blueprint, request
from src.app.tasks.tasks import execute_transcript_tasks, execute_new_sentence
from celery.result import AsyncResult
from src.app.helpers.ModelService import ModelService
from flask import jsonify

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

        # check if video already exists in the db
        if (model_service.video_exists(id)):
            return {'message': 'Video exists in our db!', 'task_id': task_id}, 200

        task = execute_transcript_tasks.apply_async((id,))
        task_id = task.id
        
        print(f"Task ID:{task_id}") # send this to the client for them to check below method
        return {'message': 'Task has been added to the queue', 'task_id': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to enqueue task'}, 500

@youtubebp.route('/updatesentence', methods=['POST'])
def update_user_sentence():
    request_data = request.get_json()
    try:
        task = execute_new_sentence.apply_async([request_data['youtube_id'], request_data['line_changed'], request_data['sentence']])
        task_id = task.id
        print(f"Task ID:{task_id}") # send this to the client for them to check below method
        return {'message': 'Sentence task has been added to the queue', 'task_id': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update user sentence'}, 500

@youtubebp.route('/task/<task_id>', methods=['GET']) # client polls this
def taskstatus(task_id):
    print(f"checking task status of {task_id}")
    task = AsyncResult(task_id)
    if task.state == 'PENDING':
        response = {
            'state': task.state,
            'status': 'Pending...'
        }
    elif task.state != 'FAILURE':
        # task is done
        result = task.result
        if result is not None and isinstance(result, tuple) and len(result) == 2:
            video_subtitles_details, video_keywords_img, id = result
            print(f"oo, not failed. i have {video_subtitles_details} and {video_keywords_img}")
            if model_service.video_exists(id):
                print(f"Successfully added video!")
                response = {
                    'state': True,
                    'vid_subtitles': video_subtitles_details,
                    'video_keywords': video_keywords_img
                } 
            else:
                print("Error:", str(e))
                return {'message': 'Video not yet in db'}, 500
    else: # failed
        response = {
            'state': task.state,
            'result': str(task.info),
        }

    return jsonify(response)
