from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
from datetime import date
from sqlalchemy import and_, or_
from sqlalchemy import Column, Integer, Float, Date, Text, String, ForeignKey
from sqlalchemy.orm import relationship, aliased
from sqlalchemy.dialects.mysql import JSON
from typing import List, Tuple
import redis
import json

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

class Word(db.Model):
    __tablename__ = 'word'

    id = Column(Integer, primary_key=True)
    word = Column(String(255), nullable=False)
    pinyin = Column(String(255))
    similar_words = Column(JSON)
    images = Column(JSON)
    translation = Column(JSON)
    sentences = relationship('WordSentence', backref='associated_word')

class Sentence(db.Model):
    __tablename__ = 'sentence'

    id = Column(String(255), primary_key=True)
    sentence = Column(Text, nullable=False)
    words = relationship('WordSentence', backref='associated_sentence')
    user_sentences = relationship('UserSentence', backref='original_sentence')

class WordSentence(db.Model):
    __tablename__ = 'word_sentence'

    id = Column(Integer, primary_key=True)
    youtube_id = Column(String(255))
    word_id = Column(Integer, ForeignKey('word.id'))
    sentence_id = Column(String(255), ForeignKey('sentence.id'))
    youtube_creator = Column(String(255))
    video_title = Column(String(255))
    user_word_sentences = relationship('UserWordSentence', backref='studied_sentence')

class UserWordReview(db.Model):
    __tablename__ = 'user_word_review'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    user_word_sentence_id = Column(Integer, ForeignKey('user_word_sentence.id'))
    note = Column(Text)
    last_reviewed = Column(Date)
    repetitions = Column(Integer)
    ease_factor = Column(Float)
    word_interval = Column(Integer)
    next_review = Column(Date)

class UserWordSentence(db.Model):
    __tablename__ = 'user_word_sentence'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    word_sentence_id = Column(Integer, ForeignKey('word_sentence.id'))
    review = db.relationship('UserWordReview', backref='reviewed_sentence', uselist=False) # one to one relationship
    word_sentence = relationship('WordSentence', backref='studied_by_users')

class UserSentence(db.Model):
    __tablename__ = 'user_sentence'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    sentence_id = Column(String(255), ForeignKey('sentence.id'))
    edited_sentence = Column(Text)

def get_review_words_today(user_id: int) -> List[Tuple[UserWordReview, UserWordSentence, WordSentence, str, Word]]:
    """
    Get words for review for a specific user today.

    Parameters:
    user_id (int): The ID of the user.

    Returns:
    List[Tuple[UserWordReview, UserWordSentence, WordSentence, str, Word]]: A list of tuples containing the review, user word sentence, word sentence, sentence, and word.
    """
    today = datetime.now().date()

    # Try to get the result from the cache
    key = f"review_words:{user_id}:{today}"
    result = r.get(key)

    if result is not None:
        return json.loads(result)

    UserSentenceForJoin = aliased(UserSentence)

    try:
        query = db.session.query(
            UserWordReview,
            UserWordSentence,
            WordSentence,
            or_(UserSentenceForJoin.edited_sentence, Sentence.sentence).label('sentence'),
            Word
        ).join(
            UserWordSentence, UserWordReview.user_word_sentence_id == UserWordSentence.id
        ).join(
            WordSentence, UserWordSentence.word_sentence_id == WordSentence.id
        ).join(
            Sentence, WordSentence.sentence_id == Sentence.id
        ).outerjoin(
            UserSentenceForJoin, and_(Sentence.id == UserSentenceForJoin.sentence_id, UserWordSentence.user_id == UserSentenceForJoin.user_id)
        ).join(
            Word, WordSentence.word_id == Word.id
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

def add_sentence(user_id, sentence_id, sentence, edited_sentence):
    try:
        existing_sentence = db.session.query(Sentence).filter(Sentence.id == sentence_id).first()

        if existing_sentence is None:
            new_sentence = Sentence(id=sentence_id, sentence=sentence)
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

def add_review_records(user_id, word_id, sentence_id, youtube_id, youtube_creator, video_title):
    # start a new transaction
    try:
        with db.session.begin():
            # Create new WordSentence
            new_word_sentence = WordSentence(
                youtube_id=youtube_id,
                word_id=word_id,
                sentence_id=sentence_id,
                youtube_creator=youtube_creator,
                video_title=video_title
            )
            db.session.add(new_word_sentence)

            # Create a new UserWordSentence
            new_user_word_sentence = UserWordSentence(
                user_id=user_id,
                word_sentence_id=new_word_sentence.id
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

