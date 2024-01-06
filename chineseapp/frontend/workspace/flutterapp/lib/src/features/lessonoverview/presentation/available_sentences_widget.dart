import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';

class AvailableSentences extends ConsumerWidget {
  const AvailableSentences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<Lesson>>>(allReadyVideoSentencesProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
          ),
        );
      }
    });

    return ref.watch(allReadyVideoSentencesProvider).when(
      data: (lessons) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 5 / 6, // 5/6 of the screen height
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              var lesson = lessons[index];
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
                    // Handle button press
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Start: ${lesson.segment.start}'),
                          Text('${index+1}/${lessons.length}'),
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
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );

  }
}
