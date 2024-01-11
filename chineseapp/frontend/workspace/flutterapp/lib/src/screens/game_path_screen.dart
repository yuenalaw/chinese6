import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              return Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseScreen(exercises: lessons[index]),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.pets, 
                    size: 50.0,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
