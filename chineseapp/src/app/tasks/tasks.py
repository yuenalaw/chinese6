from src.app.celery_app import celery_app
from src.app.socket_util import send_message_client
from src.app.helpers.YoutubeHelper import YouTubeHelper
from src.app.helpers.ModelHelper import ModelService
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
        print(f"my processed video transcript: {processed_transcript}")
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
        print(f"my keyword images: {keyword_imgs}")
        return keyword_imgs
    except Exception as e:
        print("Error with keywords and image:", str(e))
        return None
    
@celery_app.task
def add_to_db(id, results):
    video_subtitles_details = results[0]
    video_keywords_img = results[1]
    print(f"IN THE TASK ADD TO DB: {video_subtitles_details}\n video keywords: {video_keywords_img}")
    # put into db
    """
    model_helper = ModelService()
    successfully_created_lesson = model_helper.create_video_lessons(id, video_subtitles_details, video_keywords_img)
    return successfully_created_lesson
    """
    return True

def execute_transcript_tasks(id):
    prepare_lesson = group(process_video_transcript.s(id), obtain_keywords_and_img.s(id))
    result = chord(prepare_lesson)(add_to_db.s(id))
    print(f"able to call db function -- expected return None for now\n")
    return result