import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/exercises_completed_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/srs_controller.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/image_to_text_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/fill_in_blank_page.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/stroke_test_page.dart';
import 'package:flutterapp/src/features/useroverview/application/streak_controller.dart';
import 'package:flutterapp/src/screens/home_screen.dart';
import 'package:flutterapp/src/screens/main_app.dart';

class ExerciseScreen extends ConsumerStatefulWidget {

  final List<Exercise> exercises;
  final int lesson;
  const ExerciseScreen({Key? key, required this.exercises, required this.lesson}) : super(key: key);

  @override 
  ExerciseScreenState createState() => ExerciseScreenState();

}

class ExerciseScreenState extends ConsumerState<ExerciseScreen> {

  void nextExercise(Exercise exercise, bool isCorrect) {
    
    // if it's wrong, must repeat
    if (!isCorrect) {
      widget.exercises.add(exercise);
    }
    ref.read(srsReviewUpdateProvider(widget.exercises).notifier).nextExercise();
  }

  @override 
  Widget build(BuildContext context) {
    final controller = ref.watch(srsReviewUpdateProvider(widget.exercises));
    if (controller.currentExerciseIndex < widget.exercises.length) {
      Exercise currentExercise = widget.exercises[controller.currentExerciseIndex];
      if (currentExercise.exerciseType == 1) {
        // fill word
        return FillInBlankPage(exercise: currentExercise, onCompleted: nextExercise);
      } else if (currentExercise.exerciseType == 2) {
        // speech 
        return Placeholder();
      } else if (currentExercise.exerciseType == 3){
        // stroke order
        return StrokeTestPage(exercise: currentExercise, onCompleted: nextExercise);
      } else if(currentExercise.exerciseType == 4) {
        // match image to text
        return ImageToTextWidget(exercise: currentExercise, onCompleted: nextExercise);
      } else {
        // translate
        return Placeholder();
      }
    } else {
      Future.microtask(() {
        // update streak
        final streakController = ref.read(streakControllerProvider.notifier);
        streakController.setNewStudyDate();
        ref.read(completedLessonProvider.notifier).completedLesson(widget.lesson);

        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return Container(); 
    }
  }
}