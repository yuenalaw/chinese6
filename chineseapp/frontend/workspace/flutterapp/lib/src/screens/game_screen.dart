import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/srs_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/image_to_text_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/make_sentence_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/text_to_image_widget.dart';
import 'package:flutterapp/src/features/useroverview/application/streak_controller.dart';
import 'package:flutterapp/src/screens/main_app.dart';

class ExerciseScreen extends ConsumerStatefulWidget {

  final List<Exercise> exercises;
  final int lesson;
  final ValueNotifier<bool> showNavBar;
  const ExerciseScreen({Key? key, required this.exercises, required this.lesson, required this.showNavBar}) : super(key: key);

  @override 
  ExerciseScreenState createState() => ExerciseScreenState();

}

class ExerciseScreenState extends ConsumerState<ExerciseScreen> {



  void nextExercise(Exercise exercise, bool isCorrect) {
    
    // if it's wrong, must repeat
    if (!isCorrect) {
      widget.exercises.add(exercise);
    }
    Navigator.pop(context);
    ref.read(srsReviewUpdateProvider(widget.exercises).notifier).nextExercise();
  }



  @override 
  Widget build(BuildContext context) {
    widget.showNavBar.value = false;
    final controller = ref.watch(srsReviewUpdateProvider(widget.exercises));
    if (controller.currentExerciseIndex < widget.exercises.length) {
      Exercise currentExercise = widget.exercises[controller.currentExerciseIndex];
      if (currentExercise.exerciseType == 1) {
        // create sentence exercise 
        return SentenceBuilderWidget(exercise: currentExercise, onCompleted: nextExercise);
      } else if (currentExercise.exerciseType == 2) {
        // create text to image exercise
        return TextToImageWidget(exercise: currentExercise, onCompleted: nextExercise);
      } else {
        // create image to text exercise
        return ImageToTextWidget(exercise: currentExercise, onCompleted: nextExercise);
      }
    } else {
      Future.microtask(() {
        // update streak
        final streakController = ref.read(streakControllerProvider.notifier);
        streakController.setNewStudyDate();
        ref.read(completedLessonProvider.notifier).completedLesson(widget.lesson);

        Navigator.pop(context);
        widget.showNavBar.value = true;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainApp()),
          (Route<dynamic> route) => false,
        );
      });
      return Container(); 
    }
  }
}