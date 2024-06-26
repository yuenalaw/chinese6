import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/video_study_cover.dart';

class LibraryDisplay extends ConsumerWidget {
  const LibraryDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allReadyVideosProvider);
    final allReadyVideosController = ref.watch(allReadyVideosProvider.notifier);
    return Column(
      children: [
        ElevatedButton(
          onPressed: allReadyVideosController.getAllReadyVideosFromLibrary,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text('Refresh'),
        ),
        Expanded(
          child: state.when(
            data: (Library library) {
              final videos = library.videos.values.toList();
              return ListView.builder(
                itemCount: videos.length,
                itemBuilder: (BuildContext context, int index) {
                  final video = videos[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VideoStudyCard(
                      imageUrl: video.thumbnail,
                      title: video.title,
                      channelName: video.channel,
                      videoId: video.id,
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
        ),
      ],
    );
  }
}