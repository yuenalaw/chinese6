import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/file_service.dart';
import 'package:flutterapp/src/features/lessonoverview/data/existing_videos_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/data/makelesson_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/data/video_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/please_wait_vid_or_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/user_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';
import 'package:shared_preferences/shared_preferences.dart';


// to delete
import 'to_delete_fake_data/fake_library.dart';
import 'to_delete_fake_data/fake_video_overview.dart';

class VideoService {
  VideoService(this.ref){
    _initialize();
  }
  final Ref ref;
  late Library _currentLib;

  Future<void> _initialize() async {
    await getVideos();
  }

  Future<Library> checkLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? videoIds = prefs.getStringList('videoIds');
    if (videoIds == null) return getCurrentLibrary();
    for (String videoId in videoIds) {
      await handleVideo(videoId);
    }
    return getCurrentLibrary();
  }

  Future<void> handleVideo(String videoId) async {
    try {
      var result = await getVideo(videoId: videoId);
      return result.fold( 
        (pleaseWait) {
          return;
        },
        (video) async {
          await addVideoToLibrary(video);
        }
      );
    } catch (error) {
      return;
    }
  }

  Future<Library> _fetchVideos() async {
    // final library = await ref.read(existingVideosRepositoryProvider).getLibrary();
    // return library;

    return Library.fromJson(fakeLibrary);
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

  Future<void> _updateSentence({required UpdateSentence updatedSentenceObj, required Video video}) async {
    //change frontend obj too
    int lineChanged = updatedSentenceObj.lineChanged;
    video.lessons[lineChanged].changeUserSentence(updatedSentenceObj.toUserSentence());
    ref.read(videoRepositoryProvider).updateSentence(updateSentenceObj: updatedSentenceObj);
  }

  Future<Either<PleaseWaitVidOrSentence, Video>> _getSpecificVideo({required String videoId}) async {
    // final video = await ref.read(videoRepositoryProvider).getVideo(videoId: videoId);
    // return video;

    return Right(Video.fromJson(fakeVideo));
  }

  Future<UserSentence> _getUpdatedSentence({required String videoId, required int lineChanged}) async {
    final updatedSentence = await ref.read(videoRepositoryProvider).getUpdatedSentence(videoId: videoId, lineChanged: lineChanged);
    return updatedSentence.fold(
      (l) => Future.value(UserSentence(entries: [], sentence: "Loading...")), 
      (r) => r.toUserSentence(),
    );
  }

  Future<void> removeVideoIdFromLocalStorage(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? videoIds = prefs.getStringList('videoIds');
    if (videoIds == null) return;
    videoIds.remove(videoId);
    await prefs.setStringList('videoIds', videoIds);
  }

  Future<void> addVideoIdToLocalStorage(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? videoIds = prefs.getStringList('videoIds');
    if (videoIds == null) return;
    videoIds.add(videoId);
    await prefs.setStringList('videoIds', videoIds);
  }

  Future<Either<PleaseWaitVidOrSentence, Video>> getVideo({required String videoId}) async {
    final waitOrVideo = await _getSpecificVideo(videoId: videoId);
    return waitOrVideo;
  }

  Future<Library> getVideos() async {
    final library = await _fetchVideos();
    _currentLib = library;
    return _currentLib;
  }

  Library getCurrentLibrary() {
    return _currentLib;
  }

  Future<Library> addVideoToLibrary(Video video) async {
    // turn video to VideoSimple
    final videoSimple = VideoSimple(id: video.videoId, title: video.title, source: video.source);
    _currentLib.addVideo(videoSimple);
    await removeVideoIdFromLocalStorage(video.videoId);
    return _currentLib;
  }

  Future<void> updateSentence({required UpdateSentence updatedSentence, required Video video}) async {
    await _updateSentence(updatedSentenceObj: updatedSentence, video: video);
  }

  Future<void> addToPreparedVideosYT({required YouTubeRequest ytRequest}) async {
    await addVideoIdToLocalStorage(ytRequest.videoId);
    // request backend
    await _createNewYoutubeLesson(ytRequest: ytRequest);
    return Future.value();
  }

  Future<void> addToPreparedVideosDisney(DisneyRequest disneyRequest, String transcriptPath) async {
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