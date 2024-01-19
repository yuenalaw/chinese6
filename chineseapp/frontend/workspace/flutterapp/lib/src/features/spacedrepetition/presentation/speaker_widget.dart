import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutterapp/src/constants/colours.dart';

class SpeakerWidget extends StatefulWidget {
  final String speech;

  const SpeakerWidget({ required this.speech });

  @override 
  SpeakerWidgetState createState() => SpeakerWidgetState();
}

class SpeakerWidgetState extends State<SpeakerWidget> {
  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0), // Add padding to the top and bottom
      child: Container(
        width: 300.0, // Specify a width
        height: 150.0, // Specify a height
        decoration: BoxDecoration(
          color: customColourMap['BABYBLUE'], // Background color
          border: Border.all(
            color: Colors.black, // Border color
            width: 3.0, // Border width
          ),
          boxShadow: [ // Add boxShadow property
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
          borderRadius: BorderRadius.circular(10.0), // Border radius
        ),
        child: IconButton(
          icon: const Icon(Icons.volume_up, size: 100.0), // Large loudspeaker icon
          onPressed: () async {
            await flutterTts.setLanguage("zh-CN");
            await flutterTts.speak(widget.speech);
          },
        ),
      ),
    );
  }

}