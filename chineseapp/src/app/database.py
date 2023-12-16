from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
from datetime import date
from sqlalchemy import and_, or_
from sqlalchemy import Column, Integer, Float, Date, Text, String, ForeignKey
from sqlalchemy.orm import relationship, aliased, joinedload
from sqlalchemy.dialects.mysql import JSON
from typing import List, Tuple, Union
import redis
import json
import random

r = redis.Redis(host='localhost', port=6379)
db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True)
    username = Column(String(255), unique=True, nullable=False)
    study_dates = relationship('UserStudyDate', backref='associated_user')
    reviews = relationship('UserWordReview', backref='reviewing_user')
    studied_sentences = relationship('UserWordSentence', backref='studying_user')
    edited_sentences = relationship('UserSentence', backref='editing_user')

class UserStudyDate(db.Model):
    __tablename__ = 'user_study_date'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    study_date = Column(Date)

class Word(db.Model): # word is kept as a table, as it allows for one word to be mapped to many sentences
    __tablename__ = 'word'

    id = Column(Integer, primary_key=True)
    word = Column(String(255), nullable=False)
    pinyin = Column(String(255))
    similar_words = Column(JSON)
    images = Column(JSON)
    translation = Column(JSON)

class Sentence(db.Model):
    __tablename__ = 'sentence'

    id = Column(String(255), primary_key=True), # id={youtube_id}_{line_num}
    sentence = Column(Text, nullable=False)
    youtube_id = Column(String(255))
    line_num = Column(Integer)
    youtube_seconds = Column(Float)
    youtube_creator = Column(String(255))
    video_title = Column(String(255))
    user_sentences = relationship('UserSentence', backref='original_sentence')

class UserWordReview(db.Model):
    __tablename__ = 'user_word_review'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    word_id = Column(Integer, ForeignKey('word.id'))
    last_reviewed = Column(Date)
    repetitions = Column(Integer)
    ease_factor = Column(Float)
    word_interval = Column(Integer)
    next_review = Column(Date)

class UserWordSentence(db.Model):
    __tablename__ = 'user_word_sentence'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    word_id = Column(Integer, ForeignKey('word.id'))  # reference Word directly
    sentence_id = Column(String(255), ForeignKey('sentence.id'))  # reference Sentence directly
    note = Column(Text) # adding note here, as users can write notes about a certain word in a certain sentence. Means users draw more linkages rather than just one note per word, everywhere.
    review = db.relationship('UserWordReview', backref='reviewed_sentence', uselist=False) # one to one relationship

class UserSentence(db.Model):
    __tablename__ = 'user_sentence'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    sentence_id = Column(String(255), ForeignKey('sentence.id'))
    edited_sentence = Column(Text)

def get_random_sentence_with_edits(user_id: int, word_id: int):
    """
    Fetch a random sentence containing a specific word for a specific user.
    If the user has edited the sentence, the edited version is used.

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

    # Check if the user has an edited version of the sentence
    user_sentence = UserSentence.query.filter_by(user_id=user_id, sentence_id=sentence.id).first()
    if user_sentence:
        return user_sentence.edited_sentence
    else:
        # Fetch the corresponding Sentence
        sentence = Sentence.query.get(user_word_sentence.sentence_id)
        return sentence.sentence

def get_review_words_today(user_id: int) -> List[Tuple[UserWordReview, Word]]:
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

def review_cards_today(user_id: int):
    reviews_today = get_review_words_today(user_id)
    cards = []
    for review, word in reviews_today:
        sentence = get_random_sentence_with_edits(user_id, word.id)
        cards.append({'word': word, 'sentence': sentence, 'review': review})
    return cards

def get_sentence_context(user_id: int, sentence_id: str):
    try:
        youtube_id, line_num = sentence_id.split('_')
        line_num = int(line_num)

        previous_sentence = Sentence.query.filter(Sentence.youtube_id == youtube_id, Sentence.line_num == line_num-1).first()
        next_sentence = Sentence.query.filter(Sentence.youtube_id == youtube_id, Sentence.line_num == line_num+1).first()

        # check if user has any edited versions of these
        if previous_sentence:
            user_previous_sentence = UserSentence.query.filter_by(user_id=user_id, sentence_id=previous_sentence.id).first()
            if user_previous_sentence:
                previous_sentence.sentence = user_previous_sentence.edited_sentence
        
        if next_sentence:
            user_next_sentence = UserSentence.query.filter_by(user_id=user_id, sentence_id=next_sentence.id).first()
            if user_next_sentence:
                next_sentence.sentence = user_next_sentence.edited_sentence
        
        return previous_sentence, next_sentence
    except Exception as e:
        print(f"An error occurred while getting sentence context: {e}")
        return None, None

def get_sentences_for_youtube_id(youtube_id: str, user_id: int) -> Union[List[Sentence], None]:
    try:
        # Fetch all sentences for the given YouTube ID
        sentences = Sentence.query.filter_by(youtube_id=youtube_id).options(joinedload('user_sentences')).order_by(Sentence.line_num).all()

        # Replace sentences with UserSentence if it exists for the user
        for sentence in sentences:
            user_sentence = next((us for us in sentence.user_sentences if us.user_id == user_id), None)
            if user_sentence:
                sentence.sentence = user_sentence.edited_sentence

        return sentences
    except Exception as e:
        print(f"An error occurred while fetching sentences for youtube id: {e}")
        return None

def update_user_word_review(user_id: int, word_id: int, last_reviewed: date, repetitions: int, ease_factor: float, word_interval: int, next_review: date) -> None:
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

def update_user_word_sentence(user_id: int, word_sentence_id: int, note: str) -> None:
    """
    Update the note for a specific user and word sentence.

    Parameters:
    user_id (int): The ID of the user.
    word_sentence_id (int): The ID of the word sentence.
    note (str): The new note.
    """
    try:
        # Get the UserWordSentence entry
        user_word_sentence = db.session.query(UserWordSentence).filter_by(user_id=user_id, word_sentence_id=word_sentence_id).first()
        if user_word_sentence is None:
            print(f"No such user word sentence; cannot update note")
            return None
        # Update the note
        user_word_sentence.note = note

        # Commit the changes
        db.session.commit()

        print(f"Updated UserWordSentence for user_id {user_id} and word_sentence_id {word_sentence_id}")
    except Exception as e:
        print(f"An error occurred (updating UserWordSentence): {e}")
        db.session.rollback()

def update_user_sentence(user_id: int, sentence_id: str, edited_sentence: str) -> None:
    """
    Update the edited_sentence for a specific user and sentence.

    Parameters:
    user_id (int): The ID of the user.
    sentence_id (str): The ID of the sentence.
    edited_sentence (str): The new edited sentence.
    """
    try:
        # Get the UserSentence entry
        user_sentence = db.session.query(UserSentence).filter_by(user_id=user_id, sentence_id=sentence_id).first()
        if user_sentence is None:
            print(f"No such user sentence; cannot update edited sentence")
            return None
        # Update the edited_sentence
        user_sentence.edited_sentence = edited_sentence

        # Commit the changes
        db.session.commit()

        print(f"Updated UserSentence for user_id {user_id} and sentence_id {sentence_id}")
    except Exception as e:
        print(f"An error occurred (updating UserSentence): {e}")
        db.session.rollback()

def add_word(word, pinyin, similar_words, images, translation):
    try:
        existing_word = db.session.query(Word).filter(Word.word == word).first()

        if existing_word is None:
            new_word = Word(word=word, pinyin=pinyin, similar_words=similar_words, images=images, translation=translation)
            db.session.add(new_word)
            db.session.commit()
            return new_word.id

        return existing_word.id
    except Exception as e:
        print(f"An error occurred (add word): {e}")
        db.session.rollback()

def add_sentence(user_id, sentence_id, sentence, edited_sentence, youtube_seconds, youtube_id, line_num, youtube_creator, video_title):
    try:
        existing_sentence = db.session.query(Sentence).filter(Sentence.id == sentence_id).first()

        if existing_sentence is None:
            new_sentence = Sentence(id=sentence_id, sentence=sentence, youtube_id=youtube_id, line_num=line_num, youtube_seconds=youtube_seconds, youtube_creator=youtube_creator, video_title=video_title)
            db.session.add(new_sentence)
            db.session.commit()
            sentence_id = new_sentence.id
        else:
            sentence_id = existing_sentence.id

        if edited_sentence is not None:
            new_user_sentence = UserSentence(user_id=user_id, sentence_id=sentence_id, edited_sentence=edited_sentence)
            db.session.add(new_user_sentence)
            db.session.commit()

        return sentence_id
    except Exception as e:
        print(f"An error occurred (add sentence): {e}")
        db.session.rollback()

def add_review_records(user_id, word_id, sentence_id, note) -> None:
    # start a new transaction
    try:
        with db.session.begin():
            # Create a new UserWordSentence
            new_user_word_sentence = UserWordSentence(
                user_id=user_id,
                word_id=word_id,
                sentence_id=sentence_id,
                note=note
            )
            db.session.add(new_user_word_sentence)

            # Create a new UserWordReview with default values
            new_user_word_review = UserWordReview(
                user_id=user_id,
                user_word_sentence_id=new_user_word_sentence.id,
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

def add_study_date(user_id: int, study_date: date = datetime.now().date()):
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

def calculate_study_streak(user_id: int) -> int:
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

