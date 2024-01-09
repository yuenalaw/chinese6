import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/entry.dart';
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts flutterTts = FlutterTts();

class SentenceCard extends StatelessWidget {
  final List<Entry> entries;
  final String sentence;
  final double start;
  final int lineNum;
  final Function(Entry) onEntrySelected;

  const SentenceCard({Key? key, required this.entries, required this.sentence, required this.start, required this.lineNum, required this.onEntrySelected}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Start Time: $start'),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 30.0,
                  onPressed: () async {
                    await flutterTts.setLanguage("zh-CN");
                    await flutterTts.speak(sentence);
                  }
                ),
                Text('Line Number: ${lineNum+1}'),
              ],
            ),
            const SizedBox(height: 10.0), // Add space
            RichText(
              text: TextSpan(
                children: [
                  for (var entry in entries)
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          onEntrySelected(entry);
                        },
                        child: Text(
                          ' ${entry.word} ',
                          style: TextStyle(
                            fontSize: 20, // Adjust this value as needed
                            color: Colors.black,
                            backgroundColor: wordUposMap.containsKey(entry.upos) ? wordUposMap[entry.upos] : wordUposMap['default'],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
