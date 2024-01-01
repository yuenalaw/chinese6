import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:flutterapp/src/features/spacedrepetition/data/srs_repository.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/cards_today.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/review_card.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/review.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/word.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/context.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/update_review.dart';
import 'mock_context_encoded_json.dart';


class MockHttpClient extends Mock implements http.Client {} 

final expectedReviewCardsFromJson = CardsToday(
  reviewCards: [
    ReviewCard(
      imagePath: "unedited path",
      lineChanged: 1,
      note: "unedited note",
      review: Review(
        easeFactor: 2.5,
        id: 1,
        lastReviewed: "Sat, 30 Dec 2023 00:00:00 GMT",
        nextReview: "Sat, 30 Dec 2023 00:00:00 GMT",
        repetitions: 0,
        userWordSentenceId: 1,
        wordId: 1,
        wordInterval: 1
      ),
      sentence: "总是特别多彩多姿",
      word: Word(
        id: 1,
        pinyin: "te bie",
        similarSounds: [
          "特别"
        ],
        translations: [
          "especially"
        ],
        word: "特别"
      ),
    ),
  ],
);

final mockGetCardsTodayJson = 
{
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
};

final mockUpdateReviewJson = 
{
  "word_id": 1,
  "last_repetitions": 1,
  "prev_ease_factor": 2.5,
  "prev_word_interval": 1,
  "quality": 1
};

final updateReview = UpdateReview(
  wordId: 1,
  lastRepetitions: 1,
  prevEaseFactor: 2.5,
  prevWordInterval: 1,
  quality: 1,
);

const mockGetContextJson = encodedJsonContext;

void main() {
  test('srs repository with get cards today, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final srsRepository = 
      SRSRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getCardsToday())).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockGetCardsTodayJson)), 200)));
    final cardsToday = await srsRepository.getCardsToday();

    expect(cardsToday, isA<CardsToday>());
    expect(cardsToday.reviewCards[0].imagePath, "unedited path");
    expect(cardsToday.reviewCards.length, 1);
    expect(cardsToday.reviewCards[0].lineChanged, 1);
    expect(cardsToday.reviewCards[0].review.easeFactor, 2.5);
    expect(cardsToday.reviewCards[0].word.id, 1);
  });

  test('srs repository with get cards today, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final srsRepository = 
      SRSRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getCardsToday())).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockGetCardsTodayJson)), 404)));
    expect(() async => await srsRepository.getCardsToday(), throwsException);
  });

  test('srs repository with get context, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final srsRepository = 
      SRSRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getContext("-acfusFM4d8", 1))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockGetContextJson)), 200)));
    final context = await srsRepository.getContext(videoId: "-acfusFM4d8", lineChanged: 1);

    expect(context, isA<Context>());
    expect(context.previousSentence.sentence, "加州留学生的生活");
    expect(context.nextSentence.sentence, "晚上在夜店喝酒狂欢");
    expect(context.nextSentence.entries.length, 8);
  });

  test('srs repository with get context, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final srsRepository = 
      SRSRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getContext("-acfusFM4d8", 1))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockGetContextJson)), 404)));
    expect(() async => await srsRepository.getContext(videoId: "-acfusFM4d8", lineChanged: 1), throwsException);
  });

  test('review repository with for update review, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final srsRepository = 
      SRSRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.updateReviewStats(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateReviewJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockUpdateReviewJson)), 200));
    await srsRepository.updateReview(updateReviewObj: updateReview);
    verify(() => mockHttpClient.post(
      api.updateReviewStats(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateReviewJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });
}