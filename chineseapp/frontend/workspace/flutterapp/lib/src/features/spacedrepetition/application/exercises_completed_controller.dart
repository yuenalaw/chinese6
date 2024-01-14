import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompletedLessonNotifier extends StateNotifier<Map<int, bool>> {
  CompletedLessonNotifier() : super({});

  void completedLesson(int index) {
    state = {...state, index:true};
  }
}

final completedLessonProvider = StateNotifierProvider<CompletedLessonNotifier, Map<int, bool>>((ref) {
  return CompletedLessonNotifier();
});
