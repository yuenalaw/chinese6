class UpdateImage {
  final String videoId;
  final int wordId;
  final int lineChanged;
  final String imagePath;

  UpdateImage({
    required this.videoId,
    required this.wordId,
    required this.lineChanged,
    required this.imagePath,
  });

  Map<String,dynamic> toJson() {
    return {
      'video_id': videoId,
      'word_id': wordId,
      'line_changed': lineChanged,
      'image_path': imagePath,
    };
  }
}