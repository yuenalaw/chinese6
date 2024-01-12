  /*
  per card, three exercises
  1. listen to sentence, make it out of characters
  2. listen to word, get picture
  3. get picture, choose word

  using a scale 1-5, where 5 is perfect retention
  - if all 3 exercises are correct, award 5
  - if 2 exercises are correct, award 4
  - if 1 exercise is correct, award 3
  - if all exercises are wrong first try, but correct second try > 2, award 2
  - else, award 1

  */

import 'package:flutterapp/src/features/spacedrepetition/domain/word.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/review_card.dart';

class Exercise {
  final Word testedWord;
  final int exerciseType;
  final String correctAnswer;
  final String question;
  final ReviewCard reviewCard;
  final List<String> availableAnswers;

  Exercise({
    required this.testedWord,
    required this.exerciseType,
    required this.correctAnswer,
    required this.question,
    required this.reviewCard,
    required this.availableAnswers,
  });
}