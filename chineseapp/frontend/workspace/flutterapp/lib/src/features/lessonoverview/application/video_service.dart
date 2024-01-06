import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/file_service.dart';
import 'package:flutterapp/src/features/lessonoverview/data/existing_videos_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/data/makelesson_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/data/video_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/user_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';

class VideoService {
  VideoService(this.ref);
  final Ref ref;

  /*
  For preparing videos, we need to query _getvideosper10s every 10 seconds as long as the length > 0
  For preparing sentences, also query getVideoSentences every 10 seconds as long as the length > 0
  */
  final List<String> preparingVideos = [];
  final Map<String, List<int>> preparingSentences = {};

  Future<Library> _fetchVideos() async {
    final library = await ref.read(existingVideosRepositoryProvider).getLibrary();
    return library;
  }

  Future<void> _updateVideoTitle({required UpdateTitle titleObj}) async {
    await ref.read(existingVideosRepositoryProvider).updateTitle(titleObj: titleObj);
  }

  Future<void> _createNewYoutubeLesson({required YouTubeRequest ytRequest}) async {
    await ref.read(makeLessonRepositoryProvider).postYouTubeRequest(ytRequest: ytRequest);
  }

  Future<String> _readFile({required String filePath}) async {
    return await ref.read(fileServiceProvider).readFile(filePath);
  }

  Future<void> _createNewDisneyLesson({required DisneyRequest disneyRequest, required String filePath}) async {
    final transcript = await _readFile(filePath: filePath);
    disneyRequest = disneyRequest.copyWith(transcript: transcript);
    await ref.read(makeLessonRepositoryProvider).postDisneyRequest(disneyRequest: disneyRequest);
  }

  Future<void> _updateSentence({required UpdateSentence updatedSentenceObj}) async {
    await ref.read(videoRepositoryProvider).updateSentence(updateSentenceObj: updatedSentenceObj);
  }

  Future<Video> _getSpecificVideo({required String videoId}) async {
    final video = await ref.read(videoRepositoryProvider).getVideo(videoId: videoId);
    return video.fold(
      (l) => throw Exception("Video not ready"),
      (r) => r,
    );
  }

  Future<UserSentence> _getUpdatedSentence({required String videoId, required int lineChanged}) async {
    final updatedSentence = await ref.read(videoRepositoryProvider).getUpdatedSentence(videoId: videoId, lineChanged: lineChanged);
    return updatedSentence.fold(
      (l) => Future.value(UserSentence(entries: [], sentence: "Loading...")), 
      (r) => r.toUserSentence(),
    );
  }

  Future<List<Lesson>> getVideoSentences({required String videoId}) async {
    // final video = await _getSpecificVideo(videoId: videoId);
    const encodedVideoJsonResponse = 
    {
        "message": "Successfully obtained video!",
        "video": {
            "keywords_img": [
                {
                    "img": "imageurl",
                    "keyword": "亚洲"
                }
            ],
            "lessons": [
                {
                    "segment": {
                        "duration": 1.291,
                        "segment": "加州留学生的生活",
                        "sentences": {
                            "entries": [
                                {
                                    "pinyin": "jia zhou",
                                    "similarsounds": [
                                        "甲胄",
                                        "甲冑"
                                    ],
                                    "translation": [
                                        [
                                            "加州",
                                            [
                                                "California"
                                            ]
                                        ]
                                    ],
                                    "upos": "PROPN",
                                    "word": "加州"
                                }
                            ],
                            "sentence": "加州留学生的生活"
                        },
                        "start": 10.708
                    },
                    "user_sentence": {
                        "entries": [
                            {
                                "pinyin": "wo",
                                "similarsounds": null,
                                "translation": [
                                    [
                                        "我",
                                        [
                                            "I"
                                        ]
                                    ]
                                ],
                                "upos": "PRON",
                                "word": "我"
                            }
                        ],
                        "sentence": "我爱你"
                    }
                }
            ],
            "video_id": "-acfusFM4d8",
            "source": "YouTube",
            "title": "-acfusFM4d8"
        }
    };
    final video = Video.fromJson(encodedVideoJsonResponse);
    if (video.lessons.isNotEmpty){
      // change sentences if being updated
      for (var i=0; i < video.lessons.length; i++) {
        if (preparingSentences[videoId]?.contains(i) == true) {
          var updatedSentence = await _getUpdatedSentence(videoId: videoId, lineChanged: i);
          video.lessons[i].changeUserSentence(updatedSentence);
          if (updatedSentence.entries.isNotEmpty) {
            // updated sentence has finished
            preparingSentences[videoId]?.remove(i);
          }
        }
      }
    }
    return video.lessons;
  }

  Future<Library> getVideos() async {
    // final library = await _fetchVideos();
    // // if we have the video id that was in preparing videos, but now in library, 
    // //it has loaded
    // preparingVideos.removeWhere((videoId) => library.videos.containsKey(videoId));
    // cachedLibrary = library;
    // return library;
    const mockLibraryJson = {
      "library": [
        {
          "id": "-acfusFM4d8",
          "lesson_data": "[]",
          "lesson_keyword_imgs": "[]",
          "source": "YouTube",
          "title": "-acfusFM4d8"
        }
      ],
      "message": "Successfully obtained library!"
    };
    return Library.fromJson(mockLibraryJson);
  }

  Future<void> updateSentence({required UpdateSentence updatedSentence}) async {
    if (preparingSentences.containsKey(updatedSentence.videoId)) {
      preparingSentences[updatedSentence.videoId]!.add(updatedSentence.lineChanged);
    } else {
      preparingSentences[updatedSentence.videoId] = [updatedSentence.lineChanged];
    }
    await _updateSentence(updatedSentenceObj: updatedSentence);
  }

  Future<void> addToPreparedVideosYT({required YouTubeRequest ytRequest}) async {
    preparingVideos.add(ytRequest.videoId);
    // request backend
    await _createNewYoutubeLesson(ytRequest: ytRequest);
    return Future.value();
  }

  Future<void> addToPreparedVideosDisney(DisneyRequest disneyRequest, String transcriptPath) async {
    preparingVideos.add(disneyRequest.videoId);
    await _createNewDisneyLesson(disneyRequest: disneyRequest, filePath: transcriptPath);
    return Future.value();
  }

  Future<void> updateTitleOfVideo(UpdateTitle updatedTitle) async {
    final library = await _fetchVideos();
    library.setVideoTitle(updatedTitle.videoId, updatedTitle.title);
    // now update to the backend
    await _updateVideoTitle(titleObj: updatedTitle);
  }

}

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService(ref);
});