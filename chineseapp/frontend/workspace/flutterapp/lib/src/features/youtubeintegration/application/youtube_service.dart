import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/youtubeintegration/domain/queried_video.dart';
import 'package:youtube_api_client/youtube_api.dart';

class YouTubeService {
  YouTubeService(this.ref);
  final Ref ref;
  static final String _key = dotenv.env['KEY']!;
  final YoutubeApi youtubeApi = YoutubeApi(_key);

  Future<QueriedVideo> searchVideo(String vidId) async {
    try {
      List<ApiResult> results = await youtubeApi.searchVideosById([vidId],
      parts: {
        VideoPart.snippet,
        VideoPart.contentDetails,
      });
      List<YoutubeVideo> youtubeVideos = results.cast<YoutubeVideo>();
      if (youtubeVideos.isEmpty) {
        return QueriedVideo();
      }
      for (var result in youtubeVideos) {
        if (result.contentDetails!.caption == VideoCaption.closedCaption){
          return QueriedVideo( 
            vidId: vidId,
            title: result.snippet!.title,
            channel: result.snippet!.channelTitle,
            thumbnail: result.snippet!.thumbnails![ThumbnailResolution.default_]?.url,
          );
        }
      }
      return QueriedVideo();
    } catch (e) {
      print('Error fetching video data: $e');
      return QueriedVideo();
    }

  }
}

final youTubeServiceProvider = Provider<YouTubeService>((ref) {
  return YouTubeService(ref);
});