class UpdateNote {
  final String videoId;
  final int wordId;
  final int lineChanged;
  final String note;

  UpdateNote({
    required this.videoId,
    required this.wordId,
    required this.lineChanged,
    required this.note,
  });

  Map<String,dynamic> toJson() {
    return {
      'video_id': videoId,
      'word_id': wordId,
      'line_changed': lineChanged,
      'note': note,
    };
  }
}