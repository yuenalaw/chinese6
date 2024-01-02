
import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/features/lessonoverview/domain/please_wait_vid_or_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence_callback.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/updated_sentence_returned.dart';
import 'package:flutterapp/src/features/lessonoverview/data/api_exception.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:either_dart/either.dart';

class VideoRepository {
  VideoRepository({
    required this.api,
    required this.client
  });
  final LanguageBackendAPI api;
  final http.Client client;

  // get the lesson value (read once)
  Future<Either<PleaseWaitVidOrSentence, Video>> getVideo({required String videoId}) => _getData(
    uri: api.video(videoId),
    builder: (data) => Video.fromJson(data),
    processingBuilder: () => PleaseWaitVidOrSentence.fromJson({"message": "Please hold on while we process your video request..."}),
  );

  Future<Either<PleaseWaitVidOrSentence, UpdatedSentenceReturned>> getUpdatedSentence({required String videoId, required String lineChanged}) => _getData(
    uri: api.getUpdatedSentence(videoId, lineChanged),
    builder: (data) => UpdatedSentenceReturned.fromJson(data),
    processingBuilder: () => PleaseWaitVidOrSentence.fromJson({"message": "Please hold on while we process your sentence request..."}),
  );

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

  Future<Either<T1, T2>> _getData<T1,T2>({
    required Uri uri,
    required T2 Function(dynamic data) builder,
    required T1 Function() processingBuilder,
  }) async {
    try {
      final response = await client.get(uri);
      switch (response.statusCode) {
        case 200:
        String responsebody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = json.decode(responsebody);
        return Right(builder(data));
        case 202:
          String responsebody = utf8.decode(response.bodyBytes);
          Map<String, dynamic> data = json.decode(responsebody);
          return Right(builder(data));
        case 404:
          return Left(processingBuilder());
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