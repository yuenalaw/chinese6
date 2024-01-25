import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/countdown_widget.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/transcript_page_view_widget.dart';
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
        ElevatedButton(
          onPressed: () {
            setState(() {
              isViewAll = !isViewAll;
            });
          },
          child: Text(isViewAll ? 'Close All' : 'View All'),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.3, // Adjust this value as needed
          child: ref.watch(allReadyVideosProvider).when(
            data: (library) {
              int itemCount = isViewAll ? library.videos.length : min(3, library.videos.length);
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 2.0), 
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  var video = library.videos.values.elementAt(index);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => TranscriptPageView(videoId: video.id)));
                      },
                      child: Card(
                        elevation: 8.0,
                        color: Colors.green[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Align items to the start
                          crossAxisAlignment: CrossAxisAlignment.center, // Stretch items horizontally
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                textAlign: TextAlign.center,
                                video.title,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[900],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                textAlign: TextAlign.center,
                                video.source,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.green[700],
                                ),
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
      ],
    );
  }
}
