import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/data/api_exception.dart';
import 'package:http/http.dart' as http;

class ExistingVideosRepository {
  ExistingVideosRepository({
    required this.api,
    required this.client
  });
  
  final LanguageBackendAPI api;
  final http.Client client;

  Future<Library> getLibrary() => _getData(
    uri: api.getLibrary(),
    builder: (data) => Library.fromJson(data),
  );

  Future<String> updateTitle({required UpdateTitle titleObj}) async {
    Map<String, dynamic> body = titleObj.toJson();
    String jsonString = json.encode(body);
    return _postData(
      uri: api.updateTitle(),
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
          throw Exception('Cards not found');
        default:
          throw Exception('Error fetching cards');
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

final existingVideosRepositoryProvider = Provider<ExistingVideosRepository>((ref) {
  return ExistingVideosRepository(
    api: LanguageBackendAPI(),
    client: http.Client(),
  );
});