import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/srs_controller.dart';
import 'package:flutterapp/src/screens/game_screen.dart';

class GamePathScreen extends ConsumerWidget {
  const GamePathScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameDataAsyncValue = ref.watch(srsGameTodayProvider);
    return Scaffold(
      body: gameDataAsyncValue.when(
        data: (lessons) {
          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              // Calculate the offset for the S-shaped path
              double offset = (index % 4 < 2) ? 50.0 : -50.0;
              bool isCompleted = ref.watch(completedLessonProvider)[index] ?? false; 
              return Padding(
                padding: const EdgeInsets.all(16.0), // Add padding
                child: Transform.translate(
                  offset: Offset(offset, 0), // Offset the icons for an S-shaped path
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseScreen(exercises: lessons[index], lesson: index),
                        ),
                      );
                    },
                    child: Material( 
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      child: isCompleted
                        ? const Icon( 
                            Icons.check_circle,
                            size: 50.0,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.pets, 
                            size: 50.0,
                          ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
