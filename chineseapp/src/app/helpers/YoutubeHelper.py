import pinyin
import pinyin.cedict
import stanza
from stanza.pipeline.core import DownloadMethod
from hanziconv import HanziConv
import hanzidentifier
from redis import Redis, ConnectionPool
import requests
import time
from requests.exceptions import HTTPError
from src.app.config import Config
from transformers import AutoTokenizer, BertForTokenClassification
from transformers import pipeline
import json
import dimsim
from src.app.schemas.KeywordSchema import KeywordSchema
from collections import Counter
from src.app.textrazor_client import text_razor_client
from pyunsplash import PyUnsplash
import base64
        
# @inproceedings{qi2020stanza,
#     title={Stanza: A {Python} Natural Language Processing Toolkit for Many Human Languages},
#     author={Qi, Peng and Zhang, Yuhao and Zhang, Yuhui and Bolton, Jason and Manning, Christopher D.},
#     booktitle = "Proceedings of the 58th Annual Meeting of the Association for Computational Linguistics: System Demonstrations",
#     year={2020}
# }

pool = ConnectionPool(host='redis', port=6379)

class YouTubeHelper:
    pu = PyUnsplash(api_key=Config.UNSPLASH_ACCESS_KEY)
    
    def __init__(self):
        self.stanza_nlp = None
        self.translation_cache = {}
        self.pinyin_cache = {}
        self.bing_url = "https://api.bing.microsoft.com/v7.0/images/search"
        self.TAG = "raynardj/classical-chinese-punctuation-guwen-biaodian"
        self.model = None
        self.tokenizer = None
        self.ner = None
        self.redis = Redis(connection_pool=pool)  # Connect to your Redis server
        self.MAX_CHARS = 200
        self.text_razor_client = text_razor_client
    
    def init_ner_helper(self):
        try:
            if self.model is None:
                self.model = BertForTokenClassification.from_pretrained(self.TAG, cache_dir='/app/model_cache')
                print(f"NER model downloaded to: app/model_cache")
            if self.tokenizer is None:
                self.tokenizer = AutoTokenizer.from_pretrained(self.TAG, cache_dir='/app/tokenizer_cache')
                print(f"Tokenizer downloaded to: app/tokenizer_cache")
            if self.ner is None:
                self.ner = pipeline("ner", model=self.model, tokenizer=self.tokenizer)
        except Exception as e:
            print("Error initializing ner pipelines:", str(e))

    def init_stanza_helper(self):
        try:
            print(f"downloading stanza....")
            if self.stanza_nlp is None:
                # Specify the directory where you want to save the models
                stanza.download('zh', verbose=False, processors='tokenize,pos,lemma', model_dir='/app/stanza_resources')
                self.stanza_nlp = stanza.Pipeline('zh', verbose=False, processors='tokenize,pos,lemma', model_dir='/app/stanza_resources')
                print(f"Stanza model downloaded to: app/stanza_resources")
        except Exception as e:
            print("Error initializing stanza pipelines:", str(e))

    def turn_to_simplified(self, transcript): 
        print("turning to simplified...")
        simplified_transcript = ""
        for idx in range(len(transcript)):
            text = transcript[idx]['text']
            try:
                simplified_transcript += HanziConv.toSimplified(text)
            except:
                simplified_transcript += ""
        print("finished simplified!")
        return simplified_transcript.strip()

    def video_processing(self, transcript):
        if not self.stanza_nlp:
            self.init_stanza_helper()
        results = []
        for i, segment in enumerate(transcript):
            simplified_text = HanziConv.toSimplified(segment['text'])
            doc = self.stanza_nlp(simplified_text)
            sentences = []
            for j, sentence in enumerate(doc.sentences):
                seg_res = []
                if sentence.text and not sentence.text.strip().isalnum():
                    continue #skip those that are just punctuation
                for word in sentence.words:
                    word_text = word.text
                    word_upos = word.upos

                    calculated_pinyin = self.get_pinyin(word_text)

                    calculated_translation = self.get_translation(word_text)

                    similar_sounds = self.get_similarsoundwords(word_text)

                    entry = {
                        "word": word_text,
                        "upos": word_upos,
                        "pinyin": calculated_pinyin,
                        "translation": calculated_translation,
                        "similarsounds": similar_sounds
                    }
                    seg_res.append(entry)
                sentence_obj = {
                    "sentence": sentence.text,
                    "entries": seg_res
                }
                sentences.append(sentence_obj)
            results.append({
                "segment": simplified_text,
                "start": segment['start'],
                "duration": segment['duration'],
                "sentences": sentences
            })
        return results
    
    
    def generate_punctuation(self,x: str):
        if not self.model or not self.tokenizer or not self.ner:
            print("initialising ner model...")
            self.init_ner_helper()
        print("adding punctuation...")

        outputs = self.ner(x)
        x_list = list(x)
        for i, output in enumerate(outputs):
            x_list.insert(output['end']+i, output['entity'])
        
        print("finished punctuation!")
        
        return "".join(x_list)
    
    def get_pinyin(self, word):
        try:
            calc_pinyin = self.redis.get(f'pinyin:{word}')
            if calc_pinyin is None:
                if hanzidentifier.has_chinese(word):
                    calc_pinyin = pinyin.get(word, format="strip", delimiter=" ")
                    if calc_pinyin is not None:
                        calc_pinyin_json = json.dumps(calc_pinyin)
                        self.redis.set(f'pinyin:{word}', calc_pinyin_json)
                        return calc_pinyin_json
                    return None
                return None
            return json.loads(calc_pinyin.decode('utf-8'))  # Decode the byte string and load the JSON data
        except TypeError as e:
            print(f"Serialization error pinyin: {e}")
            return None
        except Exception as e:
            print(f"Unexpected pinyin error: {e}")
            return None

    def get_similarsoundwords(self, word):
        if word is None:
            return None
        try:
            cache_similarsounds = self.redis.get(f'similarsound:{word}')
            if cache_similarsounds is None:
                candidates = list(dimsim.get_candidates(word, mode='simplified', theta=1))
                if candidates:
                    candidates_json = json.dumps(list(candidates))
                    self.redis.set(f'similarsound:{word}', candidates_json)
                    return candidates_json
                return None
            return json.loads(cache_similarsounds.decode('utf-8'))  # Decode the byte string and load the JSON data
        except TypeError as e:
            print(f"Serialization error similar sounds: {e}")
            return None
        except Exception as e:
            print(f"Unexpected similar sounds error: {e}")
            return None

            
    def get_translation(self, word):
        try:
            translation = self.redis.get(f'translation:{word}')
            if translation is None:
                if hanzidentifier.has_chinese(word):
                    translation = list(pinyin.cedict.all_phrase_translations(word))
                    # Convert to list and serialize to JSON
                    translation_json = json.dumps(translation)
                    self.redis.set(f'translation:{word}', translation_json)
                    return translation_json
                else:
                    return None
            return json.loads(translation.decode('utf-8'))
        except TypeError as e:
            print(f"Serialization translation error: {e}")
            return None
        except Exception as e:
            print(f"Unexpected translation error: {e}")
            return None

    def process_transcript(self, transcript):
        processed_transcript = self.video_processing(transcript)
        return processed_transcript

    def get_keywords(self, all_simplified):
        response = self.text_razor_client.analyze(all_simplified)
        all_keywords = []
        keyword_schemas = []
        for entity in response.entities():
            if entity.id.isalpha() and entity.id.isascii():
                continue # ignore english
            keyword_schema = KeywordSchema(entity.id, entity.freebase_types)
            keyword_schemas.append(keyword_schema)
            all_keywords.append(entity.id)
        priority_keywords = Counter(all_keywords)

        sorted_keywords = sorted(
            keyword_schemas,
            key = lambda entity: priority_keywords[entity.ChineseWord],
            reverse=False
        )
        #remove duplicates
        seen_words = set()
        unique_keywords = [entity for entity in sorted_keywords if not (entity.ChineseWord in seen_words or seen_words.add(entity.ChineseWord))]
        return unique_keywords[:30]
    
    def get_with_backoff(self, url, max_retries=10):
        for n in range(max_retries):
            try:
                response = requests.get(url)
                response.raise_for_status()
                return response
            except HTTPError as e:
                if e.response.status_code == 429 and n < max_retries - 1:  # Too Many Requests
                    sleep_time = 2 ** n  # Exponential backoff
                    print(f"Rate limit exceeded. Retrying in {sleep_time} seconds...")
                    time.sleep(sleep_time)
                    continue
                else:
                    raise
        return None

    def get_images(self, keywords):
        keyword_imgs = []
        customsearch_url = f"https://www.googleapis.com/customsearch/v1?key={Config.GOOGLE_IMG_API_KEY}&cx={Config.GOOGLE_CX}&searchType=image&q="
        try:
            for keywordObj in keywords:
                keyword = keywordObj.ChineseWord
                self.redis.delete(f'images:{keyword}') # DELETE THIS!! (after one round)
                print(f"looking up images for {keyword}\n")
                cached_imgs = self.redis.get(f'images:{keyword}')
                if cached_imgs is None:
                    try:
                        photos = self.pu.photos(type_='random', count=1, featured=True, query="splash")
                        [photo] = photos.entries
                        download_link = photo.link_download
                        #response = requests.get(download_link, allow_redirects=True)
                        # Convert the image data to base64
                        #image_base64 = base64.b64encode(response.content).decode('utf-8')
                        self.redis.set(f'images:{keyword}', json.dumps(download_link))
                    except requests.exceptions.RequestException as e:
                        print(f"PyUnsplash API request failed: {e}")
                        cached_imgs = None
                else:
                    if cached_imgs is not None:
                        cached_imgs = json.loads(cached_imgs)
                keyword_imgs.append({'keyword': keyword, 'img': cached_imgs})
            return keyword_imgs
        except TypeError as e:
            print(f"Serialization images error: {e}")
            return None
        except Exception as e:
            print(f"Unexpected images error: {e}")
            return None


    def get_keywords_and_img(self, transcript):
        print(f"getting keywords and img in youtube helper \n")
        all_simplified = self.turn_to_simplified(transcript)
        keywords = self.get_keywords(all_simplified)
        keyword_images = self.get_images(keywords)
        return keyword_images
