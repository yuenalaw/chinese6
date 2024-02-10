import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/screens/youtube_player_transcript.dart';

class VideoStudyCard extends ConsumerWidget {
  final String imageUrl;
  final String title;
  final String channelName;
  final String videoId;

  const VideoStudyCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.channelName,
    required this.videoId,
  }): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => YoutubePlayerTranscriptScreen(videoId: videoId)));
      },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: <Widget>[
                Padding( 
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100, 
                    height: 55, 
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), // adjust the radius as needed
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                          return Image.asset('assets/quakkityintro.gif', fit: BoxFit.cover);
                        },
                      ),
                    ),
                  )
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8.0), // Add space between the title and channel name
                        Text(
                          channelName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
