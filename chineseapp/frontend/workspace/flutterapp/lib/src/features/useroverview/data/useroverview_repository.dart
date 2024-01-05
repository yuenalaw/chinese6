import 'dart:io';
import 'dart:convert';
import 'package:flutterapp/src/features/useroverview/domain/streak.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/data/api_exception.dart';
import 'package:http/http.dart' as http;

class UserOverviewRepository {
  UserOverviewRepository({
    required this.api,
    required this.client
  });
  
  final LanguageBackendAPI api;
  final http.Client client;

  Future<Streak> getStreak() => _getData(
    uri: api.getStreak(),
    builder: (data) => Streak.fromJson(data),
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
          throw Exception('Cards not found');
        default:
          throw Exception('Error fetching cards');
      }
    } on SocketException catch(_) {
        throw NoInternetConnectionException();
    }
  }
}

// providers used by rest of app

final userOverviewRepositoryProvider = Provider<UserOverviewRepository>((ref) {
  return UserOverviewRepository(
    api: LanguageBackendAPI(),
    client: http.Client(),
  );
});