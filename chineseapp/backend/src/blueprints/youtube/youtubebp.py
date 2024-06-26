from flask import Blueprint, request
from ...shared.helper.ModelService import ModelService
from youtube_transcript_api import YouTubeTranscriptApi
from ...celery_app import celery

youtubebp = Blueprint('youtubebp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

model_service = ModelService()

@youtubebp.route('/vid', methods=['POST'])
def process_video():
    request_data = request.get_json()
    try:
        # enqueue celery task
        print(f"trying to enqueue with video... {request_data['video_id']}")
        transcript_orig = YouTubeTranscriptApi.get_transcript(request_data['video_id'], languages=['zh-Hans', 'zh-Hant', 'zh-CN', 'zh-SG', 'zh-HK', 'zh-TW'])
        sig = celery.signature("execute_transcript_tasks")
        task = sig.delay(request_data['video_id'], transcript_orig, request_data['source'], request_data['forced'], request_data['title'], request_data['channel'], request_data['thumbnail'])
        callbackid = task.id        
        print(f"callback is {callbackid}") # send this to the client for them to check below method
        return {'message': 'Video task has been added to the queue', 'callback': callbackid}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': f'Failed to enqueue video task: {e}'}, 500

@youtubebp.route('/posttranscriptdisney', methods=['POST'])
def add_full_transcript():
    request_data = request.get_json()
    try:
        sig = celery.signature("execute_transcript_tasks_non_youtube")
        task = sig.delay(request_data['id'], request_data['transcript'], request_data['source'], request_data['forced'], request_data['title'], request_data['channel'])
        callbackid = task.id        
        print(f"Callback is {callbackid}") # send this to the client for them to check below method
        return {'message': 'Full transcript task has been added to the queue', 'callback': callbackid}, 202
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
        return {'message': 'Sentence task has been added to the queue', 'callback': task_id}, 202
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update user sentence'}, 500

@youtubebp.route('/updatesentencetask/<task_id>', methods=['GET'])
def check_sentence_task(task_id):
    try:
        task = celery.AsyncResult(task_id)
        if task.state == 'SUCCESS':
            return {'message': 'Sentence task has been completed', 'status': 'SUCCESS'}, 200
        elif task.state == 'PENDING':
            return {'message': 'Sentence task is still pending', 'status': 'PENDING'}, 202
        elif task.state == 'FAILURE':
            return {'message': 'Sentence task has failed', 'status': 'FAILURE'}, 500
        else:
            return {'message': 'Sentence task is in an unknown state', 'status': 'FAILURE'}, 500
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to check sentence task', 'status': 'FAILURE'}, 500