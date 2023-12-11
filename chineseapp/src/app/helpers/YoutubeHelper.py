import pinyin
import pinyin.cedict
import stanza
from stanza.pipeline.core import DownloadMethod
from hanziconv import HanziConv
import hanzidentifier
from redis import Redis, ConnectionPool
import requests
from src.app.config import Config
from transformers import AutoTokenizer, BertForTokenClassification
from transformers import pipeline
import json
import dimsim
from src.app.schemas.KeywordSchema import KeywordSchema
from collections import Counter
        
# @inproceedings{qi2020stanza,
#     title={Stanza: A {Python} Natural Language Processing Toolkit for Many Human Languages},
#     author={Qi, Peng and Zhang, Yuhao and Zhang, Yuhui and Bolton, Jason and Manning, Christopher D.},
#     booktitle = "Proceedings of the 58th Annual Meeting of the Association for Computational Linguistics: System Demonstrations",
#     year={2020}
# }

pool = ConnectionPool(host='redis', port=6379)

class YouTubeHelper:
    
    def __init__(self):
        self.stanza_nlp = None
        self.translation_cache = {}
        self.pinyin_cache = {}
        self.bing_url = "https://api.bing.microsoft.com/v7.0/images/search"
        self.subscription_key = Config.BING_IMG_API_KEY
        self.TAG = "raynardj/classical-chinese-punctuation-guwen-biaodian"
        self.model = None
        self.tokenizer = None
        self.ner = None
        self.redis = Redis(connection_pool=pool)  # Connect to your Redis server
        self.MAX_CHARS = 200
    
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

    def search_images_bing(self, word):
        headers = {"Ocp-Apim-Subscription-Key" : self.subscription_key}
        params  = {"q": word, "setlang": "zh-hans", "license": "public", "imageType": "photo", "count": 3}
        print("searching bing images...")
        try:
            print("I'm in the catch block!")
            response = requests.get(self.bing_url, headers=headers, params=params, allow_redirects=False)
            print(response.status_code)
            print(response.headers)
            search_results = response.json()
            image_urls = [img["contentUrl"] for img in search_results["value"]]
            print(f"received image urls... {image_urls}")
            return image_urls
        except Exception as e:
            print("Error getting images", str(e))

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
        print("text processing...")
        if not self.stanza_nlp:
            self.init_stanza_helper()
        results = []
        for i, segment in enumerate(transcript):
            simplified_text = HanziConv.toSimplified(segment['text'])
            doc = self.stanza_nlp(simplified_text)
            sentences = []
            for j, sentence in enumerate(doc.sentences):
                seg_res = []
                print(f"my sentence... {sentence.text}")
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
                    calc_pinyin = pinyin.get(word)  # Convert generator to list
                    self.redis.set(f'pinyin:{word}', json.dumps(calc_pinyin))
                else:
                    return None
            return json.loads(calc_pinyin)
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
                    self.redis.set(f'similarsound:{word}', json.dumps(list(candidates)))
                else:
                    return None
            cache_similarsounds = json.loads(cache_similarsounds)
            return cache_similarsounds[:3]
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
                    self.redis.set(f'translation:{word}', json.dumps(translation))
                else:
                    return None
            return json.loads(translation)
        except TypeError as e:
            print(f"Serialization translation error: {e}")
            return None
        except Exception as e:
            print(f"Unexpected translation error: {e}")
            return None

    def process_transcript(self, transcript):
        processed_transcript = self.video_processing(transcript)
        print("processed_transcript: ", processed_transcript)
        return processed_transcript

    def get_keywords(self, all_simplified, text_razor_client):
        response = text_razor_client.analyze(all_simplified)
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
        return unique_keywords
    
    def get_images(self, keywords):
        keyword_imgs = {}
        try:
            for keyword in keywords:
                cached_imgs = self.redis.get(f'images:{keyword}')
                if cached_imgs is None:
                    response = requests.get(f'https://www.googleapis.com/customsearch/v1?key={Config.GOOGLE_IMG_API_KEY}&cx={Config.GOOGLE_CX}&searchType=image&q={keyword}')
                    if response.status_code == 200:
                        images_data = response.json()
                        cached_imgs = images_data['images'][:3]
                        self.redis.set(f'images:{keyword}', json.dumps(cached_imgs))
                    else:
                        return None
                keyword_imgs[keyword] = json.loads(cached_imgs)
            return keyword_imgs
        except TypeError as e:
            print(f"Serialization images error: {e}")
            return None
        except Exception as e:
            print(f"Unexpected images error: {e}")
            return None

    def get_keywords_and_img(self, transcript, text_razor_client):
        all_simplified = self.turn_to_simplified(transcript)
        keywords = self.get_keywords(all_simplified, text_razor_client)
        keyword_images = self.get_images(keywords)
        print(f"keywords to images... {keyword_images}\n")
        return keyword_images
