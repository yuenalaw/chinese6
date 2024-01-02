import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutterapp/src/features/lessonoverview/data/video_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import './video_lesson_encoded_json.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/segment.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/keyword_img.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/user_sentence.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

class MockHttpClient extends Mock implements http.Client {} 

String encodedVideoJson = encodedVideoJsonResponse;

final expectedVideoFromJson = Video(
  lessons: [
    Lesson(
      segment: Segment(
        duration: 1.291,
        segment: "加州留学生的生活",
        start: 10.708,
        sentences: Sentence(
          entries: [
            Entry(
              pinyin: "jia zhou",
              similarSounds: [
                "甲胄",
                "甲冑"
              ],
              translation: [
                Translation( 
                  word: "加州",
                  translations: [
                    "California",
                  ]
                ),
              ],
              upos: "PROPN",
              word: "加州"
            ),
          ],
          sentence: "加州留学生的生活"
        ),
      ),
      userSentence: UserSentence(
        entries: [
          Entry(
            pinyin: "wo",
            similarSounds: null,
            translation: [
              Translation(
                word: "我",
                translations: [
                  "I"
                ]
              ),
            ],
            upos: "PRON",
            word: "我"
          ),
        ],
        sentence: "我爱你"
      ),
    ),
  ],
  source: "YouTube",
  title: "-acfusFM4d8",
  keywordsImg: [
    KeywordImg(
      img: "imageurl",
      keyword: "亚洲"
    ),
    ]
);

final mockUpdateSentenceJson = 
{"video_id":"-acfusFM4d8", "line_changed":2, "sentence":"我爱你"};

final mockUpdateSentence = UpdateSentence(
  videoId: "-acfusFM4d8", 
  lineChanged: 2, 
  sentence: "我爱你"
);

void main() {
  test('repository with mocked http client, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    const videoId = "-acfusFM4d8";
    final videoRepository = 
      VideoRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.video(videoId))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(encodedVideoJson), 200)));
    final video = await videoRepository.getVideo(videoId: videoId);

    expect(video.lessons[0].segment.segment, "加州留学生的生活");
  });

  test('repository with mocked http client, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    const videoId = "-acfusFM4d8";
    final videoRepository = 
      VideoRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.video(videoId))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(encodedVideoJson), 404)));
    expect(() async => await videoRepository.getVideo(videoId: videoId), throwsException);
  });

  test('lessonoverview repository with for update sentence, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final videoRepository = 
      VideoRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.post(
      api.updateSentence(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateSentenceJson)),
      encoding: any(named: 'encoding')
    ))
    .thenAnswer((_) async => http.Response.bytes(utf8.encode(jsonEncode(mockUpdateSentenceJson)), 200));
    await videoRepository.updateSentence(updateSentenceObj: mockUpdateSentence);
    verify(() => mockHttpClient.post(
      api.updateSentence(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateSentenceJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });
}