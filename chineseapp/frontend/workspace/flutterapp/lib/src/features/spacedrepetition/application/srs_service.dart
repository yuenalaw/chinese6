import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/fake_data/fake_cards_today.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/fake_data/fake_context.dart';
import 'package:flutterapp/src/features/spacedrepetition/data/srs_repository.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/cards_today.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/context.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/obtain_context.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/review_card.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/update_review.dart';
import 'package:collection/collection.dart';
import 'dart:math';

import 'package:flutterapp/src/features/spacedrepetition/domain/word.dart';

class SRSService {
  SRSService(this.ref);
  final Ref ref;

  Future<CardsToday> _getCardsToday() async {
    final cardsToday = await ref.read(srsRepositoryProvider).getCardsToday();
    return cardsToday;
    //return CardsToday.fromJson(fakeCardsToday);
  }

  Future<Context> _getContext({required ObtainContext obtainContextObj}) async {
    final context = await ref.read(srsRepositoryProvider).getContext(videoId: obtainContextObj.videoId, lineChanged: obtainContextObj.lineChanged);
    return context;
    //Context.fromJson(fakeContext);
  }

  Future<void> _updateReviews({required List<UpdateReview> updateReviews}) async {
    await ref.read(srsRepositoryProvider).batchUpdateReviews(updateReviewList: updateReviews);
    return;
  }

  Future<CardsToday> getReviewCards() async {
    final cardsToday = await _getCardsToday();
    return cardsToday;
  }

  Future<Context> getContext({required ObtainContext obtainContext}) async {
    final context = await _getContext(obtainContextObj: obtainContext);
    return context;
  }

  Future<void> batchUpdateReviews({required List<Exercise> exercises}) async {
    List<UpdateReview> batchUpdates = [];
    // split the whole list of exercises into specific groups (based per review)
    var groupedExercises = groupBy<Exercise, ReviewCard>(exercises, (exercise) => exercise.reviewCard);
    groupedExercises.forEach((reviewCard, exerciseList) {
      int newQuality = calculateAwardPoints(exerciseList);
      UpdateReview updateReview = UpdateReview( 
        wordId: reviewCard.word.id, 
        lastRepetitions: reviewCard.review.repetitions, 
        prevEaseFactor: reviewCard.review.easeFactor,
        prevWordInterval: reviewCard.review.wordInterval, 
        quality: newQuality,
      );
      batchUpdates.add(updateReview);
    });

    await _updateReviews(updateReviews: batchUpdates);
  }

  /*
  using a scale 1-5, where 5 is perfect retention
  - if all 5 exercises are correct, award 5
  - if 4 exercises are correct, award 4
  - if 3 exercise is correct, award 3
  - if 2 are correct, award 2
  - else, award 1
  */

  int calculateAwardPoints(List<Exercise> exercises) {

    // if length of exercises = 5, means no repeats, aka all correct 

    if (exercises.length <= 6) {
      return 5;
    } else if (exercises.length <= 7) {
      return 4;
    } else if (exercises.length <= 8) {
      return 3;
    } else if (exercises.length <= 9){
      return 2;
    } else {
      return 1;
    }
  }

  Exercise exerciseFillInBlank(ReviewCard reviewCard, Set<ReviewCard> othersToReview) {
    int minCount = min(othersToReview.length, 5);
    List<String> availableAnswers = othersToReview.take(minCount).map((card) => card.word.word).toList();
    // If the reviewCard.word.word is not in the list, remove the first item and add the reviewCard.word.word
    if (!availableAnswers.contains(reviewCard.word.word)) {
      availableAnswers.removeAt(0);
      availableAnswers.add(reviewCard.word.word);
    }
    return Exercise( 
      testedWord: reviewCard.word,
      exerciseType: 1,
      correctAnswer: reviewCard.word.word, // the actual word string
      availableAnswers: List.unmodifiable(availableAnswers),
      question: "Fill in the blank...", // the picture
      reviewCard: reviewCard,
    );
  }

  List<Exercise> exerciseStrokeOrder(ReviewCard reviewCard) {
  List<Exercise> exercises = [];
  for (var character in reviewCard.word.word.runes) {
    exercises.add(
      Exercise( 
        testedWord: Word(id: reviewCard.word.id, pinyin: reviewCard.word.pinyin, word: String.fromCharCode(character)), // current character
        exerciseType: 3,
        correctAnswer: String.fromCharCode(character), // the actual word string
        availableAnswers: List.unmodifiable([]),
        question: "Write the word...", // the picture
        reviewCard: reviewCard,
      ),
    );
  }
  return exercises;
}

  Exercise exercisePictureToWord(ReviewCard reviewCard, Set<ReviewCard> othersToReview) {
    int minCount = min(othersToReview.length, 5);
    List<String> availableAnswers = othersToReview.take(minCount).map((card) => card.word.word).toList();

    // Add the reviewCard.word.word to the list
    if (!availableAnswers.contains(reviewCard.word.word)) {
      availableAnswers.removeAt(0);
      availableAnswers.add(reviewCard.word.word);
    }
    return Exercise( 
      testedWord: reviewCard.word,
      exerciseType: 4,
      correctAnswer: reviewCard.word.word, // the actual word string
      availableAnswers: List.unmodifiable(availableAnswers),
      question: "Match the image...", // the picture
      reviewCard: reviewCard,
    );
  }

  Exercise exerciseTranslateSentence(ReviewCard reviewCard, Set<ReviewCard> othersToReview) {
    int minCount = min(othersToReview.length, 5);
    List<String> availableAnswers = othersToReview.take(minCount).map((card) => card.sentence).toList();

    if (!availableAnswers.contains(reviewCard.sentence)) {
      availableAnswers.removeAt(0);
      availableAnswers.add(reviewCard.sentence);
    }

    return Exercise( 
      testedWord: reviewCard.word,
      exerciseType: 5,
      correctAnswer: reviewCard.sentence, // the actual sentence
      availableAnswers: List.unmodifiable([]),
      question: "Translate...", // the picture
      reviewCard: reviewCard,
    );
  }

  List<Exercise> createExercises(List<ReviewCard> reviewCardsForLesson, Set<String> wordSet, Set<ReviewCard> othersToReview){
    List<Exercise> exercises = reviewCardsForLesson.expand((reviewCard) => [
      exerciseFillInBlank(reviewCard, Set.from(othersToReview)),
      ...exerciseStrokeOrder(reviewCard),
      exercisePictureToWord(reviewCard, Set.from(othersToReview)),
      //exerciseTranslateSentence(reviewCard, Set.from(othersToReview)),
    ]).toList();

    exercises.shuffle();
    return exercises;
  }

  /*
  per card, 5 exercises
  1. listen to sentence, fill in missing word
  2. speak sentence
  3. stroke order
  4. match picture to word
  5. translate sentence

  */
  Future<List<List<Exercise>>> getNewGame() async {
    final cardsToday = await _getCardsToday();
    final wordSet = cardsToday.reviewCards.expand((card) => card.sentence.split('')).toSet();
    final reviewCardsSet = cardsToday.reviewCards.toSet();

    List<List<ReviewCard>> lessons = [];
    for (var i=0; i < cardsToday.reviewCards.length; i += 5) {
      lessons.add(cardsToday.reviewCards.sublist(i, min(i+5, cardsToday.reviewCards.length)));
    }

    List<List<Exercise>> lessonsExercises = [];
    for (List<ReviewCard> lesson in lessons) {
      lessonsExercises.add(createExercises(lesson, wordSet, reviewCardsSet));
    }

    return lessonsExercises;

  }
}

final srsServiceProvider = Provider<SRSService>((ref) {
  return SRSService(ref);
});