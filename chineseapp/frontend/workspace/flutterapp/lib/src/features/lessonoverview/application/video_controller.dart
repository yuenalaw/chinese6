import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_service.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/please_wait_vid_or_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';

class AllReadyVideosController extends StateNotifier<AsyncValue<Library>> {
  AllReadyVideosController({ required this.videoService }) : super(const AsyncValue.loading()) {
    getAllReadyVideosFromLibrary();
    startPeriodicCheck();
  }

  final VideoService videoService;

  void startPeriodicCheck() {
    Timer.periodic(const Duration(seconds:30), (Timer t) async { 
      Library newLibrary = await videoService.checkLocalStorage();
      state = AsyncValue.data(newLibrary);
    });
  }

  Future<void> getAllReadyVideosFromLibrary() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => videoService.getVideos()
    );
  }
}

class VideoOverviewController extends StateNotifier<AsyncValue<Either<PleaseWaitVidOrSentence,Video>>> with WidgetsBindingObserver {

  VideoOverviewController({ required this.videoService }) 
    : super(const AsyncValue.loading());
  
  final VideoService videoService;

  Future<void> getVideoDetails(String videoId) async {
    state = const AsyncLoading();
    // state = await AsyncValue.guard(
    //   () => videoService.getVideo(videoId: videoId)
    // );

    videoService.getVideo(videoId: videoId).then((value) => state = AsyncValue.data(value));

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
  StateNotifierProvider<VideoOverviewController, AsyncValue<Either<PleaseWaitVidOrSentence, Video>>>((ref) {
    return VideoOverviewController(
      videoService: ref.watch(videoServiceProvider));
  });