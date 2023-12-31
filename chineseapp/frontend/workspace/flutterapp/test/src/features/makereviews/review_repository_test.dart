import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:flutterapp/src/features/makereviews/data/review_repository.dart';
import 'dart:convert';

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
  }
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

void main() {
  test('review repository with mocked http client, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.word("特别"))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(wordJson), 200)));
    final word = await reviewRepository.getWord(word:"特别");

    expect(word.id, 1);
    expect(word.word, "特别");
  });

  test('review repository with mocked http client, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.word(""))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(wordJson), 404)));
    final word = await reviewRepository.getWord(word:"");

    expect(word.id, null);
  });

  test('review repository with mocked http client, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.userWordSentence("特别", "-acfusFM4d8", "1"))).thenAnswer(
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

  test('review repository with mocked http client, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final reviewRepository = 
      ReviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.userWordSentence("", "", ""))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(userWordSentenceJson), 404)));
    final userWordSentence = await reviewRepository.getUserWordSentence(word: "", videoId: "", lineChanged: "");

    expect(userWordSentence.id, null);
  });

}