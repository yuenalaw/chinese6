import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';

class FillInBlankPage extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;
  
  const FillInBlankPage({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  _FillInBlankState createState() => _FillInBlankState();

}

class _FillInBlankState extends State<FillInBlankPage> {
  final FlutterTts flutterTts = FlutterTts();

  String? selectedWord;

  void reset() {
    setState(() {
      selectedWord = null;
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
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == selectedWord, showTranslation: true, onCompleted: widget.onCompleted, resetWidget: reset),
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
                    widget.exercise.reviewCard.sentence.replaceAll(widget.exercise.testedWord.word, '___'),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Wrap( 
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.exercise.availableAnswers.map((word) {
                return ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      word,
                      style: const TextStyle(fontSize: 16.0), // Increase the font size
                    ),
                  ),
                  selected: selectedWord == word,
                  onSelected: (selected) async {
                    if (selected) {
                      setState(() {
                        selectedWord = word;
                      });
                    }
                    await flutterTts.setLanguage("zh-CN");
                    await flutterTts.speak(word);
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Align( 
              alignment: Alignment.bottomRight,
              child: ElevatedButton( 
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedWord != null ? Colors.green : Colors.grey,
                ),
                onPressed: selectedWord != null ? () {
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