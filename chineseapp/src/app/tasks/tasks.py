from src.app.celery_app import celery_app
from src.app.socket_util import send_message_client
from src.app.helpers.YoutubeHelper import YouTubeHelper
from youtube_transcript_api import YouTubeTranscriptApi
from celery import group, chord

# Example task
@celery_app.task
def example_task(param):
    return "This is an example"

@celery_app.task
def process_video_transcript(id):
    try:
        youtube_helper = YouTubeHelper()
        transcript_orig = YouTubeTranscriptApi.get_transcript(id, languages=['zh-Hans', 'zh-Hant', 'zh-TW'])
        processed_transcript = youtube_helper.process_transcript(transcript_orig)
        return processed_transcript
        # send_message_client(video_id, {'task_id':video_id, 'result': transcript}) # client will subscribe to this room name!
    except Exception as e:
        print("Error with processing video transcript:", str(e))
        return None

@celery_app.task
def obtain_keywords_and_img(id):
    try:
        youtube_helper = YouTubeHelper()
        transcript_orig = YouTubeTranscriptApi.get_transcript(id, languages=['zh-Hans', 'zh-Hant', 'zh-TW'])
        keyword_imgs = youtube_helper.get_keywords_and_img(transcript_orig)
        return keyword_imgs
    except Exception as e:
        print("Error with keywords and image:", str(e))
        return None
    
@celery_app.task
def add_to_db(results):
    video_subtitles_details = results[0]
    video_keywords_img = results[1]
    # put into db
    print(f"put into db...{video_subtitles_details}\n{video_keywords_img}\n")
    return None

def execute_transcript_tasks(id):
    prepare_lesson = group(process_video_transcript.s(id), obtain_keywords_and_img.s(id))
    result = chord(prepare_lesson)(add_to_db.s())
    print(f"able to call db function -- expected return None for now\n")
    return result