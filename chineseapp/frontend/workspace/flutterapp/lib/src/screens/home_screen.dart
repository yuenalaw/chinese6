import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/available_videos_widget.dart';
import 'package:flutterapp/src/screens/game_path_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Home page'),
      ),
      body: SingleChildScrollView( 
        child: Column (
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GamePathScreen()),
                  );
                },
                child: Image.asset('assets/quakkityintro.gif'), // Replace with your actual GIF path
              ),
            ),
            AvailableVideos(),
          ],
        ),
      ),
    );
  }
}
