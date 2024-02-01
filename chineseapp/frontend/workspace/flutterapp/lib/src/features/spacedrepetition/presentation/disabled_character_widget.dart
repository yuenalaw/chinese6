import 'package:flutter/material.dart';

class DisabledCharacterWidget extends StatelessWidget {
  final String character;

  DisabledCharacterWidget({required this.character});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.2, // Limit the width to 20% of the screen width
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey, // Background color
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
          border: Border.all( 
            color: Colors.black,
            width: 2.0
          ),
          boxShadow: [ // Small shadow
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0), // Add padding around the text
            child: Container(width: 24.0, height: 30.0),
            ),
          ),
        ),
      );
  }
}