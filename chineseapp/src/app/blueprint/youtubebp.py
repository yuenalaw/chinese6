from flask import Blueprint, request

from src.app.tasks.tasks import process_video_transcript, example_task
from src.app.textrazor_client import text_razor_client
from src.app.schemas.KeywordSchema import KeywordSchema
from collections import Counter
from src.app.helpers.YoutubeHelper import YouTubeHelper
import dimsim

youtubebp = Blueprint('youtubebp', __name__,
                     template_folder='templates',
                     static_folder='static',
                     static_url_path='assets')

@youtubebp.route('/vid') #/vid?v=<id>
def process_video():
    id=request.args.get('v')
    try:
        # enqueue celery task
        print(f"trying to enqueue... {id}")
        result = process_video_transcript.delay(id)
        task_id = result.id
        print(f"Task ID:{task_id}")
        #blocking - to get the celery task (for now)
        transcript = result.get()
        if transcript:
            return transcript
        else:
            return '<h1>An error with getting initial translations...</h1>'
    except Exception as e:
        print("Error:", str(e))
        return '<h1>No chinese transcript for this video found</h1>'

@youtubebp.route('/lessonkeywords')
def keywords_video():
    video_id = request.args.get('v') #video id
    lesson_id = request.args.get('lesson') #lesson no. (videos are split into small lessons)

    # obtain from the db the composite key video id and lesson id

    try:
        response = text_razor_client.analyze("计算机科学是一个广泛而迅速发展的领域，它涉及到计算机系统的设计、开发和应用。这一领域的重要性在当今社会日益增长，因为计算机技术已经成为几乎所有行业的核心组成部分。本文将探讨计算机科学的一些关键方面，包括它的历史、应用、和未来发展趋势。 \
                                             计算机科学的历史可以追溯到20世纪初期，当时计算机作为巨大的机械装置出现，用于执行数学运算和数据处理。随着时间的推移，计算机变得更小、更强大，同时也更加普及。第二次世界大战期间，计算机被用于解密敌方的密码，这标志着计算机在军事和情报领域的重要性。在20世纪后半叶，个人计算机的兴起改变了人们的生活方式，开创了一个数字时代。\
                                             计算机科学在各个领域都有广泛的应用。它不仅影响到通信、医疗保健、金融和教育等行业，还在科学研究中扮演着重要的角色。例如，计算机模拟已经成为物理、化学和生物领域的重要工具，用于研究分子结构、气候模式和生物系统。此外，计算机科学还推动了人工智能（AI）的发展，使机器能够模仿人类智能，进行语言处理、图像识别和自动驾驶等任务。\
                                             未来，计算机科学领域仍然充满机遇和挑战。随着技术的不断进步，计算机将变得更加强大和智能化。量子计算机的发展有望在解决目前无法处理的问题上取得突破，如量子力学模拟和密码学。同时，人工智能和机器学习将继续推动自动化和智能系统的发展，从自动驾驶汽车到智能家居。然而，计算机科学领域也面临着一些伦理和社会问题。隐私和数据安全问题引发了关于数据收集和使用的争议。此外，自动化可能导致一些工作的失业，这需要社会制定政策来解决。\
                                             总之，计算机科学是一个不断演进的领域，它在当今社会中起着至关重要的作用。它的历史可以追溯到几十年前，但它的未来将继续塑造我们的生活方式和社会。计算机科学的应用范围广泛，从医疗保健到科学研究，再到人工智能和机器学习，都有着深远的影响。在探讨计算机科学的未来时，我们必须谨慎处理伦理和社会问题，以确保技术的发展符合人类的最大利益。通过继续研究和创新，我们可以期待计算机科学领域的更多令人兴奋的发展。")
        all_keywords = []
        keyword_schemas = []
        for entity in response.entities():
            keyword_schema = KeywordSchema(entity.id, entity.freebase_types)
            keyword_schemas.append(keyword_schema)
            all_keywords.append(entity.id)
            print(entity.id, entity.relevance_score, entity.confidence_score, entity.freebase_types)
        priority_keywords = Counter(all_keywords)

        sorted_keywords = sorted(
            keyword_schemas,
            key = lambda entity: priority_keywords[entity.ChineseWord],
            reverse=False
        )
        #remove duplicates
        seen_words = set()
        unique_keywords = [entity for entity in sorted_keywords if not (entity.ChineseWord in seen_words or seen_words.add(entity.ChineseWord))]
        return '<h1>yeahh</h1>'
    except Exception as e:
        print(f"{e} error - text razor")
        return '<h1>Text razor error</h1>'

@youtubebp.route('/keywordimg')
def get_img_youtubebp():
    word = request.args.get('w')
    print(f"got {word}")
    try:
        youtube_helper = YouTubeHelper()
        results = youtube_helper.search_images_bing(word)
        print(f"got results {results}")
        if results:
            return results
        else:
            return '<h1>No images found</h1>'
    except Exception as e:
        print(f"Exception: {e}, type: {type(e)}, args: {e.args}")
        return '<h1>Google images error</h1>'

@youtubebp.route('/keywordsimilar')
def get_similarwords():
    youtube_helper = YouTubeHelper()
    word = request.args.get('w')
    try:
        candidates = dimsim.get_candidates(word, mode='simplified', theta=1)
        # for the words, get their pinyin as well
        candidate_pinyin = {}
        for candidate in candidates:
            candidate_pinyin[candidate] = youtube_helper.get_pinyin(candidate)
        print(candidate_pinyin)
        return candidate_pinyin
    except Exception as e:
        print(f"{e} error - getting similar words")
        return '<h1>similar words error</h1>'

