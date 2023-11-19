import pinyin
import pinyin.cedict
import stanza
from stanza.pipeline.core import DownloadMethod
from hanziconv import HanziConv
import hanzidentifier
import threading

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

    def init_helper(self):
        with self._init_lock:
            if self.stanza_nlp is None:
                try:
                    self.stanza_nlp = stanza.Pipeline('zh', download_method=DownloadMethod.REUSE_RESOURCES, use_gpu=False, verbose=False)
                except Exception as e:
                    print("Error initializing stanza pipeline:", str(e))

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
        try:
            doc = self.stanza_nlp(concatenated_text)
            # for each sentence in the doc, obtain the words
            sentence_and_words = []
            for sentence in doc.sentences:
                seg_res = []
                for word in sentence.words:
                    word_text = word.text.strip()
                    calculated_pinyin = self.pinyin_cache.get(word_text)
                    if not calculated_pinyin:
                        calculated_pinyin[word_text] = self.get_pinyin(word_text)
                    calculated_translation = self.translation_cache.get(word_text)
                    if not calculated_translation:
                        calculated_translation[word_text] = self.get_translation(word_text)
                    entry = {
                    "word": word_text,
                    "word_lemma": word.lemma.strip(),
                    "word_pos": word.pos.strip(), #IS PROPN/ NOUN/ AUX etc
                    "pinyin": calculated_pinyin,
                    "translation": calculated_translation
                    }
                    seg_res.append(entry)
                sentence_and_words.append(seg_res)
            print("finished word segmenting...")
            return sentence_and_words
        except Exception as e:
            print("Error with stanza: " + str(e))
            return {"error": str(e)}

    def process_transcript(self, transcript):
        simplified_transcript = self.turn_to_simplified(transcript)
        print("simplified transcript: ", simplified_transcript)
        processed_transcript = self.word_segmentation_with_pinyin_and_translation(simplified_transcript)
        print("processed_transcript: ", processed_transcript)
        return processed_transcript