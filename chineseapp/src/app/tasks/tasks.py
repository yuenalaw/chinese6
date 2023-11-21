from src.app.celery_app import celery_app
from src.app.socket_util import send_message_client
from youtube_transcript_api import YouTubeTranscriptApi
from src.app.helpers.YoutubeHelper import YouTubeHelper

# Example task
@celery_app.task
def example_task(param):
    return "This is an example"

@celery_app.task
def process_video_transcript(video_id):
    print("I have been called!", video_id)
    try:
        transcript_orig = YouTubeTranscriptApi.get_transcript(video_id, languages=['zh-Hans', 'zh-Hant', 'zh-TW'])
        print("transcript:",transcript_orig)
        youtubeHelper = YouTubeHelper()
        transcript = youtubeHelper.process_transcript(transcript_orig)
        # add to db

        send_message_client(video_id, {'task_id':video_id, 'result': transcript}) # client will subscribe to this room name!
    except Exception as e:
        print("Error:", str(e))
        return None