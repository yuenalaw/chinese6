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
import re
import json
import regex
        
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

    # should be used in a thread to get the keywords
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

                    entry = {
                        "word": word_text,
                        "upos": word_upos,
                        "pinyin": calculated_pinyin,
                        "translation": calculated_translation
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
        calc_pinyin = self.redis.get(f'pinyin:{word}')
        if calc_pinyin is None:
            if hanzidentifier.has_chinese(word):
                calc_pinyin = pinyin.get(word)
                self.redis.set(f'pinyin:{word}', calc_pinyin)       
            else:
                return None
        return calc_pinyin
        
    def get_translation(self, word):
        try:
            translation = self.redis.get(f'translation:{word}')
            if translation is None:
                if hanzidentifier.has_chinese(word):
                    translation = pinyin.cedict.all_phrase_translations(word)
                    # Convert to list and serialize to JSON
                    self.redis.set(f'translation:{word}', json.dumps(list(translation)))
                else:
                    return None
            return json.loads(translation)
        except TypeError as e:
            print(f"Serialization error: {e}")
            return None
        except Exception as e:
            print(f"Unexpected error: {e}")
            return None

    def process_transcript(self, transcript):
        processed_transcript = self.video_processing(transcript)
        print("processed_transcript: ", processed_transcript)
        return processed_transcript