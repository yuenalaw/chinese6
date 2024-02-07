import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/video.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/gradient_text_widget.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/keywords_widget.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/transcript_sentence_widget.dart';
import 'package:flutterapp/src/screens/make_review_screen.dart';

class LessonOverviewScreen extends StatefulWidget {
    const LessonOverviewScreen({Key? key, required this.video}) : super(key: key);
    final Video video;


  @override
  LessonOverviewScreenState createState() => LessonOverviewScreenState();
}

class LessonOverviewScreenState extends State<LessonOverviewScreen > {

  @override
  Widget build(BuildContext context) {
    DraggableScrollableController draggableScrollableController = DraggableScrollableController();
    return SizedBox.expand( 
      child: DraggableScrollableSheet( 
        controller: draggableScrollableController,
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: 0.8,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration( 
              color: Theme.of(context).colorScheme.primary, 
              border: Border.all(color: Colors.white, width: 5),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
            ),
            child: Column( 
              children: <Widget>[
                IconButton( 
                  icon: Icon(Icons.drag_handle, color: Colors.white),
                  onPressed: () {
                    draggableScrollableController.reset();
                  }
                ),
                Expanded( 
                  child: ListView.builder( 
                  controller: scrollController,
                  itemCount: widget.video.lessons.length,
                  itemBuilder: (BuildContext context, int index) {
                    var lesson = widget.video.lessons[index];
                    return Column( 
                      children: <Widget>[ 
                        if (index == 0) ... [ 
                          KeywordCarousel(keywordsImg: widget.video.keywordsImg), // Add the carousel at the top
                          const SizedBox(height: 15.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 45.0),
                            child: Container( 
                              alignment: Alignment.centerLeft,
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Align( 
                                alignment: Alignment.centerLeft,
                                child:  GradientText(
                                  text: widget.video.title, 
                                  gradient: LinearGradient(colors: [Colors.lightBlue.shade300, Colors.lightBlue.shade600]),                                ),
                              )
                            ), 
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 45.0),
                            child: Container( 
                              alignment: Alignment.centerLeft,
                              child: Text( 
                                widget.video.channel,
                                style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey[800], fontSize: 16.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 45.0),
                            child: Container( 
                              alignment: Alignment.centerLeft,
                              child: const Text( 
                                'Transcription',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20.0),
                              )
                            ),
                          ),
                          const SizedBox(height: 10.0),
                        ],
                        GestureDetector( 
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewScreen(
                              videoId: widget.video.videoId, lineNum: index, sentence: lesson.segment.segment, 
                              entries: lesson.userSentence?.entries ?? lesson.segment.sentences.entries, start: lesson.segment.start)));
                          },
                          child: TranscriptSentenceWidget( 
                            entries: lesson.userSentence?.entries ?? lesson.segment.sentences.entries,
                            sentence: lesson.segment.sentences.sentence,
                            start: lesson.segment.start,
                            indexLineNum: index,
                            totalLines: widget.video.lessons.length,
                          ),
                        ),
                      ],
                    );
                  }
                )
                )
              ]
            )
          );
        }
      )
    );
  }
}