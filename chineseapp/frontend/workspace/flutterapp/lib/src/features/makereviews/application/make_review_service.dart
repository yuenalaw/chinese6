import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/caching_search_engine.dart';
import 'package:flutterapp/src/features/makereviews/data/review_repository.dart';
import 'package:flutterapp/src/features/makereviews/domain/cse_results.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_query.dart';
import 'package:flutterapp/src/features/makereviews/domain/reviewed_userword_sentence.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_image.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_note.dart';
import 'package:flutterapp/src/features/makereviews/domain/user_word_sentence.dart';
import 'package:flutterapp/src/features/makereviews/presentation/fake_data/user_word_sentence_fake.dart';

class MakeReviewService {
  MakeReviewService(this.ref);
  final Ref ref;

  Future<UserWordSentence> _fetchUserWordSentence({required String word, required String videoId, required String lineNum}) async {
    //final userWordSentence = await ref.read(reviewRepositoryProvider).getUserWordSentence(word: word, videoId: videoId, lineChanged: lineNum);
    //return userWordSentence;
    return UserWordSentence.fromJson(userWordSentenceFake);
  }

  Future<void> _addNewReview({required ReviewQuery reviewQuery}) async {
    await ref.read(reviewRepositoryProvider).makeReview(review: reviewQuery);
    return;
  }

  Future<void> _updateNote({required UpdateNote updateNote}) async {
    await ref.read(reviewRepositoryProvider).updateNote(note: updateNote);
    return;
  }

  Future<void> _updateImage({required UpdateImage updateImage}) async {
    await ref.read(reviewRepositoryProvider).updateImage(image: updateImage);
    return;
  }

  Future<ReviewedUserWordSentence> fetchUserWordSentence({required String word, required String videoId, required String lineNum}) async {
    final userWordSentence = await _fetchUserWordSentence(word: word, videoId: videoId, lineNum: lineNum);
    final reviewedUserWordSentence = ReviewedUserWordSentence(
      id: userWordSentence.id,
      imagePath: userWordSentence.imagePath,
      lineChanged: userWordSentence.lineChanged,
      note: userWordSentence.note,
      sentence: userWordSentence.sentence,
      videoId: userWordSentence.videoId,
      wordId: userWordSentence.wordId,
    );
    return reviewedUserWordSentence;
  }

  Future<ReviewedUserWordSentence> updateReview({required ReviewedUserWordSentence prevReviewDetails, required UpdateNote updateNote, required UpdateImage updateImage}) async {
    if (prevReviewDetails.note != updateNote.note) {
      prevReviewDetails = prevReviewDetails.copyWith(note: updateNote.note);
      await _updateNote(updateNote: updateNote);
    }
    if (prevReviewDetails.imagePath != updateImage.imagePath) {
      prevReviewDetails = prevReviewDetails.copyWith(imagePath: updateImage.imagePath);
      await _updateImage(updateImage: updateImage);
    }
    return prevReviewDetails;
  }

  Future<ReviewedUserWordSentence> addNewReview({required ReviewQuery reviewQuery, required ReviewedUserWordSentence reviewedUserWordSentence}) async {
    await _addNewReview(reviewQuery: reviewQuery);
    final updatedReviewUserWordSentence = ReviewedUserWordSentence(
      id: reviewedUserWordSentence.id,
      imagePath: reviewQuery.imagePath,
      lineChanged: reviewedUserWordSentence.lineChanged,
      note: reviewQuery.note,
      sentence: reviewedUserWordSentence.sentence,
      videoId: reviewedUserWordSentence.videoId,
      wordId: reviewedUserWordSentence.wordId,
    );
    return updatedReviewUserWordSentence;
  }

}

final makeReviewServiceProvider = Provider<MakeReviewService>((ref) {
  return MakeReviewService(ref);
});