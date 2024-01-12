import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';

class TextToImageWidget extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;

  const TextToImageWidget({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  TextToImageState createState() => TextToImageState();
}

class TextToImageState extends State<TextToImageWidget> {
  FlutterTts flutterTts = FlutterTts();
  String selectedImage = '';

  void reset() {
    setState(() {
      selectedImage = '';
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
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == selectedImage, isSentence: false, onCompleted: widget.onCompleted, resetWidget: reset),
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( 
        title: Text(widget.exercise.question),
        actions: [ 
          IconButton(
            onPressed: () async {
              await flutterTts.setLanguage("zh-CN");
              await flutterTts.speak(widget.exercise.correctAnswer);
            }, 
            icon: const Icon(Icons.volume_up),
          )
        ]
      ),
      body: Padding( 
        padding: const EdgeInsets.all(16.0),
        child: Column( 
          children: <Widget>[ 
            Row( 
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ 
                Text( 
                  widget.exercise.testedWord.word,
                  style: const TextStyle(fontSize: 30.0),
                ),
                IconButton( 
                  icon: const Icon(Icons.volume_up),
                  onPressed: () async {
                    await flutterTts.setLanguage("zh-CN");
                    await flutterTts.speak(widget.exercise.testedWord.word);
                  }
                )
              ]
            ),
            Expanded(
              child: GridView.count( 
                crossAxisCount: 3,
                children: List.generate(widget.exercise.availableAnswers.length, (index) {
                  return Padding( 
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector( 
                      onTap: () {
                        setState(() {
                          selectedImage = widget.exercise.availableAnswers[index];
                        });
                      },
                    child: File(widget.exercise.availableAnswers[index]).existsSync() 
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = widget.exercise.availableAnswers[index];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedImage == widget.exercise.availableAnswers[index] ? Colors.blue : Colors.transparent,
                                width: 2.0, // Adjust border width
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // Adjust padding
                              child: Image.file(File(widget.exercise.availableAnswers[index])),
                            ),
                          ),
                        ) 
                      : Image.asset('assets/Error404.gif'),
                    )
                  );
                })
              ),
            ),
            Padding( 
              padding: const EdgeInsets.all(16.0),
              child: selectedImage != ''
              ? ElevatedButton( 
                onPressed: () => _showBottomSheet(context),
                style: ElevatedButton.styleFrom( 
                  foregroundColor: customColourMap['BUTTONS'],
                ),
                child: const Text('Check'),
              ) : Container(),
            )
          ]
        ),
      )
    );
  }

}