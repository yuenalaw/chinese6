from ...celery_app import celery
from ..helper.YoutubeHelper import YouTubeHelper
from ..helper.ModelService import ModelService
from youtube_transcript_api import YouTubeTranscriptApi
from celery import group, chord, chain
import logging

logger = logging.getLogger(__name__)

@celery.task(name="process_video_transcript")
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

@celery.task(name="obtain_keywords_and_img")
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
    
@celery.task(name="prepare_add_to_db")
def prepare_add_to_db(results):
    try:
        model_service = ModelService()
        video_subtitles_details = results[0]
        video_keywords_img,id = results[1]
        print(f"In prepare add to db... video sub details: {video_subtitles_details}\n video keywords img: {video_keywords_img}\n videoid: {id}")
        model_service.create_video_lesson(id, video_subtitles_details, video_keywords_img)
        return video_subtitles_details, video_keywords_img, id
    except Exception as e:
        logger.error("Error in add_to_db:", exc_info=True)
        return None

@celery.task(name="update_user_sentence")
def update_user_sentence(processed_sentence, youtube_id, line_changed):
    try:
        model_service = ModelService()
        print(f"in the celery update user sentence, before model service, with processed sentence: {processed_sentence}")
        model_service.update_user_sentence(youtube_id, line_changed, processed_sentence)
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
def execute_transcript_tasks(id):
    prepare_lesson = group(process_video_transcript.s(id), obtain_keywords_and_img.s(id))
    results = chord(prepare_lesson)(prepare_add_to_db.s())
    #results = prepare_lesson.apply_async()
    print(f"Tasks are being executed in parallel\n")
    return results

@celery.task(name="execute_new_sentence")
def execute_new_sentence(youtube_id, line_changed, sentence):
    processed_sentence = chain(
        process_new_sentence.s(sentence),
        update_user_sentence.s(youtube_id, line_changed)
    )
    result = processed_sentence.apply_async()
    return result