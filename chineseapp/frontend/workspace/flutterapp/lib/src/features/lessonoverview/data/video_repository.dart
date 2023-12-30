
import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
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

  // get the lesson value (read once)
  Future<Video> getVideo({required String videoId}) => _getData(
    uri: api.video(videoId),
    builder: (data) => Video.fromJson(data),
  );

  Future<T> _getData<T>({
    required Uri uri,
    required T Function(dynamic data) builder,
  }) async {
    try {
      final response = await client.get(uri);
      switch (response.statusCode) {
        case 200:
        String responsebody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> data = json.decode(responsebody);
        return builder(data);
        case 404:
          throw Exception('Video not found');
        default:
          throw Exception('Error fetching video');
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