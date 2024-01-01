class Review {
  final double easeFactor;
  final int id;
  final String lastReviewed;
  final String nextReview;
  final int repetitions;
  final int userWordSentenceId;
  final int wordId;
  final int wordInterval;

  Review({
    required this.easeFactor,
    required this.id,
    required this.lastReviewed,
    required this.nextReview,
    required this.repetitions,
    required this.userWordSentenceId,
    required this.wordId,
    required this.wordInterval,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      easeFactor: json['ease_factor'],
      id: json['id'],
      lastReviewed: json['last_reviewed'],
      nextReview: json['next_review'],
      repetitions: json['repetitions'],
      userWordSentenceId: json['user_word_sentence_id'],
      wordId: json['word_id'],
      wordInterval: json['word_interval'],
    );
  }
}