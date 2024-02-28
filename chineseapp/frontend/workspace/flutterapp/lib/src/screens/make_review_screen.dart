import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/pressable_sentence_card_widget.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/presentation/looping_stroke_order_animator_widget.dart';
import 'package:flutterapp/src/features/makereviews/presentation/make_review_steps_widget.dart';

final selectedEntryProvider = StateProvider<Entry?>((ref) => null);


class MakeReviewScreen extends ConsumerWidget {
  final String videoId;
  final int lineNum;
  final String sentence;
  final List<Entry> entries;
  final double start;


  const MakeReviewScreen({Key? key, required this.videoId, required this.lineNum, required this.sentence, required this.entries, required this.start}) : super(key: key);
  
  @override 
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Make Review'),
      ),
      body: SingleChildScrollView( 
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column (
          children: <Widget>[
            PressableSentenceWidget(entries: entries, sentence: sentence, start: start, indexLineNum: lineNum, totalLines: entries.length, onEntrySelected: (entry) {
              ref.read(selectedEntryProvider.notifier).state = entry;
            }),
            Consumer(
              builder: (context, watch, child) {
                final selectedEntry = ref.watch(selectedEntryProvider);
                if (selectedEntry != null) {
                  final reviewParams = ReviewParams(
                    word: selectedEntry.word,
                    videoId: videoId,
                    lineNum: (lineNum+1).toString(),
                    entry: selectedEntry,
                    sentence: sentence,
                  );

                  List<String> characters = selectedEntry.word.split('');

                  final strokeCharacter = RawScrollbar( 
                    thumbColor: Theme.of(context).colorScheme.primary,
                    radius: const Radius.circular(8.0),
                    thickness: 5,
                    child: ListView.builder( 
                      scrollDirection: Axis.horizontal,
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        return Container( 
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: LoopingStrokeOrderAnimator(character: characters[index]),
                        );
                      }
                    )
                  );

                  ref.read(makeReviewControllerProvider(reviewParams)).obtainUserWordSentence();

                  final paddedTimeline = Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                    child: Column(
                      children: [
                        ReviewStepsList(
                          reviewParams: reviewParams,
                        ),
                      ],
                    ),
                  );
                  return SizedBox( 
                    height: MediaQuery.of(context).size.height * 2,
                    child: Column( 
                      children: <Widget>[ 
                        AspectRatio(
                          aspectRatio: 0.9,
                          child: strokeCharacter,
                        ),
                        Expanded(
                          child: SizedBox(
                          height: 200, 
                          child: paddedTimeline,
                        ),
                        ),
                      ]
                    )
                  );
                } else {
                  
                  return const Center( 
                    child: Text('Select a word to review!'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}