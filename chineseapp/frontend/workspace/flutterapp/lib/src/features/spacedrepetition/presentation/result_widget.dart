import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:gtext/gtext.dart';
import 'package:lpinyin/lpinyin.dart';

class ResultWidget extends StatelessWidget {
  final Exercise exercise;
  final bool isCorrect;
  final bool showTranslation; 
  final bool showWord;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;
  final void Function() resetWidget;

  ResultWidget({ required this.exercise, required this.isCorrect, required this.showTranslation, required this.showWord, required this.onCompleted, required this.resetWidget});

  @override 
  Widget build(BuildContext context) {
    return ClipRRect( 
      borderRadius: BorderRadius.circular(8.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container( 
          decoration: BoxDecoration(
            color: isCorrect ? customColourMap['CORRECT_ANS'] : customColourMap['WRONG_ANS'],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column (
            children: <Widget>[ 
              Text( 
                isCorrect ? 'Correct!' : 'Nearly there!',
                style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800),
              ),
              if (showTranslation) 
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          GText(
                            exercise.reviewCard.sentence, 
                            toLang: 'en',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                          const SizedBox(height: 16.0), 
                          Text(
                            PinyinHelper.getPinyin(exercise.reviewCard.sentence, separator: " ", format: PinyinFormat.WITH_TONE_MARK),
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center, 
                          ),
                          const SizedBox(height: 16.0), 
                          Text(
                            exercise.reviewCard.sentence,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ],
                      ),
                    ),
                  ),
              Padding( 
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary, // This is the background color
                    ),
                    onPressed: () {
                      resetWidget();
                      onCompleted(exercise, isCorrect);
                      Navigator.pop(context);
                    },
                    child: const Text('Next', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
              if (showWord) 
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          exercise.reviewCard.word.word,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                        SizedBox(height: 16.0), // Add some spacing
                        Text(
                          exercise.reviewCard.note!,
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                      ],
                    ),
                  ),
                ),
            ]
          )
        )
      ]
    )
    );
  }
}