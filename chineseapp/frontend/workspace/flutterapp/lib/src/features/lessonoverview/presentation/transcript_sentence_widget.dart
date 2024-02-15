import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:gtext/gtext.dart';

FlutterTts flutterTts = FlutterTts();

class TranscriptSentenceWidget extends StatelessWidget {
  final List<Entry> entries;
  final String sentence;
  final double start;
  final int indexLineNum;
  final int totalLines;

  const TranscriptSentenceWidget({
    Key? key,
    required this.entries,
    required this.sentence,
    required this.start,
    required this.indexLineNum,
    required this.totalLines
  }) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Padding( 
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration( 
          color: indexLineNum % 2 == 0 ? Theme.of(context).colorScheme.primary : Colors.black,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding( 
            padding: const EdgeInsets.all(16.0),
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[ 
                DefaultTextStyle( 
                  style: TextStyle( 
                    fontSize: 16.0,
                    fontWeight: FontWeight.w800,
                    color: indexLineNum % 2 == 0 ? Colors.black : Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    "${indexLineNum + 1}/$totalLines",
                  ),
                ),
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
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: indexLineNum % 2 == 0 ? Colors.black : Colors.white,
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
                  children: entries.map((entry) { 
                    return Container( 
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
                    );
                  }).toList(),
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
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: indexLineNum % 2 == 0 ? Colors.black : Colors.white,
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Row( 
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[ 
                    Icon(
                      Icons.access_time,
                      color: indexLineNum % 2 == 0 ? Colors.black : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 5.0),
                    DefaultTextStyle( 
                      style: TextStyle( 
                          fontSize: 16.0,
                          color: indexLineNum % 2 == 0 ? Colors.black : Theme.of(context).colorScheme.primary
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
        )
      ),
    );
  }
}