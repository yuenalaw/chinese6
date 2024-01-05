import 'package:flutter_test/flutter_test.dart';
import 'package:flutterapp/src/api/api.dart';
import 'package:flutterapp/src/features/lessonoverview/data/video_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/updated_sentence_returned.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/please_wait_vid_or_sentence.dart';
import './video_lesson_encoded_json.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/segment.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence_callback.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/keyword_img.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/user_sentence.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'dart:convert';
import 'package:either_dart/either.dart';

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
  videoId: "-acfusFM4d8",
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

  /*return {'message': 'Sentence task has been added to the queue', 'callback': task_id}, 202
*/

final mockUpdateSentenceCallback = UpdateSentenceCallback(
  taskId: "taskidfake"
);

final mockUpdateSentenceCallbackJson = 
{"callback": "taskidfake"};

final mockCheckStatusPendingTaskJson = 
{"message": "Sentence task is still pending", "status": "PENDING"};

final mockCheckStatusCompletedTaskJson = 
{"message": "Sentence task is completed", "status": "SUCCESS"};

final mockUpdatedSentenceJson = 
{
    "message": "Successfully obtained updated sentence!",
    "updated_sentence": {
        "entries": [
            {
                "pinyin": "wo",
                "similarsounds": null,
                "translation": [
                    [
                        "我",
                        [
                            "I",
                            "me",
                            "my"
                        ]
                    ]
                ],
                "upos": "PRON",
                "word": "我"
            },
            {
                "pinyin": "ai",
                "similarsounds": null,
                "translation": [
                    [
                        "爱",
                        [
                            "to love",
                            "to be fond of",
                            "to like",
                            "affection",
                            "to be inclined (to do sth)",
                            "to tend to (happen)"
                        ]
                    ]
                ],
                "upos": "VERB",
                "word": "爱"
            },
            {
                "pinyin": "ni",
                "similarsounds": [
                    "泥",
                    "鹂",
                    "鲡",
                    "檪",
                    "霓"
                ],
                "translation": [
                    [
                        "你",
                        [
                            "you (informal, as opposed to courteous 您[nin2])"
                        ]
                    ]
                ],
                "upos": "PRON",
                "word": "你"
            }
        ],
        "sentence": "我爱你"
    }
};
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
    expect(video, isA<Right<PleaseWaitVidOrSentence, Video>>());
  });

  test('repository with mocked http client, failure', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    const videoId = "-acfusFM4d8";
    final videoRepository = 
      VideoRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.video(videoId))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(encodedVideoJson), 404)));
    final video = await videoRepository.getVideo(videoId: videoId);
    expect(video, isA<Left<PleaseWaitVidOrSentence, Video>>());
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
    .thenAnswer((_) async => http.Response(jsonEncode(mockUpdateSentenceCallbackJson), 202));
    await videoRepository.updateSentence(updateSentenceObj: mockUpdateSentence);
    verify(() => mockHttpClient.post(
      api.updateSentence(), 
      headers: any(named: 'headers'),
      body: equals(jsonEncode(mockUpdateSentenceJson)),
      encoding: any(named: 'encoding')
    )).called(1);
  });

  test('lessonoverview repository for get updated sentence, success', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final videoRepository = 
      VideoRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getUpdatedSentence("-acfusFM4d8", 2))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockUpdatedSentenceJson)), 200)));
    final updatedSentenceReturned = await videoRepository.getUpdatedSentence(videoId: "-acfusFM4d8", lineChanged: 2);
    expect(updatedSentenceReturned, isA<Right<PleaseWaitVidOrSentence, UpdatedSentenceReturned>>());
    // expect(updatedSentenceReturned.entries[0].word, "我");
  });

  test('lessonoverview repository for get updated sentence, pending', () async {
    final mockHttpClient = MockHttpClient();
    final api = LanguageBackendAPI();
    final videoRepository = 
      VideoRepository(api: api, client: mockHttpClient);
    when(() => mockHttpClient.get(api.getUpdatedSentence("-acfusFM4d8", 2))).thenAnswer(
        (_) => Future.value(http.Response.bytes(utf8.encode(jsonEncode(mockUpdatedSentenceJson)), 404)));
    final updatedSentenceReturned = await videoRepository.getUpdatedSentence(videoId: "-acfusFM4d8", lineChanged: 2);
    expect(updatedSentenceReturned, isA<Left<PleaseWaitVidOrSentence, UpdatedSentenceReturned>>());
  });
}