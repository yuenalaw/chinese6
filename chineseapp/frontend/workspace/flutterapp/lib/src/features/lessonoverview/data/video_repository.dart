
import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence_callback.dart';
import 'package:flutterapp/src/features/lessonoverview/data/api_exception.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class VideoRepository {
  VideoRepository({
    required this.api,
    required this.client
  });
  final LanguageBackendAPI api;
  final http.Client client;
  
  Future<Video> getVideo({required String videoId}) => _getData(
    uri: api.video(videoId),
    builder: (data) => Video.fromJson(data),
  );

  // Future<Either<PleaseWaitVidOrSentence, UpdatedSentenceReturned>> getUpdatedSentence({required String videoId, required int lineChanged}) => _getData(
  //   uri: api.getUpdatedSentence(videoId, lineChanged),
  //   builder: (data) => UpdatedSentenceReturned.fromJson(data),
  // );

  /*return {'message': 'Sentence task has been added to the queue', 'callback': task_id}, 202
*/
  Future<UpdateSentenceCallback> updateSentence({required UpdateSentence updateSentenceObj}) async {
    Map<String, dynamic> body = updateSentenceObj.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.updateSentence(),
      builder: (data) => UpdateSentenceCallback.fromJson(data),
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
        case 202:
          String responsebody = utf8.decode(response.bodyBytes);
          Map<String, dynamic> data = json.decode(responsebody);
          return builder(data);
        case 404:
          return builder(null);
        default:
          throw Exception('Error fetching...');
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
        case 202:
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

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(
    api: LanguageBackendAPI(),
    client: http.Client(),
  );
});