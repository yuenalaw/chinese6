class YouTubeRequest {
  YouTubeRequest({
    required this.videoId,
    required this.source,
    required this.forced, // overwrite if exists
    required this.title,
    required this.channel,
    required this.thumbnail,
  });
  final String videoId;
  final String source;
  final String forced;
  final String title;
  final String channel;
  final String thumbnail;

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'source': source,
      'forced': forced,
      'title': title,
      'channel': channel,
      'thumbnail': thumbnail,
    };
  }
}