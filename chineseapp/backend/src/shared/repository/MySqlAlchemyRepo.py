from ..model.models import db, UserStudyDate, Word, UserWordReview, UserWordSentence, UserSentence, VideoDetails
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
from datetime import date
from typing import List, Tuple
import json
import random

class ModelRepository:
    
    def get_random_sentence(self, word_id: int):
        """
        Fetch a random edited sentence containing a specific word.

        Parameters:
        word_id (int): The ID of the word.

        Returns:
        tuple: The sentence and its note
        """
        try:
            # Fetch all UserWordSentence entries for the given word
            user_word_sentences = UserWordSentence.query.filter_by(word_id=word_id).all()

            # If there are no sentences for the word, return None
            if not user_word_sentences:
                print(f"no sentence exists for this word!")
                return None, None, None

            # Choose a random UserWordSentence
            user_word_sentence = random.choice(user_word_sentences)

            # Get the UserSentence entry
            user_sentence = UserSentence.query.filter_by(video_id=user_word_sentence.video_id, line_changed=user_word_sentence.line_changed).first()
            if user_sentence is not None:
                return user_sentence.user_sentence, user_word_sentence.note, user_word_sentence.line_changed, user_word_sentence.image_path

            return user_word_sentence.sentence, user_word_sentence.note, user_word_sentence.line_changed, user_word_sentence.image_path
        except Exception as e:
            print(f"An error occurred getting random sentence: {e}")
            raise

    def get_review_words_today(self) -> List[Tuple[UserWordReview, Word]]:
        """
        Get words for review for today

        Returns:
        List[Tuple[UserWordReview, Word]]: A list of tuples containing the review and word.
        """
        today = datetime.now().date()

        try:
            # Query UserWordReview and Word
            query = db.session.query(
                UserWordReview,
                Word
            ).join(
                Word, UserWordReview.word_id == Word.id
            ).filter(
                UserWordReview.next_review <= today
            )

            reviews = query.all()

            return reviews
        except Exception as e:
            print(f"An error occurred (getting review words): {e}")
            db.session.rollback()
            raise

    def review_cards_today(self):
        try:
            reviews_today = self.get_review_words_today()
            cards = []
            for review, word in reviews_today:
                sentence, note, line_changed, image_path = self.get_random_sentence( word.id)
                cards.append({'word': word.to_dict(), 'sentence': sentence, 'note': note, 'line_changed':line_changed, 'review': review.to_dict(), 'image_path':image_path})
            return cards
        except Exception as e:
            print(f"An error occurred calling get review words today: {e}")
            raise

    def get_sentence_context(self, video_id: str, line_changed: int):
        try:
            # Get the VideoDetails entry
            video_details = VideoDetails.query.get(video_id)
            if video_details is None:
                print(f"No such video details; cannot get sentence context")
                return None, None

            # ensure line changed is int
            line_changed = int(line_changed)

            # Get the sentences
            lesson_data = json.loads(video_details.lesson_data)
            previous_sentence = lesson_data[line_changed - 1] if line_changed > 0 else None
            next_sentence = lesson_data[line_changed + 1] if line_changed < len(lesson_data) - 1 else None

            # Check if user has any edited versions of these
            if previous_sentence:
                user_previous_sentence = UserSentence.query.filter_by(video_id=video_id, line_changed=line_changed - 1).first()
                if user_previous_sentence:
                    previous_sentence = user_previous_sentence.user_sentence

            if next_sentence:
                user_next_sentence = UserSentence.query.filter_by(video_id=video_id, line_changed=line_changed + 1).first()
                if user_next_sentence:
                    next_sentence = user_next_sentence.user_sentence

            return previous_sentence, next_sentence
        except Exception as e:
            print(f"An error occurred while getting sentence context: {e}")
            raise
    
    def get_user_word_review(self, word, video_id: str, line_changed: int):
        try:
            # Get the Word entry
            word = Word.query.filter_by(word=word).first()
            if word is None:
                print(f"No such word; cannot get user word review")
                return None
            # Get the UserWordSentence entry
            user_word_sentence = UserWordSentence.query.filter_by(word_id=word.id, video_id=video_id, line_changed=line_changed).first()
            if user_word_sentence is None:
                print(f"No such user word sentence; cannot get user word review")
                return None

            # Get the UserWordReview entry
            user_word_review = UserWordReview.query.filter_by(user_word_sentence_id=user_word_sentence.id).first()
            if user_word_review is None:
                print(f"No such user word review; cannot get user word review")
                return None

            return {"user_word_review": user_word_review.to_dict(), "word_id": word.id}
        except Exception as e:
            print(f"An error occurred while getting user word review: {e}")
            raise
        
    def update_user_word_review(self, word_id: int, last_reviewed: date, repetitions: int, ease_factor: float, word_interval: int, next_review: date) -> None:
        """
        Update a UserWordReview entry for a word sentence.

        Parameters:
        word_id (int): The ID of the word.
        last_reviewed (date): The date when the word was last reviewed.
        repetitions (int): The number of repetitions for the word.
        ease_factor (float): The ease factor for the word.
        word_interval (int): The interval for the word.
        next_review (date): The date for the next review of the word.
        """
        try:
            print(f"word id is {word_id}, last reviewed is {last_reviewed}, repetitions is {repetitions}, ease factor is {ease_factor}, interval is {word_interval} and next review date is {next_review}")
            # Get the UserWordReview entry
            review = db.session.query(UserWordReview).filter_by(word_id=word_id).first()
            if review is None:
                print(f"No such review found in db")
                return None
            # Update the fields
            review.last_reviewed = last_reviewed
            review.repetitions = repetitions
            review.ease_factor = ease_factor
            review.word_interval = word_interval
            review.next_review = next_review

            # Commit the changes
            db.session.commit()

            print(f"Updated UserWordReview for word_id {word_id} with new repetition: {repetitions}, ease factor: {ease_factor}, interval: {word_interval}, next review date is {next_review}")
        except Exception as e:
            print(f"An error occurred (updating UserWordReview): {e}")
            db.session.rollback()
            raise
    
    def get_user_word_sentence(self, word, video_id: str, line_changed: int):
        try:
            # Get the Word entry
            word = Word.query.filter_by(word=word).first()
            if word is None:
                print(f"No such word; cannot get user word review")
                return None
            # Get the UserWordSentence entry
            user_word_sentence = UserWordSentence.query.filter_by(word_id=word.id, video_id=video_id, line_changed=line_changed).first()
            if user_word_sentence is None:
                print(f"No such user word sentence; cannot get user word review")
                return None
            
            return {"word_id": word.id, "user_word_sentence": user_word_sentence.to_dict()}
        except Exception as e:
            print(f"An error occurred while getting user word sentence: {e}")
            raise
    
    def get_updated_user_sentence(self, video_id: str, line_changed: int):
        try:
            user_sentence = UserSentence.query.filter_by(video_id=video_id, line_changed=line_changed).first()
            if user_sentence:
                return {"sentence": user_sentence.user_sentence['sentence'], "entries": user_sentence.user_sentence['entries']}
            else:
                return None
        except Exception as e:
            print(f"An error occurred while getting user sentence: {e}")
            raise

    def update_note(self, video_id: str, word_id: int, line_changed: int, note: str) -> None:
        """
        Update the note for a specific user and word sentence.

        Parameters:
        video_id (str): The ID of the video.
        word_id (str): The ID of the word.
        line_changed (int): The index of the sentence in the lesson_data.
        note (str): The new note.
        """
        try:
            # ensure line changed is int
            line_changed = int(line_changed)
            # Get the UserWordSentence entry
            user_word_sentence = db.session.query(UserWordSentence).filter_by(video_id=video_id, word_id=word_id, line_changed=line_changed).first()
            if user_word_sentence is None:
                print(f"No such user word sentence; cannot update note")
                return None
            # Update the note
            user_word_sentence.note = note

            # Commit the changes
            db.session.commit()

            print(f"Updated UserWordSentence for video_id {video_id}, line_changed {line_changed}, and word_id {word_id}")
        except Exception as e:
            print(f"An error occurred (updating UserWordSentence): {e}")
            db.session.rollback()
            raise
    
    def update_video_title(self, video_id, title):
        try:
            # Get the VideoDetails entry
            video_details = VideoDetails.query.get(video_id)
            if video_details is None:
                print(f"No such video details; cannot update title")
                return None
            # Update the title
            video_details.title = title

            # Commit the changes
            db.session.commit()

            print(f"Updated VideoDetails for video_id {video_id}")
        except Exception as e:
            print(f"An error occurred (updating VideoDetails title): {e}")
            db.session.rollback()
            raise

    def update_image_path(self, video_id: str, word_id: int, line_changed: int, image_path: str) -> None:
        """
        Update the image path for a specific user and word sentence.

        Parameters:
        video_id (str): The ID of the video.
        word_id (str): The ID of the word.
        line_changed (int): The index of the sentence in the lesson_data.
        image path (str): The new image path.
        """
        try:
            # ensure line changed is int
            line_changed = int(line_changed)
            # Get the UserWordSentence entry
            user_word_sentence = db.session.query(UserWordSentence).filter_by(video_id=video_id, word_id=word_id, line_changed=line_changed).first()
            if user_word_sentence is None:
                print(f"No such user word sentence; cannot update note")
                return None
            # Update the note
            user_word_sentence.image_path = image_path

            # Commit the changes
            db.session.commit()

            print(f"Updated UserWordSentence for video_id {video_id}, line_changed {line_changed}, and word_id {word_id}")
        except Exception as e:
            print(f"An error occurred (updating UserWordSentence): {e}")
            db.session.rollback()
            raise
    
    def video_details_exists(self, id):
        return db.session.query(VideoDetails.id).filter_by(id=id).scalar() is not None
    
    def get_library(self):
        try:
            videos = VideoDetails.query.all()
            library = [video.to_dict() for video in videos]
            return library
        except Exception as e:
            print(f"An error occurred while getting library: {e}")
            raise
    
    def get_lesson_data(self, video_id):
        try:
            video_details = VideoDetails.query.get(video_id)
            user_sentences = UserSentence.query.filter_by(video_id=video_id).all()

            # Convert the list of UserSentence objects to a dictionary for easier lookup
            user_sentences_dict = {us.line_changed: us for us in user_sentences}

            lesson_data = []
            lesson_data_json = json.loads(video_details.lesson_data)
            for index, segment in enumerate(lesson_data_json):
                if index in user_sentences_dict:
                    user_sentence = user_sentences_dict[index].user_sentence
                    lesson_data.append({'segment': segment, 'user_sentence': user_sentence})
                else:
                    lesson_data.append({'segment': segment})
            
            reformat_keywords_imgs = json.loads(video_details.lesson_keyword_imgs)

            return {"video_id": video_id, "source": video_details.source, "title": video_details.title, "channel": video_details.channel, "thumbnail": video_details.thumbnail, "keywords_img": reformat_keywords_imgs, "lessons": lesson_data}
        except Exception as e:
            print(f"An error occurred while getting lesson data: {e}")
            raise
    

    
    def delete_video_lesson_from_db(self, video_id):
        try:
            if (self.video_details_exists(video_id)):
                video_details = VideoDetails.query.get(video_id)
                db.session.delete(video_details)
                db.session.commit()
                print(f"Deleted VideoDetails for video_id {video_id}")
        except Exception as e:
            print(f"An error occurred while deleting VideoDetails: {e}")
            db.session.rollback()
            raise
    
    def get_word(self, word):
        try:
            word = Word.query.filter_by(word=word).first()
            if word is None:
                print(f"No such word; cannot get word")
                return None
            return word.to_dict()
        except Exception as e:
            print(f"An error occurred while getting word: {e}")
            raise

    def add_word(self, word, pinyin, similar_words, translation):
        try:
            existing_word = db.session.query(Word).filter(Word.word == word).first()

            if existing_word is None:
                new_word = Word(word=word, pinyin=pinyin, similar_words=similar_words, translation=translation)
                db.session.add(new_word)
                db.session.commit()

                print(f"word id is {new_word.id}")
                return new_word.id
            
            print(f"word id is {existing_word.id}")
            return existing_word.id
        except Exception as e:
            print(f"An error occurred (add word): {e}")
            db.session.rollback()
            raise

    def add_review_records(self, word_id, video_id, line_changed, sentence, note, image_path) -> None:
        # start a new transaction
        try:
            # ensure line changed is int
            line_changed = int(line_changed)
            # Check if UserWordSentence already exists
            existing_user_word_sentence = UserWordSentence.query.filter_by(
                word_id=word_id,
                video_id=video_id,
                line_changed=line_changed
            ).first()

            if existing_user_word_sentence is None:
                # Create a new UserWordSentence
                new_user_word_sentence = UserWordSentence(
                    word_id=word_id,
                    video_id=video_id,
                    line_changed=line_changed,
                    sentence=sentence,
                    note=note,
                    image_path=image_path
                )
                db.session.add(new_user_word_sentence)
                db.session.commit()
            else:
                new_user_word_sentence = existing_user_word_sentence

            # Create a new UserWordReview with default values
            new_user_word_review = UserWordReview(
                word_id=word_id,  # Assuming UserWordReview has a word_id field
                user_word_sentence_id=new_user_word_sentence.id,
                last_reviewed=datetime.now().date(),
                repetitions=0, # default repetitions if new
                ease_factor=2.5,  # default ease factor for SuperMemo2 algorithm
                word_interval=1,
                next_review=datetime.now().date()  # Review word tomorrow
            )
            db.session.add(new_user_word_review)
            db.session.commit()

        except Exception as e:
            print(f"An error occurred (add review records): {e}")
            db.session.rollback()
            raise

    def add_word_sentence_review(self, word, pinyin, similar_words, translation, video_id, line_changed, sentence, note, image_path):
        try:
            # Add word
            word_id = self.add_word(word, pinyin, similar_words, translation)
            # Add review records
            self.add_review_records(word_id, video_id, line_changed, sentence, note, image_path)

            return True
        except Exception as e:
            print(f"An error occurred (add word, youtubeid, and review records): {e}")
            raise

    def add_study_date(self, date):
        """
        Parameters:
        study_date (date, optional): The study date. Defaults to today's date.
        """
        if date is None:
            date = datetime.now(ZoneInfo("Europe/London")).date()
        try:
            # Check if a study date for the current day already exists
            existing_study_date = db.session.query(UserStudyDate).filter(UserStudyDate.study_date == date).first()

            # If a study date for the current day does not exist, insert a new one
            if existing_study_date is None:
                new_study_date = UserStudyDate(study_date=date)
                db.session.add(new_study_date)
                db.session.commit()
            else:
                print("A study date for the current day already exists.")
        except Exception as e:
            print(f"An error occurred (add study date): {e}")
            db.session.rollback()
            raise

    def calculate_study_streak(self) -> int:
        """
        Calculate the study streak.

        Returns:
        int: The study streak of the user.
        """
        try:
            # Get all the unique study dates
            study_dates = db.session.query(UserStudyDate.study_date).order_by(UserStudyDate.study_date.desc()).distinct().all()

            print(study_dates)

            if len(study_dates) == 0:
                return 0

            # Convert the study dates to a set for fast lookup
            study_dates_set = set(study_date.study_date for study_date in study_dates)

            print("set: ", study_dates_set)

            streak = 0
            current_day = datetime.now(ZoneInfo("Europe/London")).date()

            # Continue to check study dates until a gap is found
            while current_day in study_dates_set:

                streak += 1
                current_day -= timedelta(days=1)
                print("current_day: ", current_day)
                print("streak: ", streak)

            return streak
        except Exception as e:
            print(f"An error occurred (calculate study streak): {e}")
            raise