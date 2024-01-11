import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';

class SentenceBuilderWidget extends StatefulWidget {
  final Exercise exercise;
  final void Function() onCompleted;
  
  const SentenceBuilderWidget({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  SentenceBuilderState createState() => SentenceBuilderState();

}

class SentenceBuilderState extends State<SentenceBuilderWidget> {
  final FlutterTts flutterTts = FlutterTts();
  List<String> sentence = [];
  List<String> availableWords = [];

  @override 
  void initState() {
    super.initState();
    availableWords = widget.exercise.availableAnswers;
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == sentence.join(''), isSentence: true, onCompleted: widget.onCompleted),
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
      body: Column( 
        children: [ 
          Center(
            child: IconButton(
              onPressed: () async {
                await flutterTts.setLanguage("zh-CN");
                await flutterTts.speak(widget.exercise.correctAnswer);
              }, 
              icon: Icon(Icons.volume_up, size: 50.0), // Adjust the size as needed
            ),
          ),
          Expanded( 
            child: Center( 
              child: Wrap( 
                spacing: 8.0,
                runSpacing: 4.0,
                children: sentence.map((word) {
                  return Chip(
                    label: Text(word),
                    onDeleted: () {
                      setState(() {
                        sentence.remove(word);
                        availableWords.add(word);
                      });
                    },
                  );
                }).toList(),
              )
            )
          ),
          Wrap( 
            spacing: 8.0,
            runSpacing: 4.0,
            children: availableWords.map((word) {
              return OutlinedButton( 
                child: Text(word),
                onPressed: () async {
                  await flutterTts.setLanguage("zh-CN");
                  await flutterTts.speak(word);
                  setState(() {
                    sentence.add(word);
                    availableWords.remove(word);
                  });
                }
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: customColourMap['BUTTONS'], // Add this line
              child: ElevatedButton(
                onPressed: () => _showBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: customColourMap['BUTTONS'],
                ),
                child: const Text('Check'),
              ),
            ),
          )
        ]
      )
    );
  }

}