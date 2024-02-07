/*
{
    "message": "Successfully obtained word sentence!",
    "word_sentence": {
        "user_word_sentence": {
            "id": 1,
            "image_path": "unedited path",
            "line_changed": 1,
            "note": "attempt!",
            "sentence": "总是特别多彩多姿",
            "video_id": "-acfusFM4d8",
            "word_id": 1
        },
        "word_id": 1
    }
}
*/

class UserWordSentence {
  final int? id;
  final String? imagePath;
  final int? lineChanged;
  final String? note;
  final String? sentence;
  final String? videoId;
  final int? wordId;

  UserWordSentence({
    this.id,
    this.imagePath,
    this.lineChanged,
    this.note,
    this.sentence,
    this.videoId,
    this.wordId,
  });

  factory UserWordSentence.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return UserWordSentence(
        id: null,
        imagePath: null,
        lineChanged: null,
        note: null,
        sentence: null,
        videoId: null,
        wordId: null,
      );
    } else {
      return UserWordSentence(
        id: json['word_sentence']['user_word_sentence']['id'],
        imagePath: json['word_sentence']['user_word_sentence']['image_path'],
        lineChanged: json['word_sentence']['user_word_sentence']['line_changed'],
        note: json['word_sentence']['user_word_sentence']['note'],
        sentence: json['word_sentence']['user_word_sentence']['sentence'],
        videoId: json['word_sentence']['user_word_sentence']['video_id'],
        wordId: json['word_sentence']['user_word_sentence']['word_id'],
      );
    }
  }
}