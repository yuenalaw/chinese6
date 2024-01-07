import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/data/api_exception.dart';
import 'package:flutterapp/src/features/makereviews/domain/user_word_sentence.dart';
import 'package:flutterapp/src/features/makereviews/domain/word.dart';
import 'package:http/http.dart' as http;
import 'package:flutterapp/src/features/makereviews/domain/review_query.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_image.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_note.dart';

class ReviewRepository {
  ReviewRepository({
    required this.api,
    required this.client
  });
  final LanguageBackendAPI api;
  final http.Client client;

  Future<UserWordSentence> getUserWordSentence({required String videoId, required String word, required String lineChanged}) => _getData(
    uri: api.userWordSentence(word, videoId, lineChanged),
    builder: (data) => UserWordSentence.fromJson(data),
  );

  Future<Word> getWord({required String word}) => _getData(
    uri: api.word(word),
    builder: (data) => Word.fromJson(data),
  );

  Future<String> makeReview({required ReviewQuery review}) async {
    Map<String, dynamic> body = review.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.addReview(),
      builder: (data) => json.encode(data),
      body: jsonString,
    );
  }

  Future<String> updateImage({required UpdateImage image}) async {
    Map<String, dynamic> body = image.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.updateImage(),
      builder: (data) => json.encode(data),
      body: jsonString,
    );
  }

  Future<String> updateNote({required UpdateNote note}) async {
    Map<String, dynamic> body = note.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.updateNote(),
      builder: (data) => json.encode(data),
      body: jsonString,
    );
  }

  Future<T> _getData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Connection': 'keep-alive',
      'Accept': '*/*',
      'Cache-Control': 'no-cache',
      'Accept-Encoding': 'gzip, deflate, br',
    };
    try {
      final response = await client.get(uri, headers: headers);
      switch (response.statusCode) {
        case 200:
        String responsebody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = json.decode(responsebody);
        return builder(data);
        case 404:
          // means not reviewed before
          return builder(null);
        default:
          throw Exception('Error fetching user word sentence');
      }
    } on SocketException catch(_) {
        throw NoInternetConnectionException();
    }
  }

  Future<T> _postData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
    required String body,
  }) async {
    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Cache-Control': 'no-cache',
          'Accept': '*/*',
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br',
        },
        body: body,
      );
      switch (response.statusCode) {
        case 200:
          String responseBody = utf8.decode(response.bodyBytes);
          Map<String, dynamic> data = json.decode(responseBody);
          return builder(data);
        case 201:
          String responseBody = utf8.decode(response.bodyBytes);
          Map<String, dynamic> data = json.decode(responseBody);
          return builder(data);
        default:
          throw Exception('Failed to create resource: ${response.statusCode}');
      }
    } on SocketException catch(_) {
      throw NoInternetConnectionException();
    }
  }

}

// providers used by rest of app

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(
    api: LanguageBackendAPI(),
    client: http.Client(),
  );
});