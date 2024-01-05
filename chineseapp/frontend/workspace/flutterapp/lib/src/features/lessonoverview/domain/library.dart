class Library {

  const Library([this.videos = const {}]);

  final Map<String, VideoSimple> videos;

  factory Library.fromJson(Map<String, dynamic> json) {
    return Library(
      {
        for (var video in json['library'])
          video['id']: VideoSimple.fromJson(video)
      },
    );
  }
}

class VideoSimple {
  final String id;
  final String title;
  final String source;
  final String transcriptPath;

  VideoSimple({
    required this.id,
    required this.title,
    required this.source,
    this.transcriptPath = "",
  });

  factory VideoSimple.fromJson(Map<String, dynamic> json) {
    return VideoSimple(
      id: json["id"],
      title: json["title"],
      source: json["source"],
      transcriptPath: json["transcript_path"] ?? "",
    );
  }
  
    VideoSimple copyWith({
      String? id,
      String? source,
      String? title,
      String? transcriptPath,
    }) {
      return VideoSimple(
        id: id ?? this.id,
        source: source ?? this.source,
        title: title ?? this.title,
        transcriptPath: transcriptPath ?? this.transcriptPath,
      );
    }
}

// Helper extension to mutate videos in available videos
extension MutableLibrary on Library {
  Library addVideo(VideoSimple video) {
    return Library({...videos, video.id: video});
  }

  Library setVideoTitle(String videoId, String title){
    final VideoSimple? videoToUpdate = videos[videoId];
    
    if (videoToUpdate == null) {
      throw Exception('Video with id $videoId not found');
    }

    final VideoSimple updatedVideo = videoToUpdate.copyWith(title:title);
    return Library({...videos, videoId: updatedVideo});
  }
}