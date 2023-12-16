from src.app.database import db
from sqlalchemy import Column, Integer, Float, Date, Text, String, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.mysql import JSON

class User(db.Model):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True)
    username = Column(String(255), unique=True, nullable=False)
    study_dates = relationship('UserStudyDate', backref='associated_user')
    reviews = relationship('UserWordReview', backref='reviewing_user')
    studied_sentences = relationship('UserWordSentence', backref='studying_user')
    user_sentences = relationship('UserSentence', backref='sentences_user')

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
    translation = Column(JSON)

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
    youtube_id = Column(String(255), ForeignKey('video_details.id'))  # reference VideoDetails directly
    line_changed = Column(Integer)
    note = Column(Text) # adding note here, as users can write notes about a certain word in a certain sentence. Means users draw more linkages rather than just one note per word, everywhere.
    review = db.relationship('UserWordReview', backref='reviewed_sentence', uselist=False) # one to one relationship

class UserSentence(db.Model):
    __tablename__ = 'user_sentence'

    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    line_changed = Column(Integer)
    youtube_id = Column(String(255))
    user_sentence = Column(JSON) # does not have to be edited, just a sentence the user saves
    """
    {'sentence': '加州留学生的生活', 'entries': [{'word': '加州', 'upos': 'PROPN', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '留学', 'upos': 'VERB', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '生', 'upos': 'PART', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '的', 'upos': 'PART', 'pinyin': None, 'translation': None, 'similarsounds': None}, 
        {'word': '生活', 'upos': 'NOUN', 'pinyin': None, 'translation': None, 'similarsounds': None}]}]
    """

class VideoDetails(db.Model):
    __tablename__ = 'video_details'

    id = Column(String(255), primary_key=True) # same as youtube id
    lesson_keyword_imgs = Column(JSON)
    lesson_data = Column(Text, unique=True, nullable=False)