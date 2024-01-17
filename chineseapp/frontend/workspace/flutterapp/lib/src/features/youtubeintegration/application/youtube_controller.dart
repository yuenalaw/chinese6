import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/youtubeintegration/application/youtube_service.dart';
import 'package:flutterapp/src/features/youtubeintegration/domain/queried_video.dart';

class YouTubeController extends StateNotifier<AsyncValue<QueriedVideo>> {
  YouTubeController({required this.youTubeService})
      : super(const AsyncValue.loading());

  Future<void> searchVideo(String vidId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => youTubeService.searchVideo(vidId));
  }

  void clear() {
    state = const AsyncLoading();
  }

  final YouTubeService youTubeService;
}

final youtubeControllerProvider =
    StateNotifierProvider<YouTubeController, AsyncValue<QueriedVideo>>((ref) {
  return YouTubeController(youTubeService: ref.watch(youTubeServiceProvider));
});
