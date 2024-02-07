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
  - if all 3 exercises are correct, award 5
  - if 2 exercises are correct, award 4
  - if 1 exercise is correct, award 3
  - if all exercises are wrong first try, but correct second try > 2, award 2
  - else, award 1
  */

  int calculateAwardPoints(List<Exercise> exercises) {

    // if length of exercises = 3, means no repeats, aka all correct 

    if (exercises.length == 3) {
      return 5;
    } else if (exercises.length <= 4) {
      return 4;
    } else if (exercises.length <= 5) {
      return 3;
    } else if (exercises.length <= 6){
      return 2;
    } else {
      return 1;
    }
  }

  Exercise exerciseCreateSentence(ReviewCard reviewCard, Set<String> wordSet) {
    List<String> availableCharacters = reviewCard.sentence.split('');

    // smaller of no. of remaining chars in wordSet and no. characters required to reach 20
    int randomCharsToAdd = min(wordSet.length - availableCharacters.length, 20 - availableCharacters.length);
    
    while (availableCharacters.length < 20 && randomCharsToAdd > 0) {
      var potentialCharacter = (wordSet.toList()..shuffle()).first;
      if (!availableCharacters.contains(potentialCharacter)) {
        availableCharacters.add(potentialCharacter);
        randomCharsToAdd--;
      }
    }

    availableCharacters.shuffle();
    
    return Exercise( 
      testedWord: reviewCard.word,
      exerciseType: 1,
      correctAnswer: reviewCard.sentence, // re-create sentence
      availableAnswers: List.unmodifiable(availableCharacters),
      question: "Re-create the sentence",
      reviewCard: reviewCard,
    );
  }

  Exercise exerciseWordToPicture(ReviewCard reviewCard, Set<ReviewCard> othersToReview) {
    int minCount = min(othersToReview.length, 5);
    List<String> availableAnswers = othersToReview.take(minCount).map((card) => card.imagePath!).toList();
    // Add the reviewCard.word.word to the list
    if (!availableAnswers.contains(reviewCard.imagePath)) {
      availableAnswers.add(reviewCard.imagePath!);
    }
    return Exercise( 
      testedWord: reviewCard.word,
      exerciseType: 2,
      correctAnswer: reviewCard.imagePath!, // get picture
      availableAnswers: List.unmodifiable(availableAnswers),
      question: "Match the word", // the actual word string
      reviewCard: reviewCard,
    );
  }

  Exercise exercisePictureToWord(ReviewCard reviewCard, Set<ReviewCard> othersToReview) {
    int minCount = min(othersToReview.length, 5);
    List<String> availableAnswers = othersToReview.take(minCount).map((card) => card.word.word).toList();

    // Add the reviewCard.word.word to the list
    if (!availableAnswers.contains(reviewCard.word.word)) {
      availableAnswers.add(reviewCard.word.word);
    }
    return Exercise( 
      testedWord: reviewCard.word,
      exerciseType: 3,
      correctAnswer: reviewCard.word.word, // the actual word string
      availableAnswers: List.unmodifiable(availableAnswers),
      question: "Match the image", // the picture
      reviewCard: reviewCard,
    );
  }

  List<Exercise> createExercises(List<ReviewCard> reviewCardsForLesson, Set<String> wordSet, Set<ReviewCard> othersToReview){
    List<Exercise> exercises = reviewCardsForLesson.expand((reviewCard) => [
      exerciseCreateSentence(reviewCard, wordSet),
      exerciseWordToPicture(reviewCard, Set.from(othersToReview)),
      exercisePictureToWord(reviewCard, Set.from(othersToReview)),
    ]).toList();

    exercises.shuffle();
    return exercises;
  }

  /*
  per card, three exercises
  1. listen to sentence, make it out of characters
  2. listen to word, get picture
  3. get picture, choose word

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