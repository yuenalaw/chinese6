import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/srs_controller.dart';
import 'package:flutterapp/src/screens/game_screen.dart';

class LessonGames extends ConsumerWidget {
  final Function(int) onLoadLessons;
  LessonGames({Key? key, required this.onLoadLessons}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameDataAsyncValue = ref.watch(srsGameTodayProvider);
    return gameDataAsyncValue.when(
      data: (lessons) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        onLoadLessons(lessons.length);
      });
      return Column( 
        children: List.generate( 
          lessons.length,
          (index) {
            bool isCompleted = ref.watch(completedLessonProvider)[index] ?? false;
            return Padding(
              padding: const EdgeInsets.all(8.0), // adjust the padding as needed
              child: ListTile( 
                onTap: () {
                  if (isCompleted) {
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExerciseScreen(exercises: lessons[index], lesson: index, showNavBar: ValueNotifier<bool>(false)),
                    ),
                  );
                },
                leading: isCompleted
                  ? Icon( 
                      CupertinoIcons.flame,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40.0, // adjust the size as needed
                    )
                  : Icon(
                      CupertinoIcons.flame, 
                      color: Theme.of(context).colorScheme.surface,
                      size: 40.0, // adjust the size as needed
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
  }
}
