from flask import Blueprint, request
from src.app.helpers.ModelService import ModelService

db_bp = Blueprint('db_bp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

model_service = ModelService()

@db_bp.route('/makelesson', methods=['POST'])
def create_lesson():
    request_data = request.form
    print(f"request data is {request_data}")
    try:
        model_service.create_video_lesson(request_data['youtube_id'], request_data['processed_transcript'], request_data['keyword_to_images'])
        return {'message': 'Successfully added video to db!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to add video to db'}, 500

@db_bp.route('/getlesson/<youtube_id>', methods=['GET'])
def obtain_lesson(youtube_id):
    print(f"obtaining lesson for {youtube_id}")
    try:
        obtained_video = model_service.get_video(youtube_id)
        return {'message': 'Successfully obtained video!', 'video': obtained_video}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain video'}, 500

@db_bp.route('/addstudydate')
def add_study_date():
    try:
        model_service.add_study_date()
        return {'message': 'Successfully added study date!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to add study date'}, 500

@db_bp.route('/getstreak')
def get_streak():
    try:
        study_streak = model_service.get_streak()
        return {'message': 'Successfully obtained study streak!', 'streak': study_streak}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain study streak'}, 500

@db_bp.route('/addreview', methods=['POST'])
def add_review():
    request_data = request.form
    print(f"request data is {request_data}")
    try:
        model_service.add_review(request_data['word'], request_data['pinyin'], request_data['similar_words'], request_data['translation'], request_data['sentence_id'], request_data['note'])
        return {'message': 'Successfully added review!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to add review'}, 500

@db_bp.route('/updatesentence', methods=['POST'])
def update_user_sentence():
    request_data = request.form
    print(f"request data is {request_data}")
    try:
        model_service.update_user_sentence(request_data['youtube_id'], request_data['line_changed'], request_data['new_sentence'])
        return {'message': 'Successfully updated user sentence!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update user sentence'}, 500

@db_bp.route('/updatenote', methods=['POST'])
def update_note():
    request_data = request.form
    print(f"request data is {request_data}")
    try:
        model_service.update_note(request_data['youtube_id'], request_data['word_id'], request_data['line_changed'], request_data['note'])
        return {'message': 'Successfully updated note!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update note'}, 500

@db_bp.route('/getcontext/<youtube_id>/<line_changed>')
def get_context(youtube_id, line_changed):
    try:
        context = model_service.get_sentence_context(youtube_id, line_changed)
        return {'message': 'Successfully obtained context!', 'context': context}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain context'}, 500


@db_bp.route('/getcardstoday', methods=['GET'])
def get_review_cards():
    try:
        review_cards = model_service.get_cards_today()
        return {'message': 'Successfully obtained review cards!', 'review_cards': review_cards}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain review cards'}, 500