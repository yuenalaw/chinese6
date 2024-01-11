import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/review_card.dart';

FlutterTts flutterTts = FlutterTts();

class SimpleReviewCardWidget extends StatelessWidget {
  final ReviewCard reviewCard;

  const SimpleReviewCardWidget({ Key? key, required this.reviewCard }) : super(key:key);

  @override 
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.all(8.0),
      child: Card( 
        child: Padding( 
          padding: const EdgeInsets.all(8.0),
          child: Column( 
            children: [
              Row( 
                children: [ 
                  Expanded( 
                    child: Column( 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[ 
                        Text(reviewCard.word.pinyin, style: const TextStyle(fontSize: 20)),
                        const Text('Translation', style: TextStyle(fontSize: 16)),
                        reviewCard.word.translations != null ? Text(reviewCard.word.translations!.join(', ')) : Container(),
                        const Text('Similar sounds', style: TextStyle(fontSize: 16)),
                        Row( 
                          children: 
                            reviewCard.word.similarSounds != null ? reviewCard.word.similarSounds!.map((s) => Padding( 
                              padding: const EdgeInsets.all(4.0),
                              child: Chip(label: Text(s, style: const TextStyle(fontSize: 12))),
                            )).toList() : [],
                        )
                      ]
                    )
                  ),
                  Column( 
                    children: [ 
                      IconButton( 
                        icon: const Icon(Icons.volume_up),
                        onPressed: () async {
                          await flutterTts.setLanguage("zh-CN");
                          await flutterTts.speak(reviewCard.word.word);
                        },
                      ),
                      Text(reviewCard.word.word, style: const TextStyle(fontSize: 50)),
                    ],
                  )
                ]
              ),
              const SizedBox(height: 10.0), // Moved inside the Column
              Row( 
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [ 
                  Expanded(
                    child: Container( 
                      height: 200,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration( 
                        border: Border.all(color: Colors.black),
                      ),
                      child: reviewCard.imagePath != null && File(reviewCard.imagePath!).existsSync() ? Image.file(File(reviewCard.imagePath!)) : Container(),
                    )
                  ),
                  Expanded ( 
                    child: Container( 
                      height: 200,
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration( 
                        border: Border.all(color: Colors.black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          reviewCard.note ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    )
                  )
                ]
              )
            ]
          ),
        )
      ),
    );
  }
}
