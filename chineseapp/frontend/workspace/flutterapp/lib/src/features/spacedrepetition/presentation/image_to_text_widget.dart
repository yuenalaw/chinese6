import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';

class ImageToTextWidget extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;

  const ImageToTextWidget({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  ImageToTextState createState() => ImageToTextState();
}

class ImageToTextState extends State<ImageToTextWidget> {
  final FlutterTts flutterTts = FlutterTts();
  String? chosenWord;

  void reset() {
    setState(() {
      chosenWord = null;
    });
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ResultWidget(exercise: widget.exercise, isCorrect: widget.exercise.correctAnswer == chosenWord, showTranslation: false, showWord: true, onCompleted: widget.onCompleted, resetWidget: reset),
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( 
        title: Text(widget.exercise.question),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( 
          children: <Widget>[ 
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: widget.exercise.reviewCard.imagePath != null
              ? Image.network(
                  widget.exercise.reviewCard.imagePath!,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                )
              : Image.asset('assets/Error404.gif'),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.exercise.availableAnswers.map((word) {
                return ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      word,
                      style: const TextStyle(fontSize: 16.0), // Increase the font size
                    ),
                  ),
                  selected: chosenWord == word,
                  onSelected: (selected) async {

                    setState(() {
                      chosenWord = selected ? word : null;
                    });
                    await flutterTts.setLanguage("zh-CN");
                    await flutterTts.speak(word);
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: chosenWord != null ? Colors.green : Colors.grey,
                ),
                onPressed: chosenWord != null ? () {
                  _showBottomSheet(context);
                } : null,
                child: const Text('Check', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
