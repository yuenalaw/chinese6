import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';

FlutterTts flutterTts = FlutterTts();

class PressableSentenceWidget extends StatelessWidget {
  final List<Entry> entries;
  final String sentence;
  final double start;
  final int indexLineNum;
  final int totalLines;
  final Function(Entry) onEntrySelected;

  const PressableSentenceWidget({
    Key? key,
    required this.entries,
    required this.sentence,
    required this.start,
    required this.indexLineNum,
    required this.totalLines,
    required this.onEntrySelected,
  }) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Padding( 
        padding: const EdgeInsets.symmetric(horizontal: 45.0),
        child: Container(
          decoration: BoxDecoration( 
            color: customColourMap['HOTPINK'],
            borderRadius: BorderRadius.circular(25.0),
          ),
        child: Padding( 
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row( 
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: <Widget>[
              Stack( 
                alignment: Alignment.center,
                children: <Widget>[ 
                  Container( 
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration( 
                      color: Colors.white,
                      shape: BoxShape.circle,
                    )
                  ),
                  SizedBox( 
                    width: 40,
                    height: 40,
                    child: FloatingActionButton( 
                      heroTag: "$sentence$indexLineNum",
                      onPressed: () async {
                        await flutterTts.setLanguage("zh-CN");
                        await flutterTts.speak(sentence);
                      },
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      child: Icon(Icons.play_arrow, color: customColourMap['HOTPINK'], size: 30.0),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 10.0),
              Expanded( 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[ 
                    DefaultTextStyle( 
                      style: TextStyle( 
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                        color: customColourMap['HOTPINK'],
                      ),
                      child: Text(
                        "$indexLineNum: $totalLines",
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Wrap( 
                      spacing: 4.0,
                      runSpacing: 4.0,
                      children: entries.map((entry) => GestureDetector( 
                        onTap: () {
                          onEntrySelected(entry);
                        },
                        child: Container( 
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration( 
                            color: wordUposMap.containsKey(entry.upos) ? wordUposMap[entry.upos] : wordUposMap['default'],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: DefaultTextStyle( 
                            style: const TextStyle( 
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                            child: Text(
                              entry.word,
                            ),
                          )
                        ),
                      )).toList(),
                      ),
                    const SizedBox(height: 5.0),
                    Row( 
                      children: <Widget>[ 
                        Icon(
                          Icons.access_time,
                          color: customColourMap['HOTPINK'],
                        ),
                        const SizedBox(width: 5.0),
                        DefaultTextStyle( 
                          style: TextStyle( 
                              fontSize: 16.0,
                              color: customColourMap['HOTPINK'],
                          ),
                          child: Text(
                            start.toStringAsFixed(2),
                          ),
                        ),
                      ]
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    );
  }
}