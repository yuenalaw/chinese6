class Review {
  final String word;
  final String pinyin;
  final List<String> similarWords;
  final List<List<dynamic>> translation;
  final String videoId;
  final int lineChanged;
  final String sentence;
  final String note;
  final String imagePath;

  Review({
    required this.word,
    required this.pinyin,
    required this.similarWords,
    required this.translation,
    required this.videoId,
    required this.lineChanged,
    required this.sentence,
    required this.note,
    required this.imagePath,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    var translationFromJson = List<List<dynamic>>.from(json['translation'].map((x) => List<dynamic>.from(x)));
    return Review(
      word: json['word'],
      pinyin: json['pinyin'],
      similarWords: List<String>.from(json['similar_words']),
      translation: translationFromJson,
      videoId: json['video_id'],
      lineChanged: json['line_changed'],
      sentence: json['sentence'],
      note: json['note'],
      imagePath: json['image_path'],
    );
  }

  Map<String, dynamic> toJson() {
    var translationToJson = List<dynamic>.from(translation.map((x) => List<dynamic>.from(x)));
    return {
      'word': word,
      'pinyin': pinyin,
      'similar_words': similarWords,
      'translation': translationToJson,
      'video_id': videoId,
      'line_changed': lineChanged,
      'sentence': sentence,
      'note': note,
      'image_path': imagePath,
    };
  }
}