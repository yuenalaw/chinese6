import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:flutterapp/src/features/useroverview/data/useroverview_repository.dart';
import 'package:flutterapp/src/features/useroverview/domain/streak.dart';

import '../../constants/headers.dart';

class MockHttpClient extends Mock implements http.Client {} 

const mockStreakJson = 
{
    "message": "Successfully obtained streak!",
    "streak": 1
};

void main() {
  test('user overview repository with get streak, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final userOverviewRepository = 
      UserOverviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getStreak(), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockStreakJson)), 200)));
    final streak = await userOverviewRepository.getStreak();

    expect(streak, isA<Streak>());
    expect(streak.current, 1);
  });

  test('user overview repository with get streak, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final userOverviewRepository = 
      UserOverviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getStreak(), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockStreakJson)), 404)));
    expect(() async => await userOverviewRepository.getStreak(), throwsException);
  });
}