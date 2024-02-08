import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompletedLessonNotifier extends StateNotifier<Map<int, bool>> {
  CompletedLessonNotifier() : super({});
  int _maxCompletedLesson = 0;

  void completedLesson(int index) {
    state = {...state, index:true};
    _maxCompletedLesson = max(_maxCompletedLesson, index);
  }

  int get maxCompletedLesson {
    return _maxCompletedLesson;
  }
}

final completedLessonProvider = StateNotifierProvider<CompletedLessonNotifier, Map<int, bool>>((ref) {
  return CompletedLessonNotifier();
});

final maxCompletedLessonProvider = Provider<int>((ref) {
  return ref.watch(completedLessonProvider.notifier).maxCompletedLesson;
});