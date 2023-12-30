import 'entry.dart';

class UserSentence {
  final List<Entry> entries;
  final String sentence;

  UserSentence({required this.entries, required this.sentence});

  factory UserSentence.fromJson(Map<String, dynamic> json) {
    var entryObjsJson = json['entries'] as List;
    List<Entry> entries = entryObjsJson.map((entryJson) => Entry.fromJson(entryJson)).toList();
    var sentence = json['sentence'] as String;
    
    return UserSentence(
      entries: entries,
      sentence: sentence,
    );
  }
}