import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/video_information_widget.dart';

class LessonOverviewScreen extends ConsumerStatefulWidget {
    const LessonOverviewScreen({Key? key, required this.videoId}) : super(key: key);
   final String videoId;


  @override
  LessonOverviewScreenState createState() => LessonOverviewScreenState();
}

class LessonOverviewScreenState extends ConsumerState<LessonOverviewScreen > {

  @override 
  Widget build(BuildContext context) {
    ref.read(videoOverviewProvider.notifier).getVideoDetails(widget.videoId);

    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Lesson Overview'),
      ),
      body: SingleChildScrollView( 
        child: Column (
          children: <Widget>[
            VideoInformation(videoId: '')
          ],
        ),
      ),
    );
  }
}