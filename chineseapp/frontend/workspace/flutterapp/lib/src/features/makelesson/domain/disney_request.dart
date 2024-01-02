class DisneyRequest {
  DisneyRequest({
    required this.videoId,
    required this.transcript,
    required this.source,
    required this.forced, // overwrite if exists
  });
  final String videoId;
  final String transcript;
  final String source;
  final String forced;

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'transcript': transcript,
      'source': source,
      'forced': forced,
    };
  }
}