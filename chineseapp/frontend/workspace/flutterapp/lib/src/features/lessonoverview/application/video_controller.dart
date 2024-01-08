import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_service.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';

class AllReadyVideosController extends StateNotifier<AsyncValue<Library>> {
  AllReadyVideosController({ required this.videoService }) : super(const AsyncValue.loading()) {
    getAllReadyVideosFromLibrary();
  }

  final VideoService videoService;

  Future<void> getAllReadyVideosFromLibrary() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => videoService.getVideos()
    );
  }
}

class VideoOverviewController extends StateNotifier<AsyncValue<Video>> with WidgetsBindingObserver {
  String videoId;

  VideoOverviewController({ required this.videoService, required this.videoId }) 
    : super(const AsyncValue.loading()) {
      getVideoDetails();  
  }
  
  final VideoService videoService;

  Future<void> getVideoDetails() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => videoService.getVideoDetails(videoId: videoId)
    );
  }

}


class VideoController extends StateNotifier<AsyncValue<void>> {
  VideoController({required this.videoService})
    : super(const AsyncData(null));

  final VideoService videoService;

  Future<void> updateVideoTitle(String videoId, String title) async {
    state = const AsyncLoading();
    final updatedTitle = UpdateTitle(videoId: videoId, title: title);
    state = await AsyncValue.guard(
      () => videoService.updateTitleOfVideo(updatedTitle),
    );
  }

  Future<void> updateSentence({required Video video, required String videoId, required int lineChanged, required String sentence}) async {
    state = const AsyncLoading();
    final updatedSentence = UpdateSentence(videoId: videoId, lineChanged: lineChanged, sentence: sentence);
    state = await AsyncValue.guard(
      () => videoService.updateSentence(updatedSentence: updatedSentence, video: video),
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

final allReadyVideosProvider = 
  StateNotifierProvider<AllReadyVideosController, AsyncValue<Library>>((ref) {
    return AllReadyVideosController(
      videoService: ref.watch(videoServiceProvider),
    );
  });

final videoOverviewProvider = 
  StateNotifierProvider.family<VideoOverviewController, AsyncValue<Video>, String>((ref, videoId) {
    return VideoOverviewController(
      videoService: ref.watch(videoServiceProvider),
      videoId: videoId,
    );
  });
