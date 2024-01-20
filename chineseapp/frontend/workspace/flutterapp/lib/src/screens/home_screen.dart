import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/libraries_display.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: AnimatedTextKit( 
                  animatedTexts: [ 
                    TyperAnimatedText("What shall we study today?",
                    textStyle: const TextStyle( 
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ))
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Padding( 
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: LibraryDisplay(),
            ),
          ),
        ],
      ),
    );
  }
}

