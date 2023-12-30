import 'segment.dart';
import 'user_sentence.dart';

class Lesson {
  final Segment segment;
  final UserSentence? userSentence;

  Lesson({
    required this.segment, this.userSentence
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final segment = Segment.fromJson(json['segment']); // non-nullable Segment
    final userSentence = json['user_sentence'] != null ? UserSentence.fromJson(json['user_sentence']) : null; // nullable UserSentence
    return Lesson(
      segment: segment,
      userSentence: userSentence,
    );
  }
}