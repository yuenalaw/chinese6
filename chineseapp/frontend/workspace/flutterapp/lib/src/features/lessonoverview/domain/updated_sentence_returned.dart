/*
{
    "message": "Successfully obtained updated sentence!",
    "updated_sentence": {
        "entries": [
            {
                "pinyin": "wo",
                "similarsounds": null,
                "translation": [
                    [
                        "我",
                        [
                            "I",
                            "me",
                            "my"
                        ]
                    ]
                ],
                "upos": "PRON",
                "word": "我"
            },
            {
                "pinyin": "ai",
                "similarsounds": null,
                "translation": [
                    [
                        "爱",
                        [
                            "to love",
                            "to be fond of",
                            "to like",
                            "affection",
                            "to be inclined (to do sth)",
                            "to tend to (happen)"
                        ]
                    ]
                ],
                "upos": "VERB",
                "word": "爱"
            },
            {
                "pinyin": "ni",
                "similarsounds": [
                    "泥",
                    "鹂",
                    "鲡",
                    "檪",
                    "霓"
                ],
                "translation": [
                    [
                        "你",
                        [
                            "you (informal, as opposed to courteous 您[nin2])"
                        ]
                    ]
                ],
                "upos": "PRON",
                "word": "你"
            }
        ],
        "sentence": "我爱你"
    }
}
*/

import 'package:flutterapp/src/features/lessonoverview/domain/user_sentence.dart';

import 'entry.dart';

class UpdatedSentenceReturned {
  final List<Entry> entries;
  final String sentence;

  UpdatedSentenceReturned({
    required this.entries,
    required this.sentence,
  });

  factory UpdatedSentenceReturned.fromJson(Map<String, dynamic> json) {
    final entries = (json['updated_sentence']['entries'] as List).map((entry) => Entry.fromJson(entry)).toList();
    final sentence = json['updated_sentence']['sentence'] as String;
    return UpdatedSentenceReturned(
      entries: entries,
      sentence: sentence,
    );
  }

  UserSentence toUserSentence() {
    return UserSentence(
      entries: entries,
      sentence: sentence,
    );
  }
}