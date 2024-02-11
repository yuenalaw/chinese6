import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedLessonNotifier extends StateNotifier<LessonState> {
  CompletedLessonNotifier() : super(LessonState(completedLessons: {}, maxCompletedLesson: 0));

  void completedLesson(int index) async {
    state = LessonState(
      completedLessons: {...state.completedLessons, index: true},
      maxCompletedLesson: max(state.maxCompletedLesson, index+1),
    );

    // Save the state to local storage
    final prefs = await SharedPreferences.getInstance();
    final date = DateTime.now().toIso8601String().split('T')[0]; // day's date
    
    // Retrieve the existing data
    final existingData = jsonDecode(prefs.getString('lessonState') ?? '{}');

    // Check if there's data for today
    if (existingData['date']?.split('T')[0] == date) {
      // If there's data for today, update it
      existingData['maxCompletedLesson'] = state.maxCompletedLesson;
      existingData['completedLessons'] = state.completedLessons;
      existingData['totalLessons'] = state.completedLessons.length;
    } else {
      // If there's no data for today, create it
      existingData['date'] = DateTime.now().toIso8601String();
      existingData['maxCompletedLesson'] = state.maxCompletedLesson;
      existingData['completedLessons'] = state.completedLessons;
      existingData['totalLessons'] = state.completedLessons.length;
    }

    // Store the updated data
    await prefs.setString('lessonState', jsonEncode(existingData));
    
  }
}

class LessonState {
  final Map<int, bool> completedLessons;
  final int maxCompletedLesson;

  LessonState({required this.completedLessons, required this.maxCompletedLesson});
}

final completedLessonProvider = StateNotifierProvider<CompletedLessonNotifier, LessonState>((ref) {
  return CompletedLessonNotifier();
});

final maxCompletedLessonProvider = Provider<int>((ref) {
  return ref.watch(completedLessonProvider).maxCompletedLesson;
});