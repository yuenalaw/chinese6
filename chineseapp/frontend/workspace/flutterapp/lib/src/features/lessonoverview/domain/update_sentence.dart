import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/user_sentence.dart';

class UpdateSentence {
  final String videoId;
  final int lineChanged;
  final String sentence;

  UpdateSentence({
    required this.videoId,
    required this.lineChanged,
    required this.sentence,
  });

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'line_changed': lineChanged,
      'sentence': sentence,
    };
  }

  UserSentence toUserSentence() {
    return UserSentence(
      sentence: sentence,
      entries: [Entry(word: "loading", translation: [], pinyin: "", similarSounds: [], upos: "")],
    );
  }

}