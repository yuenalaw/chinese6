import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/gradient_text_widget.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/keywords_widget.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/transcript_sentence_widget.dart';
import 'package:flutterapp/src/screens/make_review_screen.dart';

class LessonOverviewScreen extends ConsumerStatefulWidget {
    const LessonOverviewScreen({Key? key, required this.videoId}) : super(key: key);
    final String videoId;


  @override
  LessonOverviewScreenState createState() => LessonOverviewScreenState();
}

class LessonOverviewScreenState extends ConsumerState<LessonOverviewScreen > {

  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoOverviewProvider.notifier).getVideoDetails(widget.videoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript'),
      ),
      body: ref.watch(videoOverviewProvider).when(
        data: (videoEither) {
          return videoEither.fold( 
            (pleaseWait) {
              return Text(pleaseWait.message);
            },
            (video) {
            return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
                  child: Column(
                    children: <Widget>[
                      KeywordCarousel(keywordsImg: video.keywordsImg), // Add the carousel at the top
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: video.lessons.length,
                          itemBuilder: (context, index) {
                            var lesson = video.lessons[index];
                            List<Entry> entries = lesson.userSentence?.entries ?? lesson.segment.sentences.entries;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (index == 0) ... [ 
                                  const SizedBox(height: 30.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 45.0),
                                    child: Container( 
                                      alignment: Alignment.centerLeft,
                                      width: MediaQuery.of(context).size.width * 0.5,
                                      child: Align( 
                                        alignment: Alignment.centerLeft,
                                        child: GradientText(
                                          text: video.title, 
                                          gradient: LinearGradient(colors: [Colors.pink.shade200, Colors.pink.shade500]),
                                        ),
                                      )
                                    ), 
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 45.0),
                                    child: Container( 
                                      alignment: Alignment.centerLeft,
                                      child: Text( 
                                        video.channel,
                                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade600),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 45.0),
                                    child: Container( 
                                      alignment: Alignment.centerLeft,
                                      child: const Text( 
                                        'Transcription',
                                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20.0),
                                      )
                                    ),
                                  ),
                                  const SizedBox(height: 10.0),
                                ],

                                GestureDetector( 
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewScreen(
                                      videoId: widget.videoId, lineNum: index, sentence: lesson.segment.segment, 
                                      entries: entries, start: lesson.segment.start)));
                                  },
                                  child: TranscriptSentenceWidget( 
                                    entries: entries,
                                    sentence: lesson.segment.sentences.sentence,
                                    start: lesson.segment.start,
                                    indexLineNum: index,
                                    totalLines: video.lessons.length,
                                  ),
                                ),
                              ],
                            );
                          }
                        )
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      )
    );
  }
}