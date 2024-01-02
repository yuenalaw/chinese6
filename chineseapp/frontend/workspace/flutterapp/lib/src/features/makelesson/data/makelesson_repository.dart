import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/features/makelesson/domain/disney_request.dart';
import 'package:flutterapp/src/features/makelesson/domain/youtube_request.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makelesson/data/api_exception.dart';
import 'package:http/http.dart' as http;

class MakeLessonRepository {
  MakeLessonRepository({
    required this.api,
    required this.client
  });
    
  final LanguageBackendAPI api;
  final http.Client client;

  Future<String> postYouTubeRequest({required YouTubeRequest ytRequest}) async {
    Map<String, dynamic> body = ytRequest.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.postYouTubeRequest(),
      builder: (data) => json.encode(data),
      body: jsonString,
    );
  }

  Future<String> postDisneyRequest({required DisneyRequest disneyRequest}) async {
    Map<String, dynamic> body = disneyRequest.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.postDisneyRequest(),
      builder: (data) => json.encode(data),
      body: jsonString,
    );
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

final makeLessonRepositoryProvider = Provider<MakeLessonRepository>((ref) {
  return MakeLessonRepository(
    api: LanguageBackendAPI(),
    client: http.Client(),
  );
});