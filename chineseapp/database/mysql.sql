CREATE DATABASE LANGUAGEAPPDB;

use LANGUAGEAPPDB;

CREATE TABLE User (
    id INTEGER PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE UserStudyDate (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    study_date DATE,
    FOREIGN KEY(user_id) REFERENCES User(id)
);

CREATE TABLE Word (
    id INTEGER PRIMARY KEY,
    word VARCHAR(255) NOT NULL,
    pinyin VARCHAR(255),
    similar_words JSON,
    translation JSON
);

CREATE TABLE UserWordReview (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    word_id INTEGER,
    last_reviewed DATE,
    repetitions INTEGER,
    ease_factor FLOAT,
    word_interval INTEGER,
    next_review DATE,
    FOREIGN KEY(user_id) REFERENCES User(id),
    FOREIGN KEY(word_id) REFERENCES Word(id)
);

CREATE TABLE UserWordSentence (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    word_id INTEGER,
    youtube_id VARCHAR(255),
    line_changed INTEGER,
    note TEXT,
    FOREIGN KEY(user_id) REFERENCES User(id),
    FOREIGN KEY(word_id) REFERENCES Word(id)
);

CREATE TABLE UserSentence (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    line_changed INTEGER,
    youtube_id VARCHAR(255),
    user_sentence JSON,
    FOREIGN KEY(user_id) REFERENCES User(id)
);

CREATE TABLE VideoDetails (
    id VARCHAR(255) PRIMARY KEY,
    lesson_keyword_imgs JSON,
    lesson_data TEXT NOT NULL UNIQUE
);