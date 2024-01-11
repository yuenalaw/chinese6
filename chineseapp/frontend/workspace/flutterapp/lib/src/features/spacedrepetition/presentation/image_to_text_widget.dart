import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';

class ImageToTextWidget extends StatefulWidget {
  final Exercise exercise;
  final void Function() onCompleted;

  const ImageToTextWidget({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  ImageToTextState createState() => ImageToTextState();
}

class ImageToTextState extends State<ImageToTextWidget> {
  final FlutterTts flutterTts = FlutterTts();
  String chosenWord = '';

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == chosenWord, isSentence: false, onCompleted: widget.onCompleted),
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
          children: <Widget>[ 
            widget.exercise.reviewCard.imagePath != null && File(widget.exercise.reviewCard.imagePath!).existsSync() 
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(widget.exercise.reviewCard.imagePath!)),
                ) 
              : Image.asset('assets/Error404.gif'),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                children: List.generate(widget.exercise.availableAnswers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      onPressed: () async {
                        setState(() {
                          chosenWord = widget.exercise.availableAnswers[index];
                        });
                        await flutterTts.setLanguage("zh-CN");
                        await flutterTts.speak(chosenWord);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: chosenWord == widget.exercise.availableAnswers[index] ? Colors.blue : Colors.grey),
                      ),
                      child: Text(widget.exercise.availableAnswers[index]),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                color: customColourMap['BUTTONS'], // Add this line
                child: chosenWord != "" ? ElevatedButton(
                  onPressed: () => _showBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: customColourMap['BUTTONS'],
                  ),
                  child: const Text('Check'),
                ) : Container(),
              ),
            )
          ]
        ),
      ),
    );
  }
}
