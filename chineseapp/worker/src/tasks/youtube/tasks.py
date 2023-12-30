from ...celery_app import celery
from ...init_app import create_app
from ..helper.YoutubeHelper import YouTubeHelper
from ..helper.ModelService import ModelService
from celery import group, chord, chain
from celery.result import AsyncResult
import logging
import json

logger = logging.getLogger(__name__)
app = create_app() # using the same instance of Flask app as backend

@celery.task 
def error_handler(uuid):
    result = AsyncResult(uuid)
    error_message = f'Task {uuid} raised exception: {result.result!r}'
    return error_message

@celery.task(name="process_video_transcript")
def process_video_transcript(transcript_orig):
    try:
        youtube_helper = YouTubeHelper()
        processed_transcript = youtube_helper.process_transcript(transcript_orig)
        return processed_transcript
    except Exception as e:
        logger.error("Error with processing video transcript:", exc_info=True)
        error = f"Error with processing video transcript: {str(e)}"
        return error

@celery.task(name="process_video_transcript_from_transcript")
def process_video_transcript_from_transcript(transcript):
    try:
        youtube_helper = YouTubeHelper()
        processed_transcript = youtube_helper.process_transcript(transcript, False)
        return processed_transcript
    except Exception as e:
        print("Error with processing video transcript from transcript:", str(e))
        logger.error("Error with processing video transcript from transcript:", exc_info=True)
        return str(e)

@celery.task(name="obtain_keywords_and_img")
def obtain_keywords_and_img(transcript):
    try:
        youtube_helper = YouTubeHelper()
        keyword_imgs = youtube_helper.get_keywords_and_img(transcript)
        return keyword_imgs
    except Exception as e:
        print("Error with keywords and image other id:", str(e))
        logger.error("Error with keywords and image:", exc_info=True)
        return str(e)
    
@celery.task(name="prepare_add_to_db")
def prepare_add_to_db(results, id, source, forced):
    with app.app_context():
        try:
            model_service = ModelService()
            video_subtitles_details = results[0]
            video_keywords_img = results[1]
            model_service.create_video_lesson(id, video_subtitles_details, video_keywords_img, source, forced)
            return video_subtitles_details, video_keywords_img, id
        except Exception as e:
            logger.error("Error in add_to_db:", exc_info=True)
            return None

@celery.task(name="update_user_sentence")
def update_user_sentence(processed_sentence, id, line_changed):
    try:    
        with app.app_context():
            model_service = ModelService()
            print(f"in the celery update user sentence, before model service, with processed sentence: {processed_sentence}")
            processed_sentence = json.loads(processed_sentence)
            model_service.update_user_sentence(id, line_changed, processed_sentence)
            return processed_sentence
    except Exception as e:
        logger.error("Error in update_user_sentence:", exc_info=True)
        return None

@celery.task(name="process_new_sentence")
def process_new_sentence(sentence):
    try:
        youtube_helper = YouTubeHelper()
        processed_sentence = youtube_helper.process_sentence(sentence)
        return processed_sentence
    except Exception as e:
        print("Error with processing sentence:", str(e))
        logger.error("Error with processing sentence:", exc_info=True)
        return str(e)


@celery.task(name="execute_transcript_tasks")
def execute_transcript_tasks(id, transcript, source, forced):
    prepare_lesson = group(process_video_transcript.s(transcript).on_error(error_handler.s()), 
                        obtain_keywords_and_img.s(transcript).on_error(error_handler.s()))
    results = chord(prepare_lesson)(prepare_add_to_db.s(id, source, forced))
    print(f"Tasks are being executed in parallel\n")
    return results

@celery.task(name="execute_new_sentence")
def execute_new_sentence(video_id, line_changed, sentence):
    processed_sentence = chain(
        process_new_sentence.s(sentence),
        update_user_sentence.s(video_id, line_changed)
    )
    result = processed_sentence.apply_async()
    return result

@celery.task(name="execute_transcript_tasks_non_youtube")
def execute_transcript_tasks_non_youtube(id, transcript, source, forced):
    youtube_helper = YouTubeHelper()
    transcript_format_for_keywords = youtube_helper.convert_transcript_to_format(transcript)
    prepare_lesson = group(process_video_transcript_from_transcript.s(transcript), obtain_keywords_and_img.s(transcript_format_for_keywords))
    results = chord(prepare_lesson)(prepare_add_to_db.s(id, source, forced))
    print(f"Tasks are being executed in parallel for transcript non youtube\n")
    return results