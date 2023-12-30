import 'entry.dart';

class Sentence {
  final List<Entry> entries;
  final String sentence;

  Sentence({required this.entries, required this.sentence});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    List<dynamic> entryObjsJson = json['entries'] as List<dynamic>;
    List<Entry> entries = entryObjsJson.map((entryJson) => Entry.fromJson(entryJson as Map<String, dynamic>)).toList();

    return Sentence(
      entries: entries,
      sentence: json['sentence'] as String,
    );
  }
}