import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_image.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_note.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flutterapp/src/features/makereviews/data/review_repository.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_query.dart';
import 'dart:convert';

import '../../constants/headers.dart';

class MockHttpClient extends Mock implements http.Client {} 

const wordJson = """
{
  "message": "Successfully obtained word!",
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
  },
  "word_sentence": "fake"
}
""";

const userWordSentenceJson = """
{
    "message": "Successfully obtained word sentence!",
    "word_sentence": {
        "user_word_sentence": {
            "id": 1,
            "image_path": "unedited path",
            "line_changed": 1,
            "note": "attempt!",
            "sentence": "总是特别多彩多姿",
            "video_id": "-acfusFM4d8",
            "word_id": 1
        },
        "word_id": 1
    }
}
""";

var mockReview = ReviewQuery(
  word: "特别",
  pinyin: "te bie",
  similarWords: ["特别"],
  translation: [["特", ["special", "unique", "distinguished"]], ["特别", ["especially"]], ["别", ["to make sb change their ways, opinions etc"]]],
  videoId: "-acfusFM4d8",
  lineChanged: 1,
  sentence: "总是特别多彩多姿",
  note: "initialnote",
  imagePath: "initialpath"
);

var mockReviewJson = 
{
  "word": "特别",
  "pinyin": "te bie",
  "similar_words": ["特别"],
  "translation": [["特", ["special", "unique", "distinguished"]], ["特别", ["especially"]], ["别", ["to make sb change their ways, opinions etc"]]],
  "video_id": "-acfusFM4d8",
  "line_changed": 1,
  "sentence": "总是特别多彩多姿",
  "note": "initialnote",
  "image_path": "initialpath"
};

var mockImage = UpdateImage(
  videoId: "-acfusFM4d8",
  wordId: 1,
  lineChanged: 1,
  imagePath: "initialpath"
);

var mockImageJson = 
{
  "video_id": "-acfusFM4d8",
  "word_id": 1,
  "line_changed": 1,
  "image_path": "initialpath"
};

var mockNote = UpdateNote(
  videoId: "-acfusFM4d8", 
  wordId: 1, 
  lineChanged: 1, 
  note: "initialnote"
);

var mockNoteJson = 
{
  "video_id": "-acfusFM4d8",
  "word_id": 1,
  "line_changed": 1,
  "note": "initialnote"
};

void main() {
  test('review repository with mocked http client, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.word("特别"), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(wordJson), 200)));
    final word = await reviewRepository.getWord(word:"特别");

    expect(word.word, "特别");
  });

  test('review repository with mocked http client, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.word(""), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(wordJson), 404)));
    final word = await reviewRepository.getWord(word:"");

    expect(word.id, null);
  });

  test('review repository with mocked http client, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.userWordSentence("特别", "-acfusFM4d8", "1"), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(userWordSentenceJson), 200)));
    final userWordSentence = await reviewRepository.getUserWordSentence(word: "特别", videoId: "-acfusFM4d8", lineChanged: "1");

    expect(userWordSentence.id, 1);
    expect(userWordSentence.imagePath, "unedited path");
    expect(userWordSentence.lineChanged, 1);
    expect(userWordSentence.note, "attempt!");
    expect(userWordSentence.sentence, "总是特别多彩多姿");
    expect(userWordSentence.videoId, "-acfusFM4d8");
    expect(userWordSentence.wordId, 1);
  });

  test('review repository for user word sentence with mocked http client, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.userWordSentence("","",""), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(userWordSentenceJson), 404)));
    final userWordSentence = await reviewRepository.getUserWordSentence(word:"", videoId: "", lineChanged:"");

    expect(userWordSentence.wordId, null);
  });
  test('review repository with for posting, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.addReview(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockReviewJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockReviewJson)), 200));
    await reviewRepository.makeReview(review: mockReview);
    verify(() => mockHttpClient.post(
      api.addReview(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockReviewJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });

    test('review repository with for update image path, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.updateImage(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockImageJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockImageJson)), 200));
    await reviewRepository.updateImage(image:mockImage);
    verify(() => mockHttpClient.post(
      api.updateImage(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockImageJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });

    test('review repository with for update note, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.updateNote(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockNoteJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockNoteJson)), 200));
    await reviewRepository.updateNote(note: mockNote);
    verify(() => mockHttpClient.post(
      api.updateNote(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockNoteJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });

}