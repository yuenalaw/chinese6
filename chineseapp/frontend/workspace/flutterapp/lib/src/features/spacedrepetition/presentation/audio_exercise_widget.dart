
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/result_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pulsator/pulsator.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:path_provider/path_provider.dart';



class AudioExerciseWidget extends StatefulWidget {
  final Exercise exercise;
  final void Function(Exercise exercise, bool isCorrect) onCompleted;

  const AudioExerciseWidget({Key? key, required this.exercise, required this.onCompleted}) : super(key: key);

  @override 
  _AudioExerciseWidgetState createState() => _AudioExerciseWidgetState();
}

class _AudioExerciseWidgetState extends State<AudioExerciseWidget> {
  final FlutterTts flutterTts = FlutterTts();
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  bool isPlaying = false;

  String path = ""; // path of recorded audio file


  void reset() {
    setState(() {
      path = "";
    });
  }

  @override 
  void initState() {
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
      });
    });
    audioRecord = Record();
    super.initState();
  }

  @override
  void dispose() async {
    flutterTts.stop();
    audioPlayer.dispose();
    audioRecord.dispose();
    // delete the audio file after the widget is disposed
    File audioFile = File(path!);
    if (await audioFile.exists()) {
      await audioFile.delete();
    }
    super.dispose();
    
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, 
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: ResultWidget(exercise: widget.exercise, isCorrect: true, showTranslation: true, showWord: true, onCompleted: widget.onCompleted, resetWidget: reset),
        );
      },
    );
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        }); 
      
      }
    } catch (e) {
      print('Error recording audio');
    }
  }

  Future<void> stopRecording() async {
    try {
      String? audioPath = await audioRecord.stop();
      setState(() {
        isRecording = false;
        path = audioPath!;
      });
    } catch (e) {
      print('Error stopping recording');
    }
  }

  Future<void> playRecording() async {
    try{ 
      Source urlSource = UrlSource(path);
      await audioPlayer.play(urlSource);
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio');
    }
  }

  Widget pulsator() {
  return 
    Pulsator( 
      count: 8,
      duration: Duration(seconds: 4),
      repeat: 1,
      style: PulseStyle( 
        color: Theme.of(context).colorScheme.primary,
        borderWidth: 4.0,
        borderColor: Theme.of(context).colorScheme.primary,
        gradientStyle: PulseGradientStyle( 
          startColor: Theme.of(context).colorScheme.primary,
          start: 0.5,
          reverseColors: true,
        ),
        opacityCurve: Curves.easeOut,

      )
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
          children: [ 
            Row( 
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [ 
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton( 
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      await flutterTts.setLanguage("zh-CN");
                      await flutterTts.speak(widget.exercise.reviewCard.sentence);
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded( 
                  child: Text( 
                    widget.exercise.reviewCard.sentence,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            Expanded( 
              child: Column( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [ 
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container( 
                              width: 150.0,
                              height: 150.0,
                              alignment: Alignment.center,
                              child: isRecording ? 
                              GestureDetector( 
                                onTap: stopRecording,
                                child: pulsator(),
                              ) : 
                              IconButton(
                                iconSize: 100,
                                icon: const Icon(Icons.mic),
                                onPressed: isRecording ? stopRecording : startRecording,
                                color: isRecording ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container( 
                              width: 150.0,
                              height: 150.0,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: (!isRecording && path.isNotEmpty) ? () {
                                  playRecording();
                                  setState(() {
                                    isPlaying = true;
                                  });
                                } : null,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    (!isPlaying) ? 
                                    Icon(
                                      Icons.play_arrow,
                                      color: (!isRecording && path.isNotEmpty) ? Theme.of(context).colorScheme.primary : Colors.grey,
                                      size: 100.0,
                                    ) : 
                                      pulsator(),
                                  ],
                                ),
                              ),
                          ),
                        ),
                      ),
                      ),
                    ]
                  ),
                ],
              )
            ),
            Spacer(),
            Align( 
              alignment: Alignment.bottomRight,
              child: ElevatedButton( 
                style: ElevatedButton.styleFrom(
                  backgroundColor: path.isNotEmpty ? Colors.green : Colors.grey,
                ),
                onPressed: path.isNotEmpty ? () {
                  _showBottomSheet(context);
                } : null,
                child: const Text('Next', style: TextStyle(color: Colors.black)),
              ),
            )
          ]
        )
      )
    );
  }
}
