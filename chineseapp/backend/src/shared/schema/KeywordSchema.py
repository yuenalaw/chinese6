from typing import List

class KeywordSchema:
    def __init__(self, chinese_word: str, word_category: List[str]):
        self._chinese_word = chinese_word
        self._word_category = word_category

    @property
    def ChineseWord(self):
        return self._chinese_word

    @ChineseWord.setter
    def ChineseWord(self, value):
        self._chinese_word = value
    
    @ChineseWord.deleter
    def ChineseWord(self):
        del self._chinese_word
    
    @property
    def WordCategory(self):
        return self._word_category

    @WordCategory.setter
    def WordCategory(self, value):
        self._word_category = value
    
    @WordCategory.deleter
    def WordCategory(self):
        del self._word_category
