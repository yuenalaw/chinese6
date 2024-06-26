from flask import Blueprint, request, jsonify
from ...shared.helper.ModelService import ModelService

db_bp = Blueprint('db_bp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

model_service = ModelService()

@db_bp.route('/getlesson/<video_id>', methods=['GET'])
def obtain_lesson(video_id):
    print(f"obtaining lesson for {video_id}")
    try:
        if model_service.video_exists(video_id):
            obtained_video = model_service.get_video(video_id)
            return {'message': 'Successfully obtained video!', 'video': obtained_video}, 200
        return {'message': 'Video does not exist... yet!'}, 404
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain video'}, 500

@db_bp.route('/getword/<word>', methods=['GET'])
def get_word(word):
    try:
        word = model_service.get_word(word)
        return {'message': 'Successfully obtained word!', 'word': word}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain word'}, 500

@db_bp.route('/addstudydate', methods=['POST'])
def add_study_date():
    request_data = request.get_json()
    date = request_data.get('date', None)
    print(f"request data is {request_data}")
    try:
        model_service.add_study_date(date)
        return {'message': 'Successfully added study date!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to add study date'}, 500

@db_bp.route('/getstreak',methods=['GET'])
def get_streak():
    try:
        study_streak = model_service.get_streak()
        return {'message': 'Successfully obtained study streak!', 'streak': study_streak}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain study streak'}, 500

@db_bp.route('/getreview/<word>/<video_id>/<line_changed>',methods=['GET'])
def get_review(word, video_id, line_changed):
    try:
        review = model_service.get_review(word, video_id, line_changed)
        return {'message': 'Successfully obtained review!', 'review': review}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain review'}, 500

@db_bp.route('/addnewreview', methods=['POST'])
def add_review():
    request_data = request.get_json()
    print(f"request data is {request_data}")
    try:
        model_service.add_review(request_data['word'], request_data['pinyin'], request_data['similar_words'], request_data['translation'], request_data['video_id'], request_data['line_changed'], request_data['sentence'], request_data['note'], request_data['image_path'])
        return {'message': 'Successfully added review!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to add review'}, 500

@db_bp.route('/updatereview', methods=['POST'])
def update_review():
    request_data = request.get_json()
    print(f"request data is {request_data}")
    try:
        model_service.update_user_word_review(request_data['word_id'], request_data['last_repetitions'], request_data['prev_ease_factor'], request_data['prev_word_interval'], request_data['quality'])
        return {'message': 'Successfully updated review!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update review'}, 500

@db_bp.route('/batchupdatereviews', methods=['POST'])
def update_reviews():
    request_data = request.get_json()
    print(f"request data is {request_data}")
    try:
        model_service.update_reviews_batch(request_data)
        return {'message': 'Successfully updated reviews!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update reviews'}, 500

@db_bp.route('/addword', methods=['POST'])
def add_word():
    # Parse JSON data from the request
    request_data = request.get_json()
    try:
        model_service.add_word(request_data['word'], request_data['pinyin'], request_data['similar_words'], request_data['translation'])
        return jsonify({'message': 'Successfully added word!'}), 200
    except Exception as e:
        print("Error:", str(e))
        return jsonify({'message': 'Failed to add word'}), 500

@db_bp.route('/getwordsentence/<word>/<video_id>/<line_changed>',methods=['GET'])
def get_word_sentence(word, video_id, line_changed):
    try:
        word_sentence = model_service.get_word_sentence(word, video_id, line_changed)
        return {'message': 'Successfully obtained word sentence!', 'word_sentence': word_sentence}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain word sentence'}, 500

@db_bp.route('/getupdatedsentence/<video_id>/<line_changed>',methods=['GET'])
def get_updated_user_sentence(video_id, line_changed):
    try:
        updated_sentence = model_service.get_updated_user_sentence(video_id, line_changed)
        if updated_sentence.updated_sentence == None:
            return {'message': 'No updated sentence found... yet:)'}, 404
        return {'message': 'Successfully obtained updated sentence!', 'updated_sentence': updated_sentence}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain updated sentence'}, 500

@db_bp.route('/updatenote', methods=['POST'])
def update_note():
    request_data = request.get_json()
    print(f"request data is {request_data}")
    try:
        model_service.update_note(request_data['video_id'], request_data['word_id'], request_data['line_changed'], request_data['note'])
        return {'message': 'Successfully updated note!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update note'}, 500

@db_bp.route('/updatetitle', methods=['POST'])
def update_video_title():
    request_data = request.get_json()
    print(f"request data is {request_data}")
    try:
        model_service.update_video_title(request_data['video_id'], request_data['title'])
        return {'message': 'Successfully updated video title!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update video title'}, 500

@db_bp.route('/getlibrary', methods=['GET'])
def get_library():
    try:
        library = model_service.get_library()
        return {'message': 'Successfully obtained library!', 'library': library}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to obtain library'}, 500
    
@db_bp.route('/updateimagepath', methods=['POST'])
def update_image_path():
    request_data = request.get_json()
    print(f"request data is {request_data}")
    try:
        model_service.update_image_path(request_data['video_id'], request_data['word_id'], request_data['line_changed'], request_data['image_path'])
        return {'message': 'Successfully updated image path!'}, 200
    except Exception as e:
        print("Error:", str(e))
        return {'message': 'Failed to update image path'}, 500

@db_bp.route('/getcontext/<video_id>/<line_changed>',methods=['GET'])
def get_context(video_id, line_changed):
    try:
        context = model_service.get_sentence_context(video_id, line_changed)
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