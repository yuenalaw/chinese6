import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/video_information_widget.dart';

class LessonOverviewScreen extends ConsumerWidget {
  final String videoId;
  const LessonOverviewScreen({Key? key, required this.videoId}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Lesson Overview'),
      ),
      body: SingleChildScrollView( 
        child: Column (
          children: <Widget>[
            VideoInformation(videoId: videoId)
          ],
        ),
      ),
    );
  }
}