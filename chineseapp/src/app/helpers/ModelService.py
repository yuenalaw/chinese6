from src.app.repository.MySqlAlchemyRepo import ModelRepository
from datetime import date

class ModelService:
    model_repository = ModelRepository()

    def video_exists(self, vid_id):
        return self.model_repository.video_details_exists(vid_id)

    def create_video_lesson(self, youtube_id, processed_transcript, keyword_to_images):
        try:
            self.model_repository.add_video_lesson_to_db(youtube_id, processed_transcript, keyword_to_images)
            print(f"Successfully added video to db!")
            return True
        except Exception as e:
            print(f"In model service; error occured in the repo when creating video lesson: {e}")
            return False
    
    def get_video(self, youtube_id):
        try:
            obtained_video = self.model_repository.get_lesson_data(youtube_id)
            print(f"i got... {obtained_video}")
            return obtained_video
        except Exception as e:
            print(f"In model service; error occured getting video lesson: {e}")
            return False

    def add_study_date(self):
        try:
            self.model_repository.add_study_date()
            print(f"Updated study date!")
        except Exception as e:
            print(f"In model service; error occured updating study date: {e}")
            return False

    def get_streak(self):
        try:
            study_streak = self.model_repository.calculate_study_streak()
            print(f"Study streak is {study_streak}!")
            return study_streak
        except Exception as e:
            print(f"In model service; error occured getting streak: {e}")
            return False
    
    def add_review(self, word, pinyin, similar_words, translation, sentence_id, note):
        try:
            self.model_repository.add_word_sentence_review(word, pinyin, similar_words, translation, sentence_id, note)
            print(f"Added review!")
        except Exception as e:
            print(f"In model service; error occured adding review: {e}")
            return False
    
    def update_user_sentence(self, youtube_id, line_changed, new_sentence):
        """
        new sentence has the same json structure as old, going through youtube helper and getting pinyin etc
        """
        try:
            print(f"obtained new sentence is: {new_sentence}")
            self.model_repository.update_user_sentence(youtube_id, line_changed, new_sentence)
            print(f"Updated user sentence")
        except Exception as e:
            print(f"In model service; error occured adding new user sentence: {e}")
            return False
    
    def update_note(self, youtube_id: str, word_id: int, line_changed: int, note: str):
        try:
            self.model_repository.update_note(youtube_id, word_id, line_changed, note)
            print(f"Added/ update note!")
        except Exception as e:
            print(f"In model service; error occured updating note: {e}")
            return False  
    
    def update_user_word_review(self, word_id: int, last_reviewed: date, repetitions: int, ease_factor: float, word_interval: int, next_review: date):
        # talk to the SRS service here to increment repetitions, NEW ease factor, word interval, next review
        pass

    def get_sentence_context(self, youtube_id, line_changed):
        try:
            previous, next = self.model_repository.get_sentence_context(youtube_id, line_changed)
            print(f"previous sentence: {previous}, next: {next}")
            return previous, next
        except Exception as e:
            print(f"In model service; error occured getting context: {e}")
            return False  

    def get_cards_today(self):
        try:
            cards = self.model_repository.get_review_words_today()
            print(f"Cards due today: {cards}")
            return cards
        except Exception as e:
            print(f"In model service; error occured getting cards today: {e}")
            return False  