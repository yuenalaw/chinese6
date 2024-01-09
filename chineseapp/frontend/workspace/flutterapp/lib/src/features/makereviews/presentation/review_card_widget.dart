import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/presentation/review_button_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

FlutterTts flutterTts = FlutterTts();

class ReviewCard extends ConsumerStatefulWidget {
  final ReviewParams reviewParams;

  const ReviewCard({Key? key, required this.reviewParams}) : super(key: key);

  @override 
  ReviewCardState createState() => ReviewCardState();
}

class ReviewCardState extends ConsumerState<ReviewCard> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String _personalNote = '';

  @override 
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ref.watch(makeReviewProvider(widget.reviewParams)).when(
        data: (userWordSentence) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:[
                              Text(widget.reviewParams.entry.pinyin, style: const TextStyle(fontSize: 20)), // Larger Pinyin
                              const Text('Translation', style: TextStyle(fontSize: 16)), // Smaller Translation heading
                              ...widget.reviewParams.entry.getTranslationAsListOfLists().map((t) => Text(t.join(', '))),
                              const Text('Similar Sounds', style: TextStyle(fontSize: 16)), // Smaller Similar Sounds heading
                              Row( 
                                children:
                                  widget.reviewParams.entry.similarSounds != null ?
                                  widget.reviewParams.entry.similarSounds!.map((s) => Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Chip(label :Text(s, style: const TextStyle(fontSize: 12))),
                                  )).toList()
                                  : [],
                              ),
                            ],
                          ),
                        ),
                        Column( 
                          children:[
                            IconButton(
                              icon :const Icon(Icons.volume_up),
                              onPressed :() async {
                                await flutterTts.setLanguage("zh-CN");
                                await flutterTts.speak(widget.reviewParams.entry.word);
                               },
                             ),
                             Text(widget.reviewParams.entry.word, style :const TextStyle(fontSize :50)),
                           ],
                         ),
                       ],
                     ),
                   ),
                ), 
                const SizedBox(height: 10.0), // Spacing from the above container
                Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:[
                    Expanded (
                      child: Container (
                        height: 200, // Adjust this value as needed
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            (_image != null || File(_image!.path).existsSync()) ? Image.file(File(_image!.path))
                            : ((userWordSentence.imagePath != "" && userWordSentence.imagePath != null) || File(userWordSentence.imagePath!).existsSync())
                            ? Image.file(File(userWordSentence.imagePath!))
                            : Container(),
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () async {
                                // Handle image capture
                                XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                if (image != null) {
                                  setState(() {
                                    _image = image;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded (
                      child: Container (
                        height: 200, // Adjust this value as needed
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: TextField(
                          controller: TextEditingController( 
                            text: (_personalNote != "") ? _personalNote
                            : userWordSentence.note != null && userWordSentence.note != ""
                            ? userWordSentence.note : ""
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Personal note...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(8.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _personalNote = value;
                            });
                          }
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0), // Spacing from the above container
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ReviewButton(isReview: userWordSentence.isReview),
                ),
              ],
            ),
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
