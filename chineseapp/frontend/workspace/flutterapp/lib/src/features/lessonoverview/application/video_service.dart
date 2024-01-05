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

class Tuple {
  final String videoId;
  final int lineChanged;

  Tuple(this.videoId, this.lineChanged);

  @override 
  bool operator ==(Object other) => 
    identical(this, other) || 
    other is Tuple && 
      runtimeType == other.runtimeType &&
      videoId == other.videoId &&
      lineChanged == other.lineChanged;
  
  @override 
  int get hashCode => videoId.hashCode ^ lineChanged.hashCode;
}

class VideoService {
  VideoService(this.ref);
  final Ref ref;

  /*
  For preparing videos, we need to query _fetchVideos every 10 seconds as long as the length > 0
  For preparing sentences, also query getVideoSentences every 10 seconds as long as the length > 0
  */
  final List<String> preparingVideos = [];
  final List<Tuple> preparingSentences = [];

  // only call this every 10s if there are videos in preparingVideos
  Future<Library> _fetchVideos() async {
    final library = await ref.read(existingVideosRepositoryProvider).getLibrary();
    // if we have the video id that was in preparing videos, but now in library, 
    //it has loaded
    preparingVideos.removeWhere((videoId) => library.videos.containsKey(videoId));
    return library;
  }

  Future<void> _updateVideoTitle({required String videoId, required String title}) async {
    final titleObj = UpdateTitle(videoId: videoId, title: title);
    await ref.read(existingVideosRepositoryProvider).updateTitle(titleObj: titleObj);
  }

  Future<void> _createNewYoutubeLesson({required VideoSimple video, String forced = "False"}) async {
    final ytRequest = YouTubeRequest(videoId: video.id, source: video.source, forced: forced);
    await ref.read(makeLessonRepositoryProvider).postYouTubeRequest(ytRequest: ytRequest);
  }

  Future<void> _createNewDisneyLesson({required VideoSimple video, required String transcriptPath, String forced = "False"}) async {
    final disneyTranscript = await ref.read(fileServiceProvider).readFile(transcriptPath);
    final disneyRequest = DisneyRequest(videoId: video.id, transcript: disneyTranscript, source: video.source, forced: forced);
    await ref.read(makeLessonRepositoryProvider).postDisneyRequest(disneyRequest: disneyRequest);
  }

  Future<void> _updateSentence({required String videoId, required int lineChanged, required String sentence}) async {
    final updateSentenceObj = UpdateSentence(videoId: videoId, lineChanged: lineChanged, sentence: sentence);
    preparingSentences.add(Tuple(videoId, lineChanged));
    await ref.read(videoRepositoryProvider).updateSentence(updateSentenceObj: updateSentenceObj);
  }

  Future<Video> _getSpecificVideo({required String videoId}) async {
    final video = await ref.read(videoRepositoryProvider).getVideo(videoId: videoId);
    return video.fold(
      (l) => throw Exception("Video not ready"),
      (r) => r,
    );
  }

  Future<List<Lesson>> getVideoSentences({required String videoId}) async {
    final video = await _getSpecificVideo(videoId: videoId);
    if (video.lessons.isNotEmpty){
      // change sentences if being updated
      for (var i=0; i < video.lessons.length; i++) {
        var tuple = Tuple(videoId, i);
        if (preparingSentences.contains(tuple)) {
          var updatedSentence = await getUpdatedSentence(videoId: videoId, lineChanged: i);
          video.lessons[i].changeUserSentence(updatedSentence);
          if (updatedSentence.entries.isNotEmpty) {
            // updated sentence has finished
            preparingSentences.remove(tuple);
          }
        }
      }
    }
    return video.lessons;
  }

  Future<void> updateSentence({required String videoId, required int lineChanged, required String sentence}) async {
    preparingSentences.add(Tuple(videoId, lineChanged));
    await _updateSentence(videoId: videoId, lineChanged: lineChanged, sentence: sentence);
  }

  Future<UserSentence> getUpdatedSentence({required String videoId, required int lineChanged}) async {
    final updatedSentence = await ref.read(videoRepositoryProvider).getUpdatedSentence(videoId: videoId, lineChanged: lineChanged);
    return updatedSentence.fold(
      (l) => Future.value(UserSentence(entries: [], sentence: "Loading...")), 
      (r) => r.toUserSentence(),
    );
  }

  Future<void> addToPreparedVideos(VideoSimple video) async {
    preparingVideos.add(video.id);
    // request backend
    if (video.source == "YouTube"){
      await _createNewYoutubeLesson(video: video);
    } else if (video.source == "Disney"){
      if (video.transcriptPath == ""){
        return Future.value();
      } 
      await _createNewDisneyLesson(video: video, transcriptPath: video.transcriptPath);
    }
    return Future.value();
  }

  Future<void> updateTitleOfVideo(String videoId, String title) async {
    final library = await _fetchVideos();
    library.setVideoTitle(videoId, title);
    // now update to the backend
    await _updateVideoTitle(videoId: videoId, title: title);
  }

}

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService(ref);
});