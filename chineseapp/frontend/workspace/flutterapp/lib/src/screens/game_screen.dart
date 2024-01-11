import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/image_to_text_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/make_sentence_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/text_to_image_widget.dart';
import 'package:flutterapp/src/screens/home_screen.dart';

class ExerciseScreen extends StatefulWidget {

  final List<Exercise> exercises;

  const ExerciseScreen({Key? key, required this.exercises}) : super(key: key);

  @override 
  ExerciseScreenState createState() => ExerciseScreenState();

}

class ExerciseScreenState extends State<ExerciseScreen> {
  int currentExerciseIndex = 0;

  void nextExercise() {
    Navigator.pop(context);
    setState(() {
      currentExerciseIndex = currentExerciseIndex + 1;
    });
  }

  @override 
  Widget build(BuildContext context) {
    if (currentExerciseIndex < widget.exercises.length) {
      Exercise currentExercise = widget.exercises[currentExerciseIndex];
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
      // refresh home screen and go back there
      Future.microtask(() {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return Container(); 
    }
  }
}