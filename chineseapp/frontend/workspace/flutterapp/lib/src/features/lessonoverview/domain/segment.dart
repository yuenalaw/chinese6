import 'sentence.dart';

class Segment {
  final double duration;
  final String segment;
  final Sentence sentences;
  final double start;

  Segment({
    required this.duration,
    required this.segment,
    required this.sentences,
    required this.start
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      duration: json['duration'],
      segment: json['segment'],
      sentences: Sentence.fromJson(json['sentences'] as Map<String, dynamic>),
      start: json['start']
    );
  }
}