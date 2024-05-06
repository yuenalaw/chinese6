import pinyin
import pinyin.cedict
import stanza
from hanziconv import HanziConv
import hanzidentifier
from redis import Redis, ConnectionPool
import requests
from requests.exceptions import HTTPError
from ...shared.config import Config
import json
import dimsim
from ...shared.schema.KeywordSchema import KeywordSchema
from collections import Counter
from textrazor import TextRazor
from pyunsplash import PyUnsplash

# @inproceedings{qi2020stanza,
#     title={Stanza: A {Python} Natural Language Processing Toolkit for Many Human Languages},
#     author={Qi, Peng and Zhang, Yuhao and Zhang, Yuhui and Bolton, Jason and Manning, Christopher D.},
#     booktitle = "Proceedings of the 58th Annual Meeting of the Association for Computational Linguistics: System Demonstrations",
#     year={2020}
# }

pool = ConnectionPool(host='redis', port=6379)
text_razor_client = TextRazor(Config.TEXTRAZOR_API_KEY, extractors=["entities"])

class YouTubeHelper:
    pu = PyUnsplash(api_key=Config.UNSPLASH_ACCESS_KEY)
    
    def __init__(self):
        self.stanza_nlp = None
        self.redis = Redis(connection_pool=pool)  # Connect to your Redis server
        self.text_razor_client = text_razor_client
    
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
            raise

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

    def process_words(self, sentence):
        seg_res = []
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
        return seg_res

    def process_sentence(self, sentence):
        if not self.stanza_nlp:
            self.init_stanza_helper()

        simplified_text = HanziConv.toSimplified(sentence)
        doc = self.stanza_nlp(simplified_text)

        seg_res = self.process_words(doc.sentences[0])

        sentence_obj = {
            "sentence": doc.sentences[0].text,
            "entries": seg_res
        }

        return json.dumps(sentence_obj)
    
    def time_to_seconds(self, time_str):
        # Convert a time string in the format 'HH:MM:SS,MS' to seconds
        h, m, s_ms = time_str.split(':')
        s, ms = s_ms.split(',')
        return int(h) * 3600 + int(m) * 60 + int(s) + int(ms) / 1000

    def convert_transcript_to_format(self, disney_transcript):
        transcript = []
        blocks = disney_transcript.strip().split('\n\n')
        for block in blocks:
            lines = block.split('\n')
            for sentence in lines[2:]:
                if sentence:
                    transcript.append({'text': sentence})
        
        return transcript

    def transcript_processing(self, transcript):
        """
        expecting transcript such as
        1
        00:00:00,083 --> 00:00:03,212
        暑假一百零四天

        2
        00:00:03,337 --> 00:00:05,714
        新學期開始以前

        3
        00:00:05,797 --> 00:00:08,800
        我們可要

        4
        00:00:08,884 --> 00:00:11,929
        好好利用這個假期

        8
        00:00:18,268 --> 00:00:20,646
        去探索那些
        前所未有的新事物

        """
        if not self.stanza_nlp:
            self.init_stanza_helper()
        results = []

        # split transcript into blocks
        blocks = transcript.strip().split('\n\n')
        for block in blocks:
            lines = block.split('\n')

            # time range and text
            start_time, end_time = [self.time_to_seconds(t) for t in lines[1].split(' --> ')]

            for sentence in lines[2:]:
                if sentence: # ignore empty lines
                    sentence_obj_dumps = self.process_sentence(sentence)
                    sentence_obj = json.loads(sentence_obj_dumps)
                    results.append({
                        "segment": sentence_obj['sentence'],
                        "start": round(start_time, 2),
                        "duration": round(end_time - start_time, 2),
                        "sentence_obj": sentence_obj
                    })
            
        return json.dumps(results)

    def video_processing(self, transcript):
        if not self.stanza_nlp:
            self.init_stanza_helper()
        results = []
        for i, segment in enumerate(transcript):
            simplified_text = HanziConv.toSimplified(segment['text'])
            doc = self.stanza_nlp(simplified_text)
            for j, sentence in enumerate(doc.sentences):
                # if sentence.text and not sentence.text.strip().isalnum():
                #     continue #skip those that are just punctuation

                seg_res = self.process_words(sentence)

                sentence_obj = {
                    "sentence": sentence.text,
                    "entries": seg_res
                }
                results.append({
                    "segment": simplified_text,
                    "start": segment['start'],
                    "duration": segment['duration'],
                    "sentences": sentence_obj
                })
        return json.dumps(results)
    
    def get_pinyin(self, word):
        try:
            calc_pinyin = self.redis.get(f'pinyin:{word}')
            if calc_pinyin is not None:
                calc_pinyin = json.loads(calc_pinyin.decode('utf-8'))  # Decode the byte string and load the JSON data
                calc_pinyin = calc_pinyin.replace('"', '')
                return calc_pinyin
            if not hanzidentifier.has_chinese(word):
                return None

            calc_pinyin = pinyin.get(word, format="strip", delimiter=" ")
            if calc_pinyin is None:
                return None

            calc_pinyin = calc_pinyin.replace('"', '')
            calc_pinyin_json = json.dumps(calc_pinyin)
            self.redis.set(f'pinyin:{word}', calc_pinyin_json)
            return calc_pinyin

        except TypeError as e:
            print(f"Serialization error pinyin: {e}")
            return None
        except Exception as e:
            print(f"Unexpected pinyin error: {e}")
            return None

    def get_similarsoundwords(self, word):
        if not word:
            return None

        try:
            cache_similarsounds = self.redis.get(f'similarsound:{word}')
            if cache_similarsounds:
                return json.loads(cache_similarsounds.decode('utf-8'))  # Decode the byte string and load the JSON data

            candidates = list(set(dimsim.get_candidates(word, mode='simplified', theta=1)))  # Use set to remove duplicates
            if not candidates:
                return None

            # Limit the list of candidates to a maximum of 5
            candidates = candidates[:5]

            candidates_json = json.dumps(candidates)
            self.redis.set(f'similarsound:{word}', candidates_json)
            return candidates

        except TypeError as e:
            print(f"Serialization error similar sounds: {e}")
            return None
        except Exception as e:
            print(f"Unexpected similar sounds error: {e}")
            return None
            
    def get_translation(self, word):
        if not word or not hanzidentifier.has_chinese(word):
            return None

        try:
            translation = self.redis.get(f'translation:{word}')
            if translation:
                return json.loads(translation.decode('utf-8'))  # Decode the byte string and load the JSON data

            translation = list(pinyin.cedict.all_phrase_translations(word))
            if not translation:
                return None

            # Convert to list and serialize to JSON
            translation_json = json.dumps(translation)
            self.redis.set(f'translation:{word}', translation_json)
            return translation

        except TypeError as e:
            print(f"Serialization translation error: {e}")
            return None
        except Exception as e:
            print(f"Unexpected translation error: {e}")
            return None

    def process_transcript(self, transcript, isYTVideo=True):
        if isYTVideo:
            processed_transcript = self.video_processing(transcript)
        else:
            processed_transcript = self.transcript_processing(transcript)
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
    
    def get_images(self, keywords):
        keyword_imgs = []
        try:
            for keywordObj in keywords:
                keyword = keywordObj.ChineseWord
                print(f"looking up images for {keyword}\n")
                cached_imgs = self.redis.get(f'images:{keyword}')
                if cached_imgs is None:
                    try:
                        photos = self.pu.photos(type_='random', count=1, featured=True, query="splash")
                        [photo] = photos.entries
                        download_link = photo.link_download
                        self.redis.set(f'images:{keyword}', json.dumps(download_link))
                        cached_imgs = download_link
                    except requests.exceptions.RequestException as e:
                        print(f"PyUnsplash API request failed: {e}")
                        cached_imgs = None
                else:
                    if cached_imgs is not None:
                        cached_imgs = json.loads(cached_imgs)
                keyword_imgs.append({'keyword': keyword, 'img': cached_imgs})
            return json.dumps(keyword_imgs)
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
