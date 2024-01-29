import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/transcript_sentence_widget.dart';
import 'package:flutterapp/src/screens/make_review_screen.dart';

class TranscriptPageView extends StatefulWidget {
  final String videoId;
  final List<Lesson> lessons;
  final PageController pageController;

  const TranscriptPageView({Key? key, required this.videoId, required this.lessons, required this.pageController}) : super(key: key);

  @override 
  _TranscriptPageViewState createState() => _TranscriptPageViewState();
}

class _TranscriptPageViewState extends State<TranscriptPageView> {


  @override 
  Widget build(BuildContext context) {
    return PageView.builder( 
      controller: widget.pageController, 
      itemCount: widget.lessons.length,
      itemBuilder: (context, index) {
        var lesson = widget.lessons[index];
        List<Entry> entries = lesson.userSentence?.entries ?? lesson.segment.sentences.entries;
        return GestureDetector( 
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewScreen(
              videoId: widget.videoId, lineNum: index, sentence: lesson.segment.segment, 
              entries: entries, start: lesson.segment.start)));
          },
          child: Column( 
            children: <Widget>[ 
              const SizedBox(height: 20),
              TranscriptSentenceWidget( 
              entries: entries,
              sentence: lesson.segment.sentences.sentence,
              start: lesson.segment.start,
              indexLineNum: index,
              totalLines: widget.lessons.length,
            ),
            ]
          )
        );
      },
    );
  }
}