import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/application/streak_controller.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsyncValue = ref.watch(streakControllerProvider);
    return streakAsyncValue.when(
      data: (streak) => Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/fire.gif', height: 80, width: 80), // Replace this with your fire emoji/icon
            Text(
              '${streak.current}',
              style: const TextStyle(fontSize:80.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
