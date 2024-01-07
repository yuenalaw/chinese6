class Entry {
  final String pinyin;
  final List<String>? similarSounds;
  final List<Translation> translation;
  final String? upos;
  final String word;

  Entry({
    required this.pinyin, 
    required this.similarSounds, 
    required this.translation, 
    required this.upos, 
    required this.word
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      pinyin: json['pinyin'] as String? ?? '',
      similarSounds: json['similarsounds'] != null ? List<String>.from(json['similarsounds']) : [],
      translation: json['translation'] != null ? (json['translation'] as List).map((e) => Translation.fromJson(e as List)).toList() : [],
      upos: json['upos'] as String? ?? '',
      word: json['word'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pinyin': pinyin,
      'similarsounds': similarSounds,
      'translation': translation.map((e) => e.toJson()).toList(),
      'upos': upos,
      'word': word,
    };
  }
}

class Translation {
  final String word;
  final List<String> translations;

  Translation({required this.word, required this.translations});

  factory Translation.fromJson(List<dynamic> json) {
    return Translation(
      word: json[0] as String,
      translations: List<String>.from(json[1].map((x) => x as String)),
    );
  }

  List<dynamic> toJson() {
    return [
      word,
      translations,
    ];
  }
}