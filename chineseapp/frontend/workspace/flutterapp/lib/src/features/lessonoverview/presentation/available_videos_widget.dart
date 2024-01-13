import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/countdown_widget.dart';
import 'package:flutterapp/src/screens/lesson_overview_screen.dart';
import 'dart:math';

class AvailableVideos extends ConsumerStatefulWidget {
  const AvailableVideos({Key? key}) : super(key: key);

  @override
  AvailableVideosState createState() => AvailableVideosState();
}

class AvailableVideosState extends ConsumerState<AvailableVideos> {
  bool isViewAll = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Library>>(allReadyVideosProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
          ),
        );
      }
    });

    return Column(
      children: [
        const CountdownWidget(),
        Container(
          height: MediaQuery.of(context).size.height * 0.9, // Adjust this value as needed
          child: ref.watch(allReadyVideosProvider).when(
            data: (library) {
              int itemCount = isViewAll ? library.videos.length : min(3, library.videos.length);
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 2),
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  var video = library.videos.values.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LessonOverviewScreen(videoId: video.id)));
                      },
                      child: Card(
                        color: Colors.blue[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              video.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            Text(
                              video.source,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isViewAll = !isViewAll;
            });
          },
          child: Text(isViewAll ? 'Close All' : 'View All'),
        ),
      ],
    );



  }
}
