import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/library.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/video_study_cover.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class LibraryDisplay extends ConsumerWidget {
  const LibraryDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(allReadyVideosProvider);
    return state.when(
      data: (Library library) {
        final videos = library.videos.values.toList();
        return MasonryGridView.count(
          crossAxisCount: 2,
          itemCount: videos.length,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          itemBuilder: (BuildContext context, int index) {
            final video = videos[index];
            return SizedBox(
              height: 200,
              width: 200,
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
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}
