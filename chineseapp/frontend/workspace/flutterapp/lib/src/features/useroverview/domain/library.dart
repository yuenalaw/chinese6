class Library {
  final List<Video> videos;

  Library({
    required this.videos,
  });

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      videos: List<Video>.from(json["library"].map((x) => Video.fromJson(x))),
    );
  }
}

class Video {
  final String id;
  final String title;
  final String source;

  Video({
    required this.id,
    required this.title,
    required this.source,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json["id"],
      title: json["title"],
      source: json["source"],
    );
  }
}