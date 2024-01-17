import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/presentation/review_button_widget.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

FlutterTts flutterTts = FlutterTts();

class ReviewCard extends ConsumerStatefulWidget {
  final ReviewParams reviewParams;

  const ReviewCard({Key? key, required this.reviewParams }) : super(key: key);

  @override 
  ReviewCardState createState() => ReviewCardState();
}

class ReviewCardState extends ConsumerState<ReviewCard> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  XFile? _localImage;
  String _personalNote = '';
  bool updateImgAndNote = false;

  @override 
  void didUpdateWidget(covariant ReviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reviewParams != oldWidget.reviewParams) {
      updateImgAndNote = true;
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ref.watch(makeReviewProvider(widget.reviewParams)).when(
        data: (userWordSentence) {
          if (updateImgAndNote) {
            _image = userWordSentence.imagePath != "" && File(userWordSentence.imagePath!).existsSync() ? XFile(userWordSentence.imagePath!) : null;
            _personalNote = userWordSentence.note ?? "";
            updateImgAndNote = false;
          }
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
                              Text(widget.reviewParams.entry.pinyin, style: const TextStyle(fontSize: 20)),
 // Larger Pinyin
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
                            (_image != null && File(_image!.path).existsSync()) ? Image.file(File(_image!.path))
                            : ((userWordSentence.imagePath != "" && userWordSentence.imagePath != null) && File(userWordSentence.imagePath!).existsSync())
                            ? Image.file(File(userWordSentence.imagePath!))
                            : Container(),
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: () async {
                                // Handle image capture
                                XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                if (image == null){
                                  return;
                                }
                                
                                final Directory directory = await getApplicationDocumentsDirectory();
                                final String duplicateFilePath = directory.path;
                                final fileName = '${widget.reviewParams.entry.word}_${widget.reviewParams.videoId}_${widget.reviewParams.lineNum}';
                                final File localImage = await File(image.path).copy('$duplicateFilePath/$fileName.png');

                                setState(() {
                                  _image = XFile(image.path);
                                  _localImage = XFile(localImage.path);
                                });
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
                  child: ReviewButton(userWordSentence: userWordSentence, reviewParams: widget.reviewParams, note: _personalNote, imgPath: (_localImage?.path ?? "")),
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
