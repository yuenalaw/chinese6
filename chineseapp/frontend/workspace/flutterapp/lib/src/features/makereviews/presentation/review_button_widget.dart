import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/domain/reviewed_userword_sentence.dart';

class ReviewButton extends ConsumerWidget {
  final ReviewedUserWordSentence userWordSentence;
  final ReviewParams reviewParams;
  final String note;
  final String imgPath;

  const ReviewButton({Key? key, required this.userWordSentence, required this.reviewParams, required this.note, required this.imgPath}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final makeReviewController = ref.watch(makeReviewControllerProvider(reviewParams));
    return Padding( 
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          if (userWordSentence.isReview && imgPath != "") {
            await makeReviewController.updateExistingReview(prevReview: userWordSentence, note: note, imagePath: imgPath);
          } else if (imgPath != ""){
            await makeReviewController.createNewReview(prevReview: userWordSentence, note: note, imagePath: imgPath);
          }
        },
        child: Text(userWordSentence.isReview ? 'Edit Review' : 'Add Review'),
      ),
    );
  }
}
