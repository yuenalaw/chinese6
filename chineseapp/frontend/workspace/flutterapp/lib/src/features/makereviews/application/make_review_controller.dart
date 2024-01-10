import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_service.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_query.dart';
import 'package:flutterapp/src/features/makereviews/domain/reviewed_userword_sentence.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_image.dart';
import 'package:flutterapp/src/features/makereviews/domain/update_note.dart';

/*
This controller looks at the state of type AsyncValue<ReviewedUserWordSentence> which can be either
loading, data or error
*/
class MakeReviewController extends StateNotifier<AsyncValue<ReviewedUserWordSentence>> {
  ReviewParams reviewParams;

  MakeReviewController({ required this.makeReviewService, required this.reviewParams }): super(const AsyncValue.loading()) {
    obtainUserWordSentence();
  }

  final MakeReviewService makeReviewService;
  Future<void> obtainUserWordSentence() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => makeReviewService.fetchUserWordSentence(word: reviewParams.word, videoId: reviewParams.videoId, lineNum: reviewParams.lineNum)
    );
  }

  Future<void> updateExistingReview({required ReviewedUserWordSentence prevReview, required String note, required String imagePath}) async {
    final updatedNote = UpdateNote(lineChanged: prevReview.lineChanged!, note: note, videoId: prevReview.videoId!, wordId: prevReview.wordId!);
    final updatedImage = UpdateImage(lineChanged: prevReview.lineChanged!, imagePath: imagePath, videoId: prevReview.videoId!, wordId: prevReview.wordId!);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => makeReviewService.updateReview(prevReviewDetails: prevReview, updateNote: updatedNote, updateImage: updatedImage)
    );
    print("state after updating: $state");
  }

  Future<void> createNewReview({required ReviewedUserWordSentence prevReview, required String note, required String imagePath}) async {
    final reviewQuery = ReviewQuery(word: reviewParams.entry.word, pinyin: reviewParams.entry.pinyin, 
    similarWords: reviewParams.entry.similarSounds!, lineChanged: reviewParams.getLineNumAsInt(), 
    videoId: reviewParams.videoId, sentence: reviewParams.sentence, note: note, 
    imagePath: imagePath, translation: reviewParams.entry.getTranslationAsListOfLists());
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => makeReviewService.addNewReview(reviewQuery: reviewQuery, reviewedUserWordSentence: prevReview)
    );
  }
}


final makeReviewProvider = 
  StateNotifierProvider.family<MakeReviewController, AsyncValue<ReviewedUserWordSentence>, ReviewParams>((ref, reviewParams) {
    return MakeReviewController(
      makeReviewService: ref.watch(makeReviewServiceProvider),
      reviewParams: reviewParams,
    );
  });

/* watches the controller, not its state */
final makeReviewControllerProvider = Provider.family<MakeReviewController, ReviewParams>((ref, reviewParams) {
  return MakeReviewController(
    makeReviewService: ref.watch(makeReviewServiceProvider),
    reviewParams: reviewParams,
  );
});

