import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/libraries_display.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Videos'),
        actions: <Widget>[ 
          Consumer(builder: (context, watch, child) {
            return Padding( 
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimSearchBar(
                width: 350, 
                textController: _searchController, 
                onSuffixTap: () {
                  setState(() {
                    _searchController.clear();
                  });
                }, 
                rtl: true,
                helpText: "Search for a new video",
                onSubmitted: (value) {
                  print("value is $value");
                  return;
                },
              )
            );
          })
        ]
      ),
      body: LibraryDisplay(),
    );
  }
}
