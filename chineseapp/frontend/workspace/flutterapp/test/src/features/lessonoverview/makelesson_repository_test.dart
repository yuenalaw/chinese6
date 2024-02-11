import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:flutterapp/src/features/lessonoverview/data/makelesson_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';

class MockHttpClient extends Mock implements http.Client {}

final mockPostYtRequest = YouTubeRequest(
  videoId: "-acfusFM4d8", 
  source:"YouTube", 
  forced:"True",
  title: "Title",
  channel: "channel",
  thumbnail: ""
);

final mockPostYtRequestJson = 
{
  "video_id":"-acfusFM4d8", 
  "source": "YouTube",
  "forced":"True",
  "title": "Title",
  "channel": "channel",
  "thumbnail": ""
};

final mockPostDisneyRequest = DisneyRequest(
  videoId: "randomid", 
  transcript: "1\n00:00:00,083 --> 00:00:03,212\n暑假一百零四天\n\n2\n00:00:03,337 --> 00:00:05,714\n新學期開始以前\n\n3\n00:00:05,797 --> 00:00:08,800\n我們可要\n\n4\n00:00:08,884 --> 00:00:11,929\n好好利用這個假期\n\n5\n00:00:12,012 --> 00:00:13,180\n譬如\n\n6\n00:00:13,263 --> 00:00:15,724\n造個火箭啦 和木乃伊搏鬥啦\n\n7\n00:00:15,807 --> 00:00:17,809\n登上艾菲爾鐵塔\n\n8\n00:00:18,268 --> 00:00:20,646\n去探索那些\n前所未有的新事物\n",
  source: "Disney", 
  forced: "False"
);

final mockPostDisneyRequestJson = 
{
  "video_id":"randomid", 
  "transcript": "1\n00:00:00,083 --> 00:00:03,212\n暑假一百零四天\n\n2\n00:00:03,337 --> 00:00:05,714\n新學期開始以前\n\n3\n00:00:05,797 --> 00:00:08,800\n我們可要\n\n4\n00:00:08,884 --> 00:00:11,929\n好好利用這個假期\n\n5\n00:00:12,012 --> 00:00:13,180\n譬如\n\n6\n00:00:13,263 --> 00:00:15,724\n造個火箭啦 和木乃伊搏鬥啦\n\n7\n00:00:15,807 --> 00:00:17,809\n登上艾菲爾鐵塔\n\n8\n00:00:18,268 --> 00:00:20,646\n去探索那些\n前所未有的新事物\n",
  "source": "Disney",
  "forced":"False"
};

void main() {
  test('makelesson repository with for post yt video, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final makeLessonRepository = 
      MakeLessonRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.postYouTubeRequest(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockPostYtRequestJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockPostYtRequestJson)), 200));
    await makeLessonRepository.postYouTubeRequest(ytRequest: mockPostYtRequest);
    verify(() => mockHttpClient.post(
      api.postYouTubeRequest(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockPostYtRequestJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });

  test('makelesson repository with for post yt video, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final makeLessonRepository = 
      MakeLessonRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.postYouTubeRequest(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockPostYtRequestJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockPostYtRequestJson)), 404));
    expect(() async => await makeLessonRepository.postYouTubeRequest(ytRequest: mockPostYtRequest), throwsException);
  });

    test('makelesson repository with for post disney, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final makeLessonRepository = 
      MakeLessonRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.postDisneyRequest(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockPostDisneyRequestJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockPostDisneyRequestJson)), 200));
    await makeLessonRepository.postDisneyRequest(disneyRequest: mockPostDisneyRequest);
    verify(() => mockHttpClient.post(
      api.postDisneyRequest(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockPostDisneyRequestJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });

  test('makelesson repository with for post disney, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final makeLessonRepository = 
      MakeLessonRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.postDisneyRequest(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockPostDisneyRequestJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockPostDisneyRequestJson)), 404));
    expect(() async => await makeLessonRepository.postDisneyRequest(disneyRequest: mockPostDisneyRequest), throwsException);
  });
}