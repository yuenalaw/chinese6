from ..repository.MySqlAlchemyRepo import ModelRepository
from ..helper.SRSHelper import SRSHelper
from datetime import date, timedelta

class ModelService:
    model_repository = ModelRepository()
    SRS_helper = SRSHelper()

    def video_exists(self, vid_id):
        return self.model_repository.video_details_exists(vid_id)

    def get_video(self, id):
        try:
            obtained_video = self.model_repository.get_lesson_data(id)
            return obtained_video
        except Exception as e:
            print(f"In model service; error occured getting video lesson: {e}")
            raise

    def add_study_date(self):
        try:
            self.model_repository.add_study_date()
            print(f"Updated study date!")
        except Exception as e:
            print(f"In model service; error occured updating study date: {e}")
            raise

    def get_streak(self):
        try:
            study_streak = self.model_repository.calculate_study_streak()
            print(f"Study streak is {study_streak}!")
            return study_streak
        except Exception as e:
            print(f"In model service; error occured getting streak: {e}")
            raise
    
    def get_review(self, word, video_id, line_changed):
        try:
            review = self.model_repository.get_user_word_review(word, video_id, line_changed)
            return review
        except Exception as e:
            print(f"In model service; error occured getting review: {e}")
            raise
    
    def get_library(self):
        try:
            library = self.model_repository.get_library()
            return library
        except Exception as e:
            print(f"In model service; error occured getting library: {e}")
            raise
    
    def add_review(self, word, pinyin, similar_words, translation, video_id, line_changed, sentence, note, image_path):
        try:
            self.model_repository.add_word_sentence_review(word, pinyin, similar_words, translation, video_id, line_changed, sentence, note, image_path)
            print(f"Added review!")
        except Exception as e:
            print(f"In model service; error occured adding review: {e}")
            raise
    
    def add_word(self, word, pinyin, similar_words, translation):
        try:
            self.model_repository.add_word(word, pinyin, similar_words, translation)
            print(f"Added word!")
        except Exception as e:
            print(f"In model service; error occured adding word: {e}")
            raise
    
    def get_word_sentence(self, word, video_id, line_changed):
        try:
            word_sentence = self.model_repository.get_user_word_sentence(word, video_id, line_changed)
            print(f"Word sentence is {word_sentence}!")
            return word_sentence
        except Exception as e:
            print(f"In model service; error occured getting word sentence: {e}")
            raise

    def update_note(self, video_id: str, word_id: int, line_changed: int, note: str):
        try:
            self.model_repository.update_note(video_id, word_id, line_changed, note)
            print(f"Added/ update note!")
        except Exception as e:
            print(f"In model service; error occured updating note: {e}")
            raise 
    
    def update_video_title(self, video_id, title):
        try:
            self.model_repository.update_video_title(video_id, title)
            print(f"Updated video title!")
        except Exception as e:
            print(f"In model service; error occured updating video title: {e}")
            raise

    def update_image_path(self, video_id: str, word_id: int, line_changed: int, image_path: str):
        try:
            self.model_repository.update_image_path(video_id, word_id, line_changed, image_path)
            print(f"Added/ update image path!")
        except Exception as e:
            print(f"In model service; error occured updating note: {e}")
            raise 
    
    def update_user_word_review(self, word_id: int, last_repetitions: int, last_ease_factor: float, word_interval: int, quality: int):
        # talk to the SRS service here to increment repetitions, NEW ease factor, word interval, next review
        last_reviewed = date.today()
        interval, repetitions, ease_factor = self.SRS_helper.sm2(last_repetitions, last_ease_factor, word_interval, quality)
        next_review = last_reviewed + timedelta(days=interval)
        try:
            self.model_repository.update_user_word_review(word_id, last_reviewed, repetitions, ease_factor, interval, next_review)
            print(f"Updated user word review!")
        except Exception as e:
            print(f"In model service; error occured updating user word review: {e}")
            raise

    def get_sentence_context(self, video_id, line_changed):
        try:
            previous, next = self.model_repository.get_sentence_context(video_id, line_changed)
            print(f"previous sentence: {previous}, next: {next}")
            return previous, next
        except Exception as e:
            print(f"In model service; error occured getting context: {e}")
            raise

    def get_cards_today(self):
        try:
            cards = self.model_repository.review_cards_today()
            print(f"Cards due today: {cards}")
            return cards
        except Exception as e:
            print(f"In model service; error occured getting cards today: {e}")
            raise