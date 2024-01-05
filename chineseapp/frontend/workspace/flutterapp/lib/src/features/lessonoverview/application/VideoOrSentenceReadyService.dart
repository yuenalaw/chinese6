import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/data/video_repository.dart';

/*
This service stores all the 'preparing' videos and sentences 
In the UI, every 30 seconds these get pinged
If ready, then the UI gets updated with a svg notif
*/

class VideoOrSentenceReadyService {
  VideoOrSentenceReadyService({
    required this.videoRepository,
  });
  final VideoRepository videoRepository;
  
  Future<Map<String, dynamic>> isReadyVideo(String videoId) async {
    final videoOrSentence = await videoRepository.getVideo(videoId: videoId);
    return videoOrSentence.fold(
      (l) => {'success': false, 'value': l}, // still waiting
      (r) => {'success': true, 'value': r},
    );
  }

  Future<Map<String, dynamic>> isReadySentence(String videoId, String lineChanged) async {
    final videoOrSentence = await videoRepository.getUpdatedSentence(videoId: videoId, lineChanged: lineChanged);
    return videoOrSentence.fold(
      (l) => {'success': false, 'value': l}, // still waiting
      (r) => {'success': true, 'value': r},
    );
  }
}

final videoOrSentenceReadyProvider = Provider<VideoOrSentenceReadyService>((ref) {
  return VideoOrSentenceReadyService(
    videoRepository: ref.watch(videoRepositoryProvider),
    );
});