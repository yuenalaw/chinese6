/*
request_data['word_id'], request_data['last_repetitions'], request_data['prev_ease_factor'], request_data['prev_word_interval'], request_data['quality']
*/

class UpdateReview {
  final int wordId;
  final int lastRepetitions;
  final double prevEaseFactor;
  final int prevWordInterval;
  final int quality;

  UpdateReview({
    required this.wordId,
    required this.lastRepetitions,
    required this.prevEaseFactor,
    required this.prevWordInterval,
    required this.quality,
  });

  Map<String, dynamic> toJson() {
    return {
      'word_id': wordId,
      'last_repetitions': lastRepetitions,
      'prev_ease_factor': prevEaseFactor,
      'prev_word_interval': prevWordInterval,
      'quality': quality,
    };
  }
}