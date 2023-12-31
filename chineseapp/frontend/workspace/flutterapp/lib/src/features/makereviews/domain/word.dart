/*
{
    "message": "Successfully obtained word!",
    "word": {
        "id": 1,
        "pinyin": "te bie",
        "similar_words": [
            "特别"
        ],
        "translation": [
            "especially"
        ],
        "word": "特别"
    }
}
*/

class Word {
  final int? id;
  final String? word;

  Word({
    this.id,
    this.word,
  });

  factory Word.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return Word();
    }
    return Word(
      id: data['word']['id'],
      word: data['word']['word'],
    );
  }
}