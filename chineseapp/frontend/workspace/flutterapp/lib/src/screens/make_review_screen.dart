import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/pressable_sentence_card_widget.dart';
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
    DraggableScrollableController draggableScrollableController = DraggableScrollableController();

    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Make Review'),
      ),
      body: SingleChildScrollView( 
        physics: NeverScrollableScrollPhysics(),
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
                    radius: Radius.circular(8.0),
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

                  final paddedTimeline = Padding( 
                      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
                      child: ReviewStepsList(reviewParams: reviewParams) 
                    );
                  
                  return Container( 
                    height: MediaQuery.of(context).size.height,
                    child: FractionallySizedBox( 
                      heightFactor: 0.8,
                      child: Stack( 
                          children: <Widget>[ 
                            strokeCharacter,
                            DraggableScrollableSheet(
                              controller: draggableScrollableController,
                              initialChildSize: 0.4,
                              minChildSize: 0.4,
                              maxChildSize: 1,
                              builder: (BuildContext context, ScrollController scrollController) {
                                return Stack( 
                                  children: [
                                    Container(
                                      decoration: BoxDecoration( 
                                        color: Theme.of(context).colorScheme.background,
                                        border: Border.all(color: Colors.white, width: 3.0),
                                        borderRadius: const BorderRadius.only( 
                                          topLeft: Radius.circular(24.0),
                                          topRight: Radius.circular(24.0),
                                        ),
                                      ),
                                      child: SingleChildScrollView( 
                                        controller: scrollController,
                                        child: paddedTimeline,
                                      )
                                    ),
                                    Positioned( 
                                      right: 16.0, 
                                      top: 16.0,
                                      child: Stack( 
                                        alignment: Alignment.center, 
                                        children: <Widget>[ 
                                          Container( 
                                            width: 36.0,
                                            height: 36.0,
                                            decoration: BoxDecoration( 
                                              color: Theme.of(context).colorScheme.onSurface,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          IconButton( 
                                            icon: Icon(Icons.close, color: Colors.white),
                                            onPressed: () {
                                              draggableScrollableController.reset();
                                            }
                                          )
                                        ]
                                      )
                                    )
                                  ],
                                );
                              }
                            ),
                          ]
                        )
                      ),
                    );
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