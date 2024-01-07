import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/screens/lesson_overview_screen.dart';

class AvailableVideos extends ConsumerWidget {
  const AvailableVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<Library>>(allReadyVideosProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
          ),
        );
      }
    });
    return ref.watch(allReadyVideosProvider).when(
      data: (library) {
        return SizedBox( 
          height: MediaQuery.of(context).size.height * 0.23, // Adjust this value as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: library.videos.length,
            itemBuilder: (context, index) {
              var video = library.videos.values.elementAt(index);
              return Container(
                width: MediaQuery.of(context).size.width * 0.45,
                margin: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LessonOverviewScreen(videoId: video.id)));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              video.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(video.source),
                          ],
                        ),
                        Positioned(
                          top: 8.0,
                          right: 8.0,
                          child: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Handle edit button press
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
