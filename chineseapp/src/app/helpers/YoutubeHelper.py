import pinyin
import pinyin.cedict
import stanza
from stanza.pipeline.core import DownloadMethod
from hanziconv import HanziConv
import hanzidentifier
import threading
import requests
from src.app.config import Config
from transformers import AutoTokenizer, BertForTokenClassification
from transformers import pipeline

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
        self.TAG = "raynardj/classical-chinese-punctuation-guwen-biaodian"
        self.model = None
        self.tokenizer = None
        self.ner = None

    def init_helper(self):
        with self._init_lock:
            try:
                if self.stanza_nlp is None:
                    self.stanza_nlp = stanza.Pipeline('zh', download_method=DownloadMethod.REUSE_RESOURCES, use_gpu=False, verbose=False)
                if self.model is None:
                    self.model = BertForTokenClassification.from_pretrained(self.TAG)
                if self.tokenizer is None:
                    self.tokenizer = AutoTokenizer.from_pretrained(self.TAG)
                if self.ner is None:
                    self.ner = pipeline("ner", self.model, tokenizer=self.tokenizer)
            except Exception as e:
                print("Error initializing pipelines:", str(e))

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
    
    
    def generate_punctuation(self,x: str):
        print("punctuation...")

        outputs = self.ner(x)
        x_list = list(x)
        for i, output in enumerate(outputs):
            x_list.insert(output['end']+i, output['entity'])
        
        print("finished punctuation!")
        
        return "".join(x_list)
    
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
        if not self.stanza_nlp or not self.model or not self.tokenizer or not self.ner:
            self.init_helper()

        processed_text = concatenated_text.replace('。 ', '。\n\n') #stanza recognises \n\n as sentence
        try:
            doc = self.stanza_nlp(processed_text)
            sentence_and_words = {}
            for sentence in doc.sentences:
                seg_res = []
                for word in sentence.words:
                    word_text = word.text.strip()
                    word_upos = word.upos.strip()
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
                        "upos": word_upos,
                        "word_lemma": word.lemma.strip(),
                        "word_pos": word.pos.strip(), #IS PROPN/ NOUN/ AUX etc
                        "pinyin": calculated_pinyin,
                        "translation": calculated_translation
                    }
                    seg_res.append(entry)
                sentence_and_words[sentence.text] = seg_res  
            print("finished word segmenting...")
            return sentence_and_words
        except Exception as e:
            print("Error with stanza: " + str(e))
            return {"error": str(e)}

    def process_transcript(self, transcript):
        simplified_transcript = self.turn_to_simplified(transcript)
        print("simplified transcript: ", simplified_transcript)
        punctuated_text = self.generate_punctuation(simplified_transcript)
        print("punctuated text: ", punctuated_text)
        processed_transcript = self.word_segmentation_with_pinyin_and_translation(punctuated_text)
        print("processed_transcript: ", processed_transcript)
        return processed_transcript