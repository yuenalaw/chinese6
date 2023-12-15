/* CREATE DATABASE EXAMPLEDB;

use EXAMPLEDB;

CREATE TABLE EXAMPLE_TABLE (
  UUID varchar(100) NOT NULL,
  PRIMARY KEY ( UUID )
); */

CREATE DATABASE APPDB;

use APPDB;

CREATE TABLE Users (
    id INT PRIMARY KEY AUTOINCREMENT NOT NULL,
    username VARCHAR(255) NOT NULL UNIQUE
);

INSERT OR IGNORE INTO Users (id, username) VALUES (1, 'yue');

CREATE TABLE Words (
    id INT PRIMARY KEY AUTOINCREMENT NOT NULL,
    word VARCHAR(255) NOT NULL,
    pinyin VARCHAR(255),
    similar_words JSON,
    images JSON,
    translation JSON
);

CREATE TABLE Sentences (
    id VARCHAR(255) PRIMARY KEY NOT NULL,
    sentence TEXT NOT NULL
);

CREATE TABLE WordSentence (
    id INT PRIMARY KEY AUTOINCREMENT NOT NULL,
    youtubeid VARCHAR(255),
    wordid INT,
    word VARCHAR(255),
    sentenceid VARCHAR(255),
    youtubecreator VARCHAR(255),
    videotitle VARCHAR(255),
    FOREIGN KEY (wordid) REFERENCES Words(id),
    FOREIGN KEY (sentenceid) REFERENCES Sentences(id),
    UNIQUE(wordid, sentenceid)
);

CREATE TABLE UserWordReview (
    id INT PRIMARY KEY,
    userid INT,
    userwordsentenceid INT,
    note TEXT,
    last_reviewed DATE,
    repetitions INT,
    ease_factor FLOAT,
    word_interval INT,
    next_review DATE,
    FOREIGN KEY (userid) REFERENCES Users(id),
    FOREIGN KEY (userwordsentenceid) REFERENCES userWordSentence(id)
);

CREATE TABLE UserWordSentence (
    id INT PRIMARY KEY,
    userid INT,
    wordsentenceid INT,
    FOREIGN KEY (userid) REFERENCES Users(id),
    FOREIGN KEY (wordsentenceid) REFERENCES wordSentence(id)
);

CREATE TABLE UserSentences (
    id INT PRIMARY KEY,
    userid INT,
    sentenceid VARCHAR(255),
    edited_sentence TEXT,
    FOREIGN KEY (userid) REFERENCES Users(id),
    FOREIGN KEY (sentenceid) REFERENCES Sentences(id)
);
