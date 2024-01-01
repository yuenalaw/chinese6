class Word {
  final int id;
  final String pinyin;
  final List<String>? similarSounds;
  final List<String>? translations;
  final String word;

  Word({
    required this.id,
    required this.pinyin, 
    this.similarSounds, 
    this.translations, 
    required this.word
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      pinyin: json['pinyin'],
      similarSounds: json['similarsounds'] != null ? List<String>.from(json['similarsounds']) : [],
      translations: json['translation'] != null ? List<String>.from(json['translation']) : [],
      word: json['word'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pinyin': pinyin,
      'similarsounds': similarSounds,
      'translation': translations,
      'word': word,
    };
  }
}