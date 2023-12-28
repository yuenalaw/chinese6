from sqlalchemy import Column, Integer, Float, Date, Text, String, ForeignKey
from sqlalchemy.orm import relationship, class_mapper
from sqlalchemy.dialects.mysql import JSON

from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.pool import QueuePool

db = SQLAlchemy(engine_options={"pool_size":10, "poolclass":QueuePool, "pool_pre_ping":True, "pool_recycle":3600})

class UserStudyDate(db.Model):
    __tablename__ = 'user_study_date'

    id = Column(Integer, primary_key=True)
    study_date = Column(Date)

class Word(db.Model): # word is kept as a table, as it allows for one word to be mapped to many sentences
    __tablename__ = 'word'

    id = Column(Integer, primary_key=True)
    word = Column(String(255), nullable=False)
    pinyin = Column(String(255))
    similar_words = Column(JSON)
    translation = Column(JSON)
    def to_dict(self):
        return {c.key: getattr(self, c.key)
                for c in class_mapper(self.__class__).columns}

class UserWordReview(db.Model):
    __tablename__ = 'user_word_review'

    id = Column(Integer, primary_key=True)
    word_id = Column(Integer, ForeignKey('word.id', ondelete='CASCADE'))
    user_word_sentence_id = Column(Integer, ForeignKey('user_word_sentence.id', ondelete='CASCADE'))
    last_reviewed = Column(Date)
    repetitions = Column(Integer)
    ease_factor = Column(Float)
    word_interval = Column(Integer)
    next_review = Column(Date)
    def to_dict(self):
        return {c.key: getattr(self, c.key)
                for c in class_mapper(self.__class__).columns}

class UserWordSentence(db.Model):
    __tablename__ = 'user_word_sentence'

    id = Column(Integer, primary_key=True)
    word_id = Column(Integer, ForeignKey('word.id', ondelete='CASCADE'))  # reference Word directly
    video_id = Column(String(255), ForeignKey('video_details.id', ondelete='CASCADE'))  # reference VideoDetails directly
    line_changed = Column(Integer)
    note = Column(Text) # adding note here, as users can write notes about a certain word in a certain sentence. Means users draw more linkages rather than just one note per word, everywhere.
    sentence = Column(String(255))
    image_path = Column(String(255))
    review = db.relationship('UserWordReview', backref='reviewed_sentence', uselist=False, cascade="all, delete-orphan")  # one to one relationship

class UserSentence(db.Model):
    __tablename__ = 'user_sentence'

    id = Column(Integer, primary_key=True)
    line_changed = Column(Integer)
    video_id = Column(String(255), ForeignKey('video_details.id', ondelete='CASCADE'))  # reference VideoDetails directly
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
    lesson_data = Column(JSON, nullable=False)
    sentences = relationship('UserWordSentence', backref='video', cascade="all, delete-orphan")
    user_sentences = relationship('UserSentence', backref='video', cascade="all, delete-orphan")