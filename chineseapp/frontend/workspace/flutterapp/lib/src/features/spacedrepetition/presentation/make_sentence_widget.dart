import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/word_game_ui.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/character_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/check_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/disabled_character_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/speaker_widget.dart';

class SentenceBuilderWidget extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;
  
  const SentenceBuilderWidget({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  SentenceBuilderState createState() => SentenceBuilderState();

}

class SentenceBuilderState extends State<SentenceBuilderWidget> {
  final FlutterTts flutterTts = FlutterTts();

  List<WordUi> availableWords = [];
  List<WordUi> sentence = [];

  @override 
  void initState() {
    super.initState();
    availableWords = widget.exercise.availableAnswers.map((word) {
        return WordUi(word, isEnabled: true);
      }).toList();
  }

  void reset() {
    setState(() {
      sentence = [];
      availableWords = widget.exercise.availableAnswers.map((word) {
        return WordUi(word, isEnabled: true);
      }).toList();
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
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == sentence.map((word) => word.text).join(''), isSentence: true, onCompleted: widget.onCompleted, resetWidget: reset),
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
          SpeakerWidget(speech: widget.exercise.correctAnswer),
          Expanded( 
            child: Center( 
              child: Wrap( 
                spacing: 8.0,
                runSpacing: 4.0,
                children: sentence.map((word) {
                  return GestureDetector( 
                    onTap: () {
                      setState(() {
                        sentence.remove(word);
                        word.isEnabled = true;
                      });
                    },
                    child: CharacterWidget( 
                      character: word.text,
                    )
                  );
                }).toList(),
              )
            )
          ),
          Wrap( 
            spacing: 8.0,
            runSpacing: 4.0,
            alignment: WrapAlignment.center,
            children: availableWords.map((word) {
              return GestureDetector(
                onTap: word.isEnabled ? () async {
                  setState(() {
                    sentence.add(word);
                    word.isEnabled = false;
                  });
                  await flutterTts.setLanguage("zh-CN");
                  await flutterTts.speak(word.text);
                } : null,
                child: word.isEnabled ? CharacterWidget(
                  character: word.text,
                ) : DisabledCharacterWidget(character: word.text),
              );
            }).toList(),

          ),
          CheckButton(enabled: sentence.isNotEmpty, onTap:sentence.isNotEmpty ? () => _showBottomSheet(context) : null 
          ),
        ]
      )
    );
  }

}