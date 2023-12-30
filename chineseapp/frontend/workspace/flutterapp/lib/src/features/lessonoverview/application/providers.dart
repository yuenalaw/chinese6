import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/data/video_repository.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';

final videoProvider = StateProvider<String>((ref) {
  return '';
});

final currentVideoProvider = 
  FutureProvider.autoDispose<Video>((ref) async {
    final videoId = ref.watch(videoProvider);
    final video = 
      await ref.watch(videoRepositoryProvider).getVideo(videoId: videoId);
    return video;
  });