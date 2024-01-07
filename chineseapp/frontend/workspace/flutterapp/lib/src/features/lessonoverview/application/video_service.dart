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

// to delete
import 'to_delete_fake_data/fake_library.dart';
import 'to_delete_fake_data/fake_video_overview.dart';

class VideoService {
  VideoService(this.ref);
  final Ref ref;

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

  Future<Video> _getSpecificVideo({required String videoId}) async {
    // final video = await ref.read(videoRepositoryProvider).getVideo(videoId: videoId);
    // return video.fold(
    //   (l) => throw Exception("Video not ready"),
    //   (r) => r,
    // );

    return Video.fromJson(fakeVideo);
  }

  Future<UserSentence> _getUpdatedSentence({required String videoId, required int lineChanged}) async {
    final updatedSentence = await ref.read(videoRepositoryProvider).getUpdatedSentence(videoId: videoId, lineChanged: lineChanged);
    return updatedSentence.fold(
      (l) => Future.value(UserSentence(entries: [], sentence: "Loading...")), 
      (r) => r.toUserSentence(),
    );
  }

  Future<Video> getVideoDetails({required String videoId}) async {
    final video = await _getSpecificVideo(videoId: videoId);
    // if (video.lessons.isNotEmpty){
    //   // change sentences if being updated
    //   for (var i=0; i < video.lessons.length; i++) {
    //     var updatedSentence = await _getUpdatedSentence(videoId: videoId, lineChanged: i);
    //     video.lessons[i].changeUserSentence(updatedSentence);
    //   }
    // }
    return video;
  }

  Future<Library> getVideos() async {
    final library = await _fetchVideos();
    return library;
  }

  Future<void> updateSentence({required UpdateSentence updatedSentence, required Video video}) async {
    await _updateSentence(updatedSentenceObj: updatedSentence, video: video);
  }

  Future<void> addToPreparedVideosYT({required YouTubeRequest ytRequest}) async {
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