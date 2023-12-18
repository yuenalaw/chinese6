from src.app.celery_app import celery
from src.app.socket_util import send_message_client
from src.app.helpers.YoutubeHelper import YouTubeHelper
from src.app.helpers.ModelHelper import ModelService
from youtube_transcript_api import YouTubeTranscriptApi
from celery import group, chord
import logging
# from celery import shared_task

logger = logging.getLogger(__name__)


@celery.task()
def example_task(param):
    return "This is an example"


@celery.task()
def process_video_transcript(id):
    try:
        youtube_helper = YouTubeHelper()
        transcript_orig = YouTubeTranscriptApi.get_transcript(id, languages=['zh-Hans', 'zh-Hant', 'zh-TW'])
        processed_transcript = youtube_helper.process_transcript(transcript_orig)
        return processed_transcript
        # send_message_client(video_id, {'task_id':video_id, 'result': transcript}) # client will subscribe to this room name!
    except Exception as e:
        print("Error with processing video transcript:", str(e))
        logger.error("Error with processing video transcript:", exc_info=True)
        return str(e)


@celery.task()
def obtain_keywords_and_img(id):
    try:
        youtube_helper = YouTubeHelper()
        transcript_orig = YouTubeTranscriptApi.get_transcript(id, languages=['zh-Hans', 'zh-Hant', 'zh-TW'])
        keyword_imgs = youtube_helper.get_keywords_and_img(transcript_orig)
        return keyword_imgs,id
    except Exception as e:
        print("Error with keywords and image:", str(e))
        logger.error("Error with keywords and image:", exc_info=True)
        return str(e)

@celery.task()
def prepare_add_to_db(results):
    try:
        model_service = ModelService()
        video_subtitles_details = results[0]
        video_keywords_img,id = results[1]
        model_service.create_video_lesson(id, video_subtitles_details, video_keywords_img)
        return True
    except Exception as e:
        logger.error("Error in add_to_db:", exc_info=True)
        return None


@celery.task()
def execute_transcript_tasks(id):
    prepare_lesson = group(process_video_transcript.s(id), obtain_keywords_and_img.s(id))
    result = chord(prepare_lesson)(prepare_add_to_db.s())
    print(f"Tasks are being executed in parallel\n")
    return result.id