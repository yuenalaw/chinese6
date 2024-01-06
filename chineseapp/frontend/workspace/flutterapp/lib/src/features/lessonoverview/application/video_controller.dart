import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_service.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/disney_request.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_sentence.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/update_title.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/youtube_request.dart';

class AllReadyVideosController extends StateNotifier<AsyncValue<Library>> {
  AllReadyVideosController({ required this.videoService }) : super(const AsyncValue.loading()) {
    getAllReadyVideosFromLibrary();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (videoService.preparingVideos.isNotEmpty) {
        getAllReadyVideosFromLibrary();
      }
    });
  }

  final VideoService videoService;
  late final Timer _timer;

  Future<void> getAllReadyVideosFromLibrary() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => videoService.getVideos()
    );
  }

  @override 
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class AllReadyVideoSentencesController extends StateNotifier<AsyncValue<List<Lesson>>> {
  final VideoService videoService;
  String videoId = '';
  Timer? _timer;

  AllReadyVideoSentencesController({ required this.videoService }) : super(const AsyncValue.loading());

  void updateVideoId(String newVideoId) {
    videoId = newVideoId;
    getAllVideoSentences(videoId: videoId);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (videoService.preparingSentences.isNotEmpty) {
        getAllVideoSentences(videoId: videoId);
      }
    });
  }

  Future<void> getAllVideoSentences({required String videoId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => videoService.getVideoSentences(videoId: videoId)
    );
  }

  @override 
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

final allReadyVideosProvider = 
  StateNotifierProvider<AllReadyVideosController, AsyncValue<Library>>((ref) {
    return AllReadyVideosController(
      videoService: ref.watch(videoServiceProvider),
    );
  });

final allReadyVideoSentencesProvider = 
  StateNotifierProvider<AllReadyVideoSentencesController, AsyncValue<List<Lesson>>>((ref) {
    return AllReadyVideoSentencesController(
      videoService: ref.watch(videoServiceProvider),
    );
  });