import 'segment.dart';
import 'user_sentence.dart';

class Lesson {
  final Segment segment;
  final UserSentence? userSentence;

  Lesson({
    required this.segment, this.userSentence
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var segment = Segment.fromJson(json['segment']);
    UserSentence? userSentence;
    if (json['user_sentence'] != null) {
      userSentence = UserSentence.fromJson(json['user_sentence']);
    }

    return Lesson(
      segment: segment,
      userSentence: userSentence,
    );
  }
}

extension MutableLesson on Lesson {
  Lesson changeUserSentence(UserSentence userSentence) {
    return Lesson(
      segment: segment,
      userSentence: userSentence,
    );
  }
}