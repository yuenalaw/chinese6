import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/video_controller.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/lesson.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/transcript_page_view_widget.dart';
import 'package:flutterapp/src/features/youtubeintegration/presentation/youtube_player_widget.dart';
import 'package:flutterapp/src/screens/lesson_overview_screen.dart';

class YoutubePlayerTranscriptScreen extends ConsumerStatefulWidget {
  final String videoId;
  const YoutubePlayerTranscriptScreen({Key? key, required this.videoId})
      : super(key: key);

  @override
  _YoutubePlayerTranscriptScreenState createState() =>
      _YoutubePlayerTranscriptScreenState();
}

class _YoutubePlayerTranscriptScreenState
    extends ConsumerState<YoutubePlayerTranscriptScreen> {
  late final PageController _pageController;
  List<Lesson> lessons = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoOverviewProvider.notifier).getVideoDetails(widget.videoId);
    });
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTimeChanged(Duration position) {
    int positionInSeconds = position.inSeconds;
    int index = lessons
        .indexWhere((lesson) => lesson.segment.start > positionInSeconds);
    if (index != -1 && index != 0) {
      _pageController.animateToPage(index - 1,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
    } else if (positionInSeconds >= lessons.last.segment.start) {
      _pageController.animateToPage(lessons.length - 1,
          duration: const Duration(milliseconds: 100), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript'),
      ),
      body: ref.watch(videoOverviewProvider).when(
            data: (videoEither) {
              return videoEither.fold(
                (pleaseWait) {
                  return Text(pleaseWait.message);
                },
                (video) {
                  lessons = video.lessons;
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Card(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: YoutubeWatchWidget(
                                        videoId: widget.videoId,
                                        onTimeChanged: onTimeChanged),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 200,
                                child: TranscriptPageView(
                                    videoId: widget.videoId,
                                    lessons: lessons,
                                    pageController: _pageController),
                              ),
                            ],
                          ),
                          Expanded(
                            child: LessonOverviewScreen(video: video),
                          )
                        ],
                      ));
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Error: $err'),
          ),
    );
  }
}

