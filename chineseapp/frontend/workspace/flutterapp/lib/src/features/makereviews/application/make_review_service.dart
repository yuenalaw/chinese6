import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/data/review_repository.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_query.dart';
import 'package:flutterapp/src/features/makereviews/domain/reviewed_userword_sentence.dart';
import 'package:flutterapp/src/features/makereviews/domain/search_result.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_image.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_note.dart';
import 'package:flutterapp/src/features/makereviews/domain/user_word_sentence.dart';
import 'package:flutterapp/src/features/makereviews/presentation/fake_data/user_word_sentence_fake.dart';
import 'package:http/http.dart' as http;

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

  Future<List<SearchResult>> fetchImageSearchResults(String query) async {
    var encodedQuery = Uri.encodeComponent(query);
    //var url = Uri.parse('https://www.googleapis.com/customsearch/v1');
    var url = Uri.parse('https://cse.google.com/cse?cx=${dotenv.env['CX_ID']}&q=$encodedQuery&searchType=image&num=3');
    try {
      // var response = await http.get(url, headers: {
      //   'cx': dotenv.env['CX_ID']!, // Replace with your Programmable Search Engine ID
      //   'key': dotenv.env['KEY']!, // Replace with your API key
      //   'q': encodedQuery,
      //   'searchType': 'image',
      //   'num': '3' // Limit the results to the top 3 images
      // });
      var response = await http.get(url);

      var data = jsonDecode(response.body);
      print('Data: $data');
      var items = data['items'] as List;
      final List<SearchResult> searchResults = [];

      for (var item in items) {
        print('Image URL: ${item['link']}');
        searchResults.add(SearchResult(result: item));
      }
      
      return searchResults;
    
    } catch (e) {
      print('Caught error: $e');
      throw Exception('Failed to load search results (images)');
    }
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