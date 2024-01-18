import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutterapp/src/features/lessonoverview/data/existing_videos_repository.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import '../../constants/headers.dart';
import 'mock_library_encoded_json.dart';

class MockHttpClient extends Mock implements http.Client {} 

const expectedLibraryFromJson = mockLibraryJson;

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
    final existingVideosRepository = 
      ExistingVideosRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getLibrary(), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(expectedLibraryFromJson)), 200)));
    final library = await existingVideosRepository.getLibrary();

    expect(library, isA<Library>());
    expect(library.videos.keys.first, "-acfusFM4d8");
    expect(library.videos.length, 1);
  });

  test('user overview repository with get videos, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final existingVideosRepository = 
      ExistingVideosRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getLibrary(), headers: headers)).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockLibraryJson)), 404)));
    expect(() async => await existingVideosRepository.getLibrary(), throwsException);
  });

  test('user overview repository with for update video title, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final existingVideosRepository = 
      ExistingVideosRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.updateTitle(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateTitleJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockUpdateTitleJson)), 200));
    await existingVideosRepository.updateTitle(titleObj: mockUpdateTitle);
    verify(() => mockHttpClient.post(
      api.updateTitle(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateTitleJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });
}