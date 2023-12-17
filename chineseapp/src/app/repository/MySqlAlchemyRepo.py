from src.app.models.MySqlModel import User, UserStudyDate, Word, UserWordReview, UserWordSentence, UserSentence, VideoDetails
from src.app.database import db
from datetime import datetime, timedelta
from datetime import date
from typing import List, Tuple
from sqlalchemy.exc import IntegrityError
import redis
import json
import random

r = redis.Redis(host='localhost', port=6379)

class ModelRepository:
    def add_user(self, username):
        user = User(username=username)
        db.session.add(user)
        try:
            db.session.commit()
            return user
        except IntegrityError:
            db.session.rollback()
            return User.query.filter_by(username=username).first()
    
    def get_random_sentence(self, user_id: int, word_id: int):
        """
        Fetch a random edited sentence containing a specific word for a specific user.

        Parameters:
        user_id (int): The ID of the user.
        word_id (int): The ID of the word.

        Returns:
        str: The sentence.
        """
        # Fetch all UserWordSentence entries for the given word
        user_word_sentences = UserWordSentence.query.filter_by(user_id=user_id, word_id=word_id).all()

        # If there are no sentences for the word, return None
        if not user_word_sentences:
            return None

        # Choose a random UserWordSentence
        user_word_sentence = random.choice(user_word_sentences)

        # Get the UserSentence entry
        user_sentence = UserSentence.query.filter_by(user_id=user_id, youtube_id=user_word_sentence.youtube_id, line_changed=user_word_sentence.line_changed).first()
        if user_sentence is None:
            return None

        return user_sentence.user_sentence

    def get_review_words_today(self, user_id: int) -> List[Tuple[UserWordReview, Word]]:
        """
        Get words for review for a specific user today.

        Parameters:
        user_id (int): The ID of the user.

        Returns:
        List[Tuple[UserWordReview, Word]]: A list of tuples containing the review and word.
        """
        today = datetime.now().date()

        # Try to get the result from the cache
        key = f"review_words:{user_id}:{today}"
        result = r.get(key)

        if result is not None:
            return json.loads(result)

        try:
            # Query UserWordReview and Word
            query = db.session.query(
                UserWordReview,
                Word
            ).join(
                Word, UserWordReview.word_id == Word.id
            ).filter(
                UserWordReview.user_id == user_id,
                UserWordReview.next_review <= today
            )

            reviews = query.all()

            r.set(key, json.dumps(reviews))

            return reviews
        except Exception as e:
            print(f"An error occurred (getting review words): {e}")
            db.session.rollback()
            return []

    def review_cards_today(self, user_id: int):
        reviews_today = self.get_review_words_today(user_id)
        cards = []
        for review, word in reviews_today:
            sentence = self.get_random_sentence(user_id, word.id)
            cards.append({'word': word, 'sentence': sentence, 'review': review})
        return cards

    def get_sentence_context(self, user_id: int, youtube_id: str, line_changed: int):
        try:
            # Get the VideoDetails entry
            video_details = VideoDetails.query.get(youtube_id)
            if video_details is None:
                print(f"No such video details; cannot get sentence context")
                return None, None

            # Get the sentences
            lesson_data = json.loads(video_details.lesson_data)
            previous_sentence = lesson_data[line_changed - 1] if line_changed > 0 else None
            next_sentence = lesson_data[line_changed + 1] if line_changed < len(lesson_data) - 1 else None

            # Check if user has any edited versions of these
            if previous_sentence:
                user_previous_sentence = UserSentence.query.filter_by(user_id=user_id, youtube_id=youtube_id, line_changed=line_changed - 1).first()
                if user_previous_sentence:
                    previous_sentence = user_previous_sentence.user_sentence

            if next_sentence:
                user_next_sentence = UserSentence.query.filter_by(user_id=user_id, youtube_id=youtube_id, line_changed=line_changed + 1).first()
                if user_next_sentence:
                    next_sentence = user_next_sentence.user_sentence

            return previous_sentence, next_sentence
        except Exception as e:
            print(f"An error occurred while getting sentence context: {e}")
            return None, None


    def update_user_word_review(self, user_id: int, word_id: int, last_reviewed: date, repetitions: int, ease_factor: float, word_interval: int, next_review: date) -> None:
        """
        Update a UserWordReview entry for a specific user and word sentence.

        Parameters:
        user_id (int): The ID of the user.
        word_id (int): The ID of the word.
        last_reviewed (date): The date when the word was last reviewed.
        repetitions (int): The number of repetitions for the word.
        ease_factor (float): The ease factor for the word.
        word_interval (int): The interval for the word.
        next_review (date): The date for the next review of the word.
        """
        try:
            # Get the UserWordReview entry
            review = db.session.query(UserWordReview).filter_by(user_id=user_id, word_id=word_id).first()
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

            print(f"Updated UserWordReview for user_id {user_id} and word_id {word_id}")
        except Exception as e:
            print(f"An error occurred (updating UserWordReview): {e}")
            db.session.rollback()

    def update_note(self, user_id: int, youtube_id: str, word_id: int, line_changed: int, note: str) -> None:
        """
        Update the note for a specific user and word sentence.

        Parameters:
        user_id (int): The ID of the user.
        youtube_id (str): The ID of the video.
        word_id (str): The ID of the word.
        line_changed (int): The index of the sentence in the lesson_data.
        note (str): The new note.
        """
        try:
            # Get the UserWordSentence entry
            user_word_sentence = db.session.query(UserWordSentence).filter_by(user_id=user_id, youtube_id=youtube_id, word_id=word_id, line_changed=line_changed).first()
            if user_word_sentence is None:
                print(f"No such user word sentence; cannot update note")
                return None
            # Update the note
            user_word_sentence.note = note

            # Commit the changes
            db.session.commit()

            print(f"Updated UserWordSentence for user_id {user_id}, youtube_id {youtube_id}, line_changed {line_changed}, and word_id {word_id}")
        except Exception as e:
            print(f"An error occurred (updating UserWordSentence): {e}")
            db.session.rollback()

    def update_user_sentence(self, user_id: int, youtube_id: str, line_changed: int, user_sentence: json) -> None:
        """
        Update the user_sentence for a specific user and sentence.

        Parameters:
        user_id (int): The ID of the user.
        youtube_id (str): The ID of the video.
        line_changed (int): The index of the sentence in the lesson_data.
        user_sentence (str): The new user sentence.
        """
        try:
            # Get the UserSentence entry
            user_sentence_entry = db.session.query(UserSentence).filter_by(user_id=user_id, youtube_id=youtube_id, line_changed=line_changed).first()
            if user_sentence_entry is None:
                print(f"No such user sentence; cannot update user sentence")
                return None
            # Update the user_sentence
            user_sentence_entry.user_sentence = user_sentence

            # Commit the changes
            db.session.commit()

            print(f"Updated UserSentence for user_id {user_id}, youtube_id {youtube_id}, and line_changed {line_changed}")
        except Exception as e:
            print(f"An error occurred (updating UserSentence): {e}")
            db.session.rollback()
    
    def get_lesson_data(self, youtube_id, user_id):
        video_details = VideoDetails.query.get(youtube_id)
        user_sentences = UserSentence.query.filter_by(youtube_id=youtube_id, user_id=user_id).all()

        # Convert the list of UserSentence objects to a dictionary for easier lookup
        user_sentences_dict = {us.line_changed: us for us in user_sentences}

        lesson_data = []
        """video details.lesson data looks something like
        [{'segment': '加州留学生的生活', 'start': 10.708, 'duration': 1.291, 
        'sentences': [{'sentence': '加州留学生的生活', 'entries': [{'word': '加州', 'upos': 'PROPN', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '留学', 'upos': 'VERB', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '生', 'upos': 'PART', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '的', 'upos': 'PART', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '生活', 'upos': 'NOUN', 'pinyin': None, 'translation': None, 'similarsounds': None}]}]},
        """
        lesson_data_json = json.loads(video_details.lesson_data)
        for index, segment in enumerate(lesson_data_json):
            if index in user_sentences_dict:
                user_sentence = user_sentences_dict[index].user_sentence
                lesson_data.append({'segment': segment, 'user_sentence': user_sentence})
            else:
                lesson_data.append({'segment': segment})

        return lesson_data

    def add_video_lesson_to_db(self, youtube_id, processed_transcript, keyword_to_images):
        
        print(f"On db side... Adding video to lesson. Youtube id: {youtube_id}\n transcript: {processed_transcript}\n keyword_to_images: {keyword_to_images}")

        try:
            # Create a new VideoDetails instance,
            video_details = VideoDetails(
                id=youtube_id,
                lesson_data=json.dumps(processed_transcript),  # Convert the list to a JSON string
                lesson_keyword_imgs=json.dumps(keyword_to_images)  # Convert the dictionary to a JSON string
            )

            # Add the new VideoDetails instance to the session
            db.session.add(video_details)

            # Commit the session to save the changes
            db.session.commit()
            print(f"Added VideoDetails for youtube_id {youtube_id}")
        except Exception as e:
            print(f"An error occurred while adding VideoDetails: {e}")
            db.session.rollback()

    def add_word(self, word, pinyin, similar_words, translation):
        try:
            existing_word = db.session.query(Word).filter(Word.word == word).first()

            if existing_word is None:
                new_word = Word(word=word, pinyin=pinyin, similar_words=similar_words, translation=translation)
                db.session.add(new_word)
                db.session.commit()
                return new_word.id

            return existing_word.id
        except Exception as e:
            print(f"An error occurred (add word): {e}")
            db.session.rollback()

    def add_review_records(self, user_id, word_id, youtube_id, line_changed, note) -> None:
        # start a new transaction
        try:
            with db.session.begin():
                # Check if UserWordSentence already exists
                existing_user_word_sentence = UserWordSentence.query.filter_by(
                    user_id=user_id,
                    word_id=word_id,
                    youtube_id=youtube_id,
                    line_changed=line_changed
                ).first()

                if existing_user_word_sentence is None:
                    # Create a new UserWordSentence
                    new_user_word_sentence = UserWordSentence(
                        user_id=user_id,
                        word_id=word_id,
                        youtube_id=youtube_id,
                        line_changed=line_changed,
                        note=note
                    )
                    db.session.add(new_user_word_sentence)
                else:
                    new_user_word_sentence = existing_user_word_sentence

                # Create a new UserWordReview with default values
                new_user_word_review = UserWordReview(
                    user_id=user_id,
                    word_id=word_id,  # Assuming UserWordReview has a word_id field
                    last_reviewed=datetime.now().date(),
                    repetitions=0,
                    ease_factor=2.5,  # default ease factor for SuperMemo2 algorithm
                    word_interval=1,
                    next_review=datetime.now().date()  # Review word tomorrow
                )
                db.session.add(new_user_word_review)

            # commit transaction
            db.session.commit()
        except Exception as e:
            print(f"An error occurred (add review records): {e}")
            db.session.rollback()
    
    def add_word_sentence_review(self, word, pinyin, similar_words, translation, sentence_id, user_id, note):
        try:
            # Add word
            word_id = self.add_word(word, pinyin, similar_words, translation)

            # Add review records
            self.add_review_records(user_id, word_id, sentence_id, note)

            return True
        except Exception as e:
            print(f"An error occurred (add word, sentence, and review records): {e}")
            db.session.rollback()
            return False

    def add_study_date(self, user_id: int, study_date: date = datetime.now().date()):
        """
        Add a study date for a specific user.

        Parameters:
        user_id (int): The ID of the user.
        study_date (date, optional): The study date. Defaults to today's date.
        """
        try:
            new_study_date = UserStudyDate(user_id=user_id, study_date=study_date)
            db.session.add(new_study_date)
            db.session.commit()
        except Exception as e:
            print(f"An error occurred (add study date): {e}")
            db.session.rollback()

    def calculate_study_streak(self, user_id: int) -> int:
        """
        Calculate the study streak for a specific user.

        Parameters:
        user_id (int): The ID of the user.

        Returns:
        int: The study streak of the user.
        """
        try:
            # Get the most recent study date
            most_recent_study_date = db.session.query(UserStudyDate.study_date).filter(UserStudyDate.user_id == user_id).order_by(UserStudyDate.study_date.desc()).first()

            if most_recent_study_date is None:
                return 0

            # Calculate the date one day before the most recent study date
            previous_day = most_recent_study_date.study_date - timedelta(days=1)

            # Get the study date for the previous day
            previous_study_date = db.session.query(UserStudyDate.study_date).filter(UserStudyDate.user_id == user_id, UserStudyDate.study_date == previous_day).first()

            streak = 1

            # Continue to fetch and check study dates until a gap is found
            while previous_study_date is not None:
                streak += 1
                previous_day -= timedelta(days=1)
                previous_study_date = db.session.query(UserStudyDate.study_date).filter(UserStudyDate.user_id == user_id, UserStudyDate.study_date == previous_day).first()

            return streak
        except Exception as e:
            print(f"An error occurred (calculate study streak): {e}")
            return 0

