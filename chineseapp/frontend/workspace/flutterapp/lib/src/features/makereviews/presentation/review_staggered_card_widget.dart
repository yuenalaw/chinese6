import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/domain/user_word_sentence.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

FlutterTts flutterTts = FlutterTts();

class ReviewCardStaggered extends ConsumerStatefulWidget {
  final ReviewParams reviewParams;
  const ReviewCardStaggered({Key? key, required this.reviewParams}) : super(key:key);

  @override
  ReviewCardStaggeredState createState() => ReviewCardStaggeredState();
}

class ReviewCardStaggeredState extends ConsumerState<ReviewCardStaggered> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  XFile? _localImage;
  String _personalNote = '';
  bool updateImgAndNote = true;

  @override 
  void didUpdateWidget(covariant ReviewCardStaggered oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reviewParams != oldWidget.reviewParams) {
      updateImgAndNote = true;
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.all(16.0),
      child: ref.watch(makeReviewProvider(widget.reviewParams)).when(
        data: (userWordSentence) {
          if (updateImgAndNote) {
            _image = userWordSentence.imagePath != "" && File(userWordSentence.imagePath!).existsSync() ? XFile(userWordSentence.imagePath!) : null;
            _personalNote = userWordSentence.note ?? "";
            updateImgAndNote = false;
          }

          return StaggeredGrid.count(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: [
              StaggeredGridTile.count( 
                crossAxisCellCount: 2,
                mainAxisCellCount: 2,
                child: getBoxContent(0, userWordSentence),
              ),
              StaggeredGridTile.count( 
                crossAxisCellCount: 2,
                mainAxisCellCount: 1,
                child: getBoxContent(1, userWordSentence),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 1,
                child: getBoxContent(2, userWordSentence),
              ),
              StaggeredGridTile.count( 
                crossAxisCellCount: 1,
                mainAxisCellCount: 3,
                child: getBoxContent(3, userWordSentence),
              ),
              StaggeredGridTile.count(
                crossAxisCellCount: 3, 
                mainAxisCellCount: 3, 
                child: getBoxContent(4, userWordSentence))
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      )
    );
  }

  Widget getBoxContent(int index, UserWordSentence userWordSentence) {
    switch (index) {
      case 0:
        return Container( 
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: customColourMap['PINK']
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
        );
      case 1:
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: customColourMap['PINK']
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // This centers the children vertically.
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      FlutterTts flutterTts = FlutterTts();
                      await flutterTts.setLanguage("zh-CN");
                      await flutterTts.speak(widget.reviewParams.entry.word);
                    },
                  ),
                  Text(
                    widget.reviewParams.entry.pinyin, 
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w200, color: Colors.grey), // Smaller font size for pinyin
                  ),
                ],
              ),
              Text(
                widget.reviewParams.entry.word,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Larger font size for word
              ),
              const SizedBox(height: 5.0),
            ],
          ),
        );
      case 2:
        return Container( 
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: customColourMap['HOTPINK']
          ),
          child: Center(
            child: Padding( 
              padding: const EdgeInsets.all(8.0),
              child: Column( 
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Personal note', 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100, color: Colors.grey), // make the text light and smaller
                    ),
                  ),
                  const SizedBox(height: 10), // adjust the value as needed
                  Align(
                    alignment: Alignment.center,
                    child: Text(_personalNote),
                  ),
                ],
              ),
            )          
          ),
        );
      case 3:
        return Container(
          decoration: BoxDecoration(
            color: customColourMap['HOTPINK'],
            borderRadius: BorderRadius.circular(10), // adjust the value as needed
          ),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: widget.reviewParams.entry.similarSounds!.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
            ),
          ),
        );
      case 4:
        return Container( 
          decoration: BoxDecoration( 
            color: customColourMap['PINK'],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center( 
            child: Padding( 
              padding: const EdgeInsets.all(8.0),
              child: Wrap( 
                alignment: WrapAlignment.center,
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Translation', 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w100, color: Colors.grey), // make the text light and smaller
                    ),
                  ),
                  const SizedBox(height: 10), // adjust the value as needed
                  ...widget.reviewParams.entry.getTranslationAsListOfLists().map((t) => 
                    Align(
                      alignment: Alignment.center,
                      child: Text(t.join(', ')),
                    ),
                  ),
                ],
              )
            ),
          )
        );
      default:
        return Container();
    
    }
  }
}