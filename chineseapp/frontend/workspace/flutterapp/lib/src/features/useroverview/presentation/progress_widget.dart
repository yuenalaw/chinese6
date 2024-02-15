import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressWidget extends ConsumerStatefulWidget {
  final int totalLessons;
  const ProgressWidget({super.key, required this.totalLessons});

  @override
  ConsumerState<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends ConsumerState<ProgressWidget> with SingleTickerProviderStateMixin{

  late final AnimationController _controller;
  late int lessonsDone;
  late int totalLessons;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, // the SingleTickerProviderStateMixin
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonStateData = jsonDecode(prefs.getString('lessonState') ?? '{}');

    // Get today's date
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Check if there's data for today
    if (lessonStateData['date']?.split('T')[0] == today) {
      // If there's data for today, use it to set lessonsDone and totalLessons
      lessonsDone = lessonStateData['maxCompletedLesson'] ?? 0;
      final totalLessons = lessonStateData['totalLessons'] ?? 0;

      _controller.value = lessonsDone / (totalLessons > 0 ? totalLessons : 1);
    } else {
      // If there's no data for today, set lessonsDone and totalLessons to 0
      lessonsDone = 0;
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadProgress(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or some other loading indicator
        } else {
          final lessonsDone = ref.watch(maxCompletedLessonProvider);
          _controller.value = lessonsDone / widget.totalLessons;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical:24.0),
                child: Container(
                  height: 200,
                  width: 200,
                  child: CircularProgressIndicator(
                    strokeWidth: 20,
                    value: _controller.value,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}