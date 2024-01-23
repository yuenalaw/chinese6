import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/pressable_sentence_card_widget.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/presentation/review_staggered_card_widget.dart';

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
        child: Column (
          children: <Widget>[
            PressableSentenceWidget(entries: entries, sentence: sentence, start: start, indexLineNum: lineNum, totalLines: entries.length, onEntrySelected: (entry) {
              ref.read(selectedEntryProvider.notifier).state = entry;
            }),
            Consumer(
              builder: (context, watch, child) {
                final selectedEntry = ref.watch(selectedEntryProvider);
                // Check if selectedEntry is not null before using it
                if (selectedEntry != null) {
                  return ReviewCardStaggered(reviewParams: ReviewParams(
                    word: selectedEntry.word,
                    videoId: videoId,
                    lineNum: (lineNum+1).toString(),
                    entry: selectedEntry,
                    sentence: sentence,
                  ));
                } else {
                  // Return an empty Container or another widget if selectedEntry is null
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
