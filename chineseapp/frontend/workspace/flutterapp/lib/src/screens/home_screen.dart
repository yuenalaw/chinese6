import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/available_videos_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Home page'),
      ),
      body: const SingleChildScrollView( 
        child: Column (
          children: <Widget>[
            AvailableVideos()
          ],
        ),
      ),
    );
  }
}