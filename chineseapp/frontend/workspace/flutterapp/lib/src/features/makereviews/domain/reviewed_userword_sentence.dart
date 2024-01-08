import 'package:flutterapp/src/features/makereviews/domain/user_word_sentence.dart';

class ReviewedUserWordSentence extends UserWordSentence {
  bool isReview;

  ReviewedUserWordSentence({
    int? id,
    String? imagePath,
    int? lineChanged,
    String? note,
    String? sentence,
    String? videoId,
    int? wordId,
  }) : isReview = imagePath != null || note != null,
       super(
          id: id,
          imagePath: imagePath,
          lineChanged: lineChanged,
          note: note,
          sentence: sentence,
          videoId: videoId,
          wordId: wordId,
        );
}

extension MutableReviewedUserSentence on ReviewedUserWordSentence {
  ReviewedUserWordSentence copyWith({
    int? id,
    String? imagePath,
    int? lineChanged,
    String? note,
    String? sentence,
    String? videoId,
    int? wordId,
  }) => ReviewedUserWordSentence(
    id: id ?? this.id,
    imagePath: imagePath ?? this.imagePath,
    lineChanged: lineChanged ?? this.lineChanged,
    note: note ?? this.note,
    sentence: sentence ?? this.sentence,
    videoId: videoId ?? this.videoId,
    wordId: wordId ?? this.wordId,
  );
}