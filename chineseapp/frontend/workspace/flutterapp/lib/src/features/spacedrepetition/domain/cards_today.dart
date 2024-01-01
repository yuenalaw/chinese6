
/*
    "message": "Successfully obtained review cards!",
    "review_cards": [
        {
            "image_path": "unedited path",
            "line_changed": 1,
            "note": "attempt!",
            "review": {
                "ease_factor": 2.5,
                "id": 1,
                "last_reviewed": "Sat, 30 Dec 2023 00:00:00 GMT",
                "next_review": "Sat, 30 Dec 2023 00:00:00 GMT",
                "repetitions": 0,
                "user_word_sentence_id": 1,
                "word_id": 1,
                "word_interval": 1
            },
            "sentence": "总是特别多彩多姿",
            "word": {
                "id": 1,
                "pinyin": "te bie",
                "similar_words": [
                    "特别"
                ],
                "translation": [
                    "especially"
                ],
                "word": "特别"
            }
        }
    ]
}
*/

import 'review_card.dart';

class CardsToday {
  final List<ReviewCard> reviewCards;

  CardsToday({required this.reviewCards});

  factory CardsToday.fromJson(Map<String, dynamic> json) {
    var list = json['review_cards'] as List;
    List<ReviewCard> reviewCardList = list.map((i) => ReviewCard.fromJson(i)).toList();

    return CardsToday(
      reviewCards: reviewCardList,
    );
  }
}