import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/application/streak_controller.dart';

class StreakWidget extends ConsumerWidget {
  const StreakWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsyncValue = ref.watch(streakControllerProvider);
    return streakAsyncValue.when(
      data: (streak) => Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset('assets/fire.gif', height: 150, width: 150),
            Positioned( 
              top: 10.0,
              right: 20.0,
              child: Container( 
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration( 
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                    '${streak.current}',
                    style: const TextStyle(fontSize:30.0, fontWeight: FontWeight.bold, color: Colors.white70),
                  )
              ),
            )
          ],
        ),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
