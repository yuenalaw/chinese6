import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeWatchWidget extends ConsumerStatefulWidget {
  final String videoId;
  final Function(Duration) onTimeChanged;
  final StateController<double> startTimeNotifier;

  const YoutubeWatchWidget({Key? key, required this.videoId, required this.onTimeChanged, required this.startTimeNotifier}) : super(key: key);

  @override
  ConsumerState<YoutubeWatchWidget> createState() => _YoutubeWatchWidgetState();
}

class _YoutubeWatchWidgetState extends ConsumerState<YoutubeWatchWidget> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override initState() {
    super.initState();
    _controller = YoutubePlayerController( 
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags( 
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);

    widget.startTimeNotifier.addListener(seekToStart);

  }

  void listener() {
    if (_isPlayerReady && mounted) { 
      setState(() {
        widget.onTimeChanged(_controller.value.position);
      });
    }
  }

  void seekToStart(double newValue) {
    if (_isPlayerReady) {
      _controller.seekTo(Duration(seconds: newValue.round()));
    }
  }

  @override 
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder( 
      player: YoutubePlayer( 
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: customColourMap['HOTPINK'],
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) => Scaffold( 
        body: Column( 
          children: <Widget>[
            player,
          ],
        ),
      )
    );
  }
}