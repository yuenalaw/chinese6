import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';

class ProgressWidget extends ConsumerStatefulWidget {
  final int totalLessons;
  const ProgressWidget({super.key, required this.totalLessons});

  @override
  ConsumerState<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends ConsumerState<ProgressWidget> {
  @override
  Widget build(BuildContext context) {
    final lessonsDone = ValueNotifier<int>(0);
    lessonsDone.value = ref.watch(maxCompletedLessonProvider);
    return AnimatedBuilder( 
      animation: lessonsDone,
      builder: (context, _) {
        return Padding( 
          padding: const EdgeInsets.symmetric(vertical:24.0),
          child: Container( 
          height: 200,
          width: 200,
          child: CircularProgressIndicator( 
            strokeWidth: 20,
            value: lessonsDone.value <= 0 || widget.totalLessons <= 0 ? 0 : lessonsDone.value/ widget.totalLessons,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        )
        );
      }
    );
  }
}