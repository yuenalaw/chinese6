from src.app.celery_app import celery_app
from src.app.socket_util import send_message_client

# Example task
@celery_app.task
def example_task(param):
    return "This is an example"

@celery_app.task
def process_video_transcript(transcript_orig, youtube_helper):
    try:
        youtube_helper.process_transcript(transcript_orig)
        # send_message_client(video_id, {'task_id':video_id, 'result': transcript}) # client will subscribe to this room name!
    except Exception as e:
        print("Error with processing video transcript:", str(e))
        return None

@celery_app.task
def obtain_keywords_and_img(transcript_orig, youtube_helper, text_razor_client):
    try:
        youtube_helper.get_keywords_and_img(transcript_orig, text_razor_client)
    except Exception as e:
        print("Error with keywords and image:", str(e))
        return None
    
@celery_app.task
def add_to_db(results):
    video_subtitles_details = results[0]
    video_keywords_img = results[1]
    # put into db
    pass