class YouTubeRequest {
  YouTubeRequest({
    required this.videoId,
    required this.source,
    required this.forced, // overwrite if exists
  });
  final String videoId;
  final String source;
  final String forced;

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'source': source,
      'forced': forced,
    };
  }
}