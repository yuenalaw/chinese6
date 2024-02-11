import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeWatchWidget extends StatefulWidget {
  final String videoId;
  final Function(Duration) onTimeChanged;
  const YoutubeWatchWidget({Key? key, required this.videoId, required this.onTimeChanged}) : super(key: key);

  @override
  State<YoutubeWatchWidget> createState() => _YoutubeWatchWidgetState();
}

class _YoutubeWatchWidgetState extends State<YoutubeWatchWidget> {
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
  }

  void listener() {
    if (_isPlayerReady && mounted) { 
      setState(() {
        widget.onTimeChanged(_controller.value.position);
      });
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