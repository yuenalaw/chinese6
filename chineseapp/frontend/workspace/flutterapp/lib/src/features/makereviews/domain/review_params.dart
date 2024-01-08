import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';

class ReviewParams {
  final String word;
  final String videoId;
  final String lineNum;
  final Entry entry;
  final String sentence;

  ReviewParams({
    required this.word,
    required this.videoId,
    required this.lineNum,
    required this.entry,
    required this.sentence,
  });

  int getLineNumAsInt() {
    return int.parse(lineNum);
  }
}