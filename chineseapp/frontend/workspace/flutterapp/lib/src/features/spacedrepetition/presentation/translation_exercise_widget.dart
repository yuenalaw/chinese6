import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';
import 'package:gtext/gtext.dart';

class TranslatePage extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;
  
  const TranslatePage({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  TranslateState createState() => TranslateState();

}

class TranslateState extends State<TranslatePage> {
  final FlutterTts flutterTts = FlutterTts();

  int selectedIndex = -1;

  void reset() {
    setState(() {
      selectedIndex = -1;
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == selectedIndex.toString(), showTranslation: true, showWord: false, onCompleted: widget.onCompleted, resetWidget: reset),
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( 
        title: Text(widget.exercise.question),
      ),
      body: Padding( 
        padding: const EdgeInsets.all(16.0),
        child: Column( 
          children: [ 
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton( 
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      await flutterTts.setLanguage("zh-CN");
                      await flutterTts.speak(widget.exercise.reviewCard.sentence);
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded( 
                  child: Text( 
                    widget.exercise.reviewCard.sentence,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Wrap( 
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.exercise.availableAnswers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;

                return GestureDetector( 
                  onTap: () async {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: selectedIndex == index 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                          width: 3.0,
                        ),
                      ),
                      margin: const EdgeInsets.all(4.0),
                      child: Card(
                        elevation: 4.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GText(
                            answer,
                            toLang: 'en',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            Align( 
              alignment: Alignment.bottomRight,
              child: ElevatedButton( 
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedIndex != -1 ? Colors.green : Colors.grey,
                ),
                onPressed: selectedIndex != -1 ? () {
                  _showBottomSheet(context);
                } : null,
                child: const Text('Check', style: TextStyle(color: Colors.black)),
              ),
            )
          ],
        )
      ),
    );
  }

}