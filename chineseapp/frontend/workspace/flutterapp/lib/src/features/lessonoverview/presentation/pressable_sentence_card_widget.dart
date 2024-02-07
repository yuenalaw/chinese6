import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:gtext/gtext.dart';
import 'package:lpinyin/lpinyin.dart';

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
            color: Theme.of(context).colorScheme.primary,
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
                      child: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.onPrimary, size: 30.0),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 10.0),
              Expanded( 
                child: Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[ 
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                PinyinHelper.getPinyin(sentence, separator: " ", format: PinyinFormat.WITH_TONE_MARK),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: GText(sentence, toLang: 'en',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row( 
                      children: <Widget>[ 
                        Icon(
                          Icons.access_time,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 5.0),
                        DefaultTextStyle( 
                          style: TextStyle( 
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.onPrimary,
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