import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/keyword_img.dart';
import 'package:flutterapp/src/screens/make_review_screen.dart';

class KeywordCarousel extends StatelessWidget {
  final List<KeywordImg> keywordsImg;

  const KeywordCarousel({Key? key, required this.keywordsImg}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox( 
        height: 200,
        child: ListView.builder( 
          scrollDirection: Axis.horizontal,
          itemCount: keywordsImg.length,
          itemBuilder: (context, index) {
            var keywordImg = keywordsImg[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox( 
                width: 160,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Column( 
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[ 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              keywordImg.img,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Image.asset('assets/Error404.gif');
                              }
                            ),
                          ),
                        ),
                        Text(keywordImg.keyword),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        )
      ),
    );
  }
}



class VideoInformation extends ConsumerWidget {
  final String videoId;
  const VideoInformation({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                                Navigator.push(context, MaterialPageRoute(builder: (context) => MakeReviewScreen(videoId: videoId, lineNum: index, sentence: lesson.segment.segment, entries: entries, start: lesson.segment.start)));
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