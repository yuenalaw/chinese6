import pinyin
import pinyin.cedict
import stanza
from stanza.pipeline.core import DownloadMethod
from hanziconv import HanziConv
import hanzidentifier
import threading
import requests
from src.app.config import Config

#     @article{guhr-EtAl:2021:fullstop,
    #   title={FullStop: Multilingual Deep Models for Punctuation Prediction},
    #   author    = {Guhr, Oliver  and  Schumann, Anne-Kathrin  and  Bahrmann, Frank  and  Böhme, Hans Joachim},
    #   booktitle      = {Proceedings of the Swiss Text Analytics Conference 2021},
    #   month          = {June},
    #   year           = {2021},
    #   address        = {Winterthur, Switzerland},
    #   publisher      = {CEUR Workshop Proceedings},  
    #   url       = {http://ceur-ws.org/Vol-2957/sepp_paper4.pdf}
    # }

        
    # @inproceedings{qi2020stanza,
    #     title={Stanza: A {Python} Natural Language Processing Toolkit for Many Human Languages},
    #     author={Qi, Peng and Zhang, Yuhao and Zhang, Yuhui and Bolton, Jason and Manning, Christopher D.},
    #     booktitle = "Proceedings of the 58th Annual Meeting of the Association for Computational Linguistics: System Demonstrations",
    #     year={2020}
    # }
    

class YouTubeHelper:
    _instance = None # Singleton instance
    _init_lock = threading.Lock()

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(YouTubeHelper, cls).__new__(cls)
            cls._instance.init_singleton()
        return cls._instance
    
    def init_singleton(self):
        self.stanza_nlp = None
        self.translation_cache = {}
        self.pinyin_cache = {}
        self.bing_url = "https://api.bing.microsoft.com/v7.0/images/search"
        self.subscription_key = Config.BING_IMG_API_KEY


    def init_helper(self):
        with self._init_lock:
            if self.stanza_nlp is None:
                try:
                    self.stanza_nlp = stanza.Pipeline('zh', download_method=DownloadMethod.REUSE_RESOURCES, use_gpu=False, verbose=False)
                except Exception as e:
                    print("Error initializing stanza pipeline:", str(e))

    def search_images_bing(self, word):
        headers = {"Ocp-Apim-Subscription-Key" : self.subscription_key}
        params  = {"q": word, "setlang": "zh-hans", "license": "public", "imageType": "photo", "count": 3}
        print("searching bing images...")
        try:
            print("I'm in the catch block!")
            response = requests.get(self.bing_url, headers=headers, params=params, allow_redirects=False)
            print(response.status_code)
            print(response.headers)
            # response.raise_for_status()
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
    
    def get_pinyin(self, word):
        if hanzidentifier.has_chinese(word):
            return pinyin.get(word)
        return ""
        
    def get_translation(self, word):
        if hanzidentifier.has_chinese(word):
            return list(pinyin.cedict.all_phrase_translations(word))
        return word

    def word_segmentation_with_pinyin_and_translation(self, concatenated_text):
        print("word segmenting...")
        if not self.stanza_nlp:
            self.init_helper()

        # Split the text into chunks of approximately 1000 characters -- WHAT IF MID SENTENCE?!
        text_chunks = [concatenated_text[i:i+1000] for i in range(0, len(concatenated_text), 1000)]

        sentence_and_words = []
        for text_chunk in text_chunks:
            try:
                doc = self.stanza_nlp(text_chunk)
                # for each sentence in the doc, obtain the words
                for sentence in doc.sentences:
                    seg_res = []
                    for word in sentence.words:
                        word_text = word.text.strip()
                        calculated_pinyin = self.pinyin_cache.get(word_text)
                        if not calculated_pinyin:
                            calculated_pinyin = self.get_pinyin(word_text)
                            self.pinyin_cache[word_text] = calculated_pinyin

                        calculated_translation = self.translation_cache.get(word_text)
                        if not calculated_translation:
                            calculated_translation = self.get_translation(word_text)
                            self.translation_cache[word_text] = calculated_translation
                        entry = {
                            "word": word_text,
                            "word_lemma": word.lemma.strip(),
                            "word_pos": word.pos.strip(), #IS PROPN/ NOUN/ AUX etc
                            "pinyin": calculated_pinyin,
                            "translation": calculated_translation
                        }
                        seg_res.append(entry)
                    sentence_and_words.append(seg_res)
            except Exception as e:
                print("Error with stanza: " + str(e))
                return {"error": str(e)}

        print("finished word segmenting...")
        return sentence_and_words

    def process_transcript(self, transcript):
        simplified_transcript = self.turn_to_simplified(transcript)
        print("simplified transcript: ", simplified_transcript)
        processed_transcript = self.word_segmentation_with_pinyin_and_translation(simplified_transcript)
        print("processed_transcript: ", processed_transcript)
        return processed_transcript