import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/srs_controller.dart';
import 'package:flutterapp/src/screens/game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LessonGames extends ConsumerStatefulWidget {
  final Function(int) onLoadLessons;
  const LessonGames({Key? key, required this.onLoadLessons}) : super(key: key);

  @override
  LessonGamesState createState() => LessonGamesState();
}

class LessonGamesState extends ConsumerState<LessonGames> {

  @override
  void initState() {
    super.initState();
    ref.read(srsCardsTodayProvider.notifier).getCardsToday();
  }

  Future<Map<int, bool>> _loadCompletedLessons() async {
    final date = DateTime.now().toIso8601String().split('T')[0]; // Get today's date
    final prefs = await SharedPreferences.getInstance();

    // Use the date as part of the key to retrieve the lessonState
    final lessonStateData = jsonDecode(prefs.getString('lessonState_$date') ?? '{}');

    return Map<int, bool>.from(lessonStateData['completedLessons'] ?? {});
  }
  
  @override
  Widget build(BuildContext context) {
    final gameDataAsyncValue = ref.watch(srsGameTodayProvider);

    return FutureBuilder<Map<int, bool>>( 
      future: _loadCompletedLessons(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
        return gameDataAsyncValue.when(
          data: (lessons) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoadLessons(lessons.length);
          });
          return Column( 
            children: List.generate( 
              lessons.length,
              (index) {
                bool isCompleted = ref.watch(completedLessonProvider).completedLessons[index] ?? false;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile( 
                    onTap: () {
                      if (isCompleted) {
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseScreen(exercises: lessons[index], lesson: index),
                        ),
                      );
                    },
                    leading: isCompleted
                      ? Icon( 
                          CupertinoIcons.flame,
                          color: Theme.of(context).colorScheme.primary,
                          size: 40.0,
                        )
                      : Icon(
                          CupertinoIcons.flame, 
                          color: Theme.of(context).colorScheme.surface,
                          size: 40.0,
                        ),
                    title: Card( 
                      color: isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding( 
                        padding: const EdgeInsets.all(16.0),
                        child: Column( 
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[ 
                            Text('Lesson ${index + 1}',
                            style: const TextStyle( 
                              fontSize: 20.0,
                              fontWeight: FontWeight.w800,
                            )),
                            const SizedBox(height: 10.0),
                            Row( 
                              children: <Widget>[ 
                                const Icon(Icons.access_time, color: Colors.white),
                                const SizedBox(width: 5.0),
                                Text(
                                  '${(lessons[index].length * 10 / 60).round()} mins', 
                                  style: const TextStyle( 
                                  fontSize: 12.0,
                                ))
                              ]
                            )
                          ]
                        )
                      )
                    )
                  ),
                );
              }
            ),
          );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        );
      }}
    );
  }
}
