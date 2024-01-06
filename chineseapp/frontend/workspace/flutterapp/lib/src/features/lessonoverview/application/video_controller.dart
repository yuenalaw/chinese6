import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_service.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';

class VideoController extends StateNotifier<AsyncValue<void>> {
  VideoController({required this.videoService})
    : super(const AsyncData(null));

  final VideoService videoService;

  /*
  riverpod async value returns the data, loading or error
  */
  Future<void> getAllReadyVideos() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard( 
      () => videoService.getVideosPer10s()
    );
  }

  Future<void> getAllVideoSentences({required String videoId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => videoService.getVideoSentencesPer10s(videoId: videoId)
    );
  }

  Future<void> updateVideoTitle(String videoId, String title) async {
    state = const AsyncLoading();
    final updatedTitle = UpdateTitle(videoId: videoId, title: title);
    state = await AsyncValue.guard(
      () => videoService.updateTitleOfVideo(updatedTitle),
    );
  }

  Future<void> updateSentence({required String videoId, required int lineChanged, required String sentence}) async {
    state = const AsyncLoading();
    final updatedSentence = UpdateSentence(videoId: videoId, lineChanged: lineChanged, sentence: sentence);
    state = await AsyncValue.guard(
      () => videoService.updateSentence(updatedSentence: updatedSentence),
    );
  }

  Future<void> requestNewYouTubeVid({required String videoId, String forced="False"}) async {
    state = const AsyncLoading();
    final ytRequest = YouTubeRequest(videoId: videoId, source: "YouTube", forced: forced);
    state = await AsyncValue.guard(
      () => videoService.addToPreparedVideosYT(ytRequest: ytRequest),
    );
  }

  Future<void> requestNewDisneyVid({required String videoId, required String transcriptPath, String forced="False"}) async {
    state = const AsyncLoading();
    final disneyRequest = DisneyRequest(videoId: videoId, source: "Disney", transcript: "", forced: forced);
    state = await AsyncValue.guard(
      () => videoService.addToPreparedVideosDisney(disneyRequest, transcriptPath),
    );
  }
}

final videoControllerProvider = 
  StateNotifierProvider<VideoController, AsyncValue<void>>((ref) {
    return VideoController(
      videoService: ref.watch(videoServiceProvider),
    );
  });