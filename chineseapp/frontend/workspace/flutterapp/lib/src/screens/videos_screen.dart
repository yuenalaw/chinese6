import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/libraries_display.dart';
import 'package:flutterapp/src/features/youtubeintegration/application/youtube_controller.dart';
import 'package:flutterapp/src/features/youtubeintegration/presentation/show_video_widget.dart';

class VideoScreen extends ConsumerStatefulWidget {
  const VideoScreen({super.key});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  
  late final TextEditingController _searchController;
  bool isShowVideoWidgetVisible = false;

  void showVideoWidget(isVisible) {
    setState(() {
      isShowVideoWidgetVisible = isVisible;
    });
  }

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
    final youtubeControllerNotifier = ref.read(youtubeControllerProvider.notifier);
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
                  if (value.isNotEmpty) {
                    youtubeControllerNotifier.searchVideo(value);
                    showVideoWidget(true);
                  }
                  return;
                },
              )
            );
          })
        ]
      ),
      body: Stack( 
        children: <Widget>[ 
          LibraryDisplay(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal:16), // adjust the padding as needed
            child: AnimatedContainer( 
              duration: const Duration(seconds:1),
              width: double.infinity,
              height: ref.watch(youtubeControllerProvider).when(  
                data: (video) => 270,
                loading: () => 0,
                error: (error, stackTrace) => 0,
              ),
              child: ref.watch(youtubeControllerProvider).when( 
                data: (video) => GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'The video will be in your library soon!',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.all(16.0),
                      ),
                    );
                    showVideoWidget(false);
                  },
                  child: isShowVideoWidgetVisible ? ShowVideoWidget(video: video) : Container(),
                ),
                loading: () => Container(),
                error:(error, stackTrace) => const Text('Error'),
              )
            ),
          ),
        ],
      ),
    );
  }
}
