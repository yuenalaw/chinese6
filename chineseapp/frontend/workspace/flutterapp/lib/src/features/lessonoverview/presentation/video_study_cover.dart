import 'package:flutter/material.dart';

class VideoStudyCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Image.asset('assets/quakkityintro.gif', fit: BoxFit.cover);
              },
            ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8.0), // Add space between the title and channel name
                  Text(
                    channelName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w200
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
