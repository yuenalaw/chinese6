import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:flutterapp/src/features/useroverview/data/useroverview_repository.dart';
import 'package:flutterapp/src/features/useroverview/domain/library.dart';
import 'package:flutterapp/src/features/useroverview/domain/streak.dart';
import 'package:flutterapp/src/features/useroverview/domain/update_title.dart';
import 'mock_library_encoded_json.dart';

class MockHttpClient extends Mock implements http.Client {} 

const expectedLibraryFromJson = mockLibraryJson;

const mockStreakJson = 
{
    "message": "Successfully obtained streak!",
    "streak": 1
};

final mockUpdateTitle = UpdateTitle(
  videoId: "-acfusFM4d8",
  title: "new title",
);

const mockUpdateTitleJson = 
{
  "video_id":"-acfusFM4d8", 
  "title":"new title"
};

void main() {
  test('user overview repository with get videos, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final userOverviewRepository = 
      UserOverviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getLibrary())).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(expectedLibraryFromJson)), 200)));
    final library = await userOverviewRepository.getLibrary();

    expect(library, isA<Library>());
    expect(library.videos[0].id, "-acfusFM4d8");
    expect(library.videos.length, 1);
  });

  test('user overview repository with get videos, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final userOverviewRepository = 
      UserOverviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getLibrary())).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockLibraryJson)), 404)));
    expect(() async => await userOverviewRepository.getLibrary(), throwsException);
  });

  test('user overview repository with get streak, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final userOverviewRepository = 
      UserOverviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getStreak())).thenAnswer(
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
    when(() => mockHttpClient.get(api.getStreak())).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockStreakJson)), 404)));
    expect(() async => await userOverviewRepository.getStreak(), throwsException);
  });

  test('user overview repository with for update video title, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final userOverviewRepositoryRepository = 
      UserOverviewRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.updateTitle(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateTitleJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockUpdateTitleJson)), 200));
    await userOverviewRepositoryRepository.updateTitle(titleObj: mockUpdateTitle);
    verify(() => mockHttpClient.post(
      api.updateTitle(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateTitleJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });
}