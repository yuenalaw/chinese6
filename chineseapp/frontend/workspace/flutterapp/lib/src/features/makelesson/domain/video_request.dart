class VideoRequest {
  VideoRequest({
    required this.videoId,
    required this.source,
    required this.forced, // overwrite if exists
    this.transcript,
  });
  final String videoId;
  final String source;
  final String forced;
  final String? transcript;

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'source': source,
      'forced': forced,
      'transcript': transcript,
    };
  }
}