import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/available_sentences_widget.dart';

class LessonOverviewScreen extends ConsumerWidget {
  const LessonOverviewScreen({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Home page'),
      ),
      body: const SingleChildScrollView( 
        child: Column (
          children: <Widget>[
            AvailableSentences()
          ],
        ),
      ),
    );
  }
}