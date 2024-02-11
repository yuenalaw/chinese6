import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/test_stroke_widget.dart';

class StrokeTestPage extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;
  const StrokeTestPage({super.key, required this.exercise, required this.onCompleted});

  @override
  State<StrokeTestPage> createState() => _StrokeTestPageState();
}

class _StrokeTestPageState extends State<StrokeTestPage> {
  FlutterTts flutterTts = FlutterTts();

  int errors = 0;

  void numWrong(int errors) {
    setState(() {
      this.errors = errors;
    });
    _showBottomSheet(context);
  }

  void reset() {
    setState(() {
      errors = 0;
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
          child: ResultWidget(exercise: widget.exercise, isCorrect: errors == 0, showTranslation: false, onCompleted: widget.onCompleted, resetWidget: reset),
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
          mainAxisAlignment: MainAxisAlignment.start, // Aligns the children at the start of the column
          children: <Widget>[ 
            Row( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ 
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      await flutterTts.setLanguage('zh-CN');
                      await flutterTts.speak(widget.exercise.testedWord.word);
                    },
                  ),
                ),
                const SizedBox(width: 16.0), // Adds some space between the arrow button and the word
                Text( 
                  widget.exercise.testedWord.word,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                )
              ]
            ),
            const SizedBox(height: 20),
            TestStrokeWidget(character: widget.exercise.testedWord.word, onCompleted: numWrong),
          ]
        )
      )
    );
  }
}