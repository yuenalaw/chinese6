class UpdateTitle {
  final String videoId;
  final String title;

  UpdateTitle({required this.videoId, required this.title});

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'title': title,
    };
  }
}