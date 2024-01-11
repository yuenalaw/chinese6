import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/simple_review_card_widget.dart';

class ResultWidget extends StatelessWidget {
  final Exercise exercise;
  final bool isCorrect;
  final bool isSentence; 
  final void Function() onCompleted;

  ResultWidget({ required this.exercise, required this.isCorrect, required this.isSentence, required this.onCompleted});

  @override 
  Widget build(BuildContext context) {
    return Container( 
      color: isCorrect ? customColourMap['CORRECT_ANS'] : customColourMap['WRONG_ANS'],
      padding: const EdgeInsets.all(16.0),
      child: Column (
        children: <Widget>[ 
          Icon( 
            isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
            size: 48.0
          ),
          Text( 
            isCorrect ? 'Correct!' : 'Nearly there!',
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
          if (isSentence) 
            Text( 
              exercise.correctAnswer,
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          SimpleReviewCardWidget(reviewCard: exercise.reviewCard),
          Padding( 
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton( 
              onPressed: onCompleted,
              child: const Text('Next'),
            )
          )
        ]
      )
    );
  }

}