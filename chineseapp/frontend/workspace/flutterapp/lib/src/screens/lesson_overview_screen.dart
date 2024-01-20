import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/keywords_widget.dart';
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
    return ref.watch(videoOverviewProvider).when(
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
                          var textSpans = <TextSpan>[];
                          for (var entry in entries) {
                            textSpans.add(
                              TextSpan(
                                text: ' ${entry.word} ',
                                style: TextStyle(
                                  fontSize: 20, // Adjust this value as needed
                                  color: Colors.black,
                                  backgroundColor: wordUposMap.containsKey(entry.upos) ? wordUposMap[entry.upos] : wordUposMap['default'],
                                ),
                              ),
                            );
                          }
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewScreen(videoId: widget.videoId, lineNum: index, sentence: lesson.segment.segment, entries: entries, start: lesson.segment.start)));
                              },
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text('Start: ${lesson.segment.start}'),
                                      Text('${index+1}/${video.lessons.length}'),
                                    ],
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      children: textSpans,
                                      style: DefaultTextStyle.of(context).style,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
    );
  }
}