import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/presentation/review_button_widget.dart';

class ReviewCard extends ConsumerWidget {
  final ReviewParams reviewParams;

  const ReviewCard({Key? key, required this.reviewParams}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(makeReviewProvider(reviewParams)).when(
      data: (userWordSentence) {
        return Column(
          children: [
            // Top widget with pinyin, translation, and similar sounds
            Column(
              children: [
                Text(reviewParams.entry.pinyin), // Pinyin
                const Text('Translation'),
                ...reviewParams.entry.getTranslationAsListOfLists().map((t) => Text(t.join(', '))), // Translations
                const Text('Similar Sounds'),
                if (reviewParams.entry.similarSounds != null)
                  ...reviewParams.entry.similarSounds!.map((s) => Container(
                    color: Colors.grey,
                    child: Text(s),
                  )), // Similar sounds with grey background
              ],
            ),
            // Right side with the word
            Text(reviewParams.entry.word, style: const TextStyle(fontSize: 50)), // Massive word
            // Bottom widgets for image and personal note
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                // Handle image capture
              },
            ),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Personal note...',
              ),
            ),
            // Review button
            ReviewButton(isReview: userWordSentence.isReview),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
