

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/youtubeintegration/application/youtube_controller.dart';
import 'package:flutterapp/src/features/youtubeintegration/presentation/show_video_widget.dart';

class SearchBarWidget extends ConsumerWidget {
  const SearchBarWidget({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    final youtubeControllerNotifier = ref.read(youtubeControllerProvider.notifier);
    final youtubeInput = TextEditingController();

    return Padding( 
      padding: const EdgeInsets.all(8.0),
      child: Column( 
        children: [
          TextField( 
            controller: youtubeInput,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration( 
              labelText: 'Search YouTube video by id...',
              labelStyle: const TextStyle(color: Colors.grey),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton( 
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (youtubeInput.text.isNotEmpty) {
                      youtubeControllerNotifier.searchVideo(youtubeInput.text);
                    }
                  }
                )
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            )
          ),
          AnimatedContainer( 
            duration: const Duration(seconds:1),
            height: ref.watch(youtubeControllerProvider).when(  
              data: (video) => 200,
              loading: () => 0,
              error: (error, stackTrace) => 0,
            ),
            child: ref.watch(youtubeControllerProvider).when( 
              data: (video) => ShowVideoWidget(video: video),
              loading: () => Container(),
              error:(error, stackTrace) => const Text('Error'),
            )
          )
        ],
      )
    );
  }
}
