
import 'word.dart';
import 'review.dart';

class ReviewCard {
  final String? imagePath;
  final int lineChanged;
  final String? note;
  final Review review;
  final String sentence;
  final Word word;

  ReviewCard({
    this.imagePath,
    required this.lineChanged,
    this.note,
    required this.review,
    required this.sentence,
    required this.word,
  });

  factory ReviewCard.fromJson(Map<String, dynamic> json) {

    return ReviewCard(
      imagePath: json['image_path'],
      lineChanged: json['line_changed'],
      note: json['note'],
      review: Review.fromJson(json['review']),
      sentence: json['sentence'],
      word: Word.fromJson(json['word']),
    );
  }
}