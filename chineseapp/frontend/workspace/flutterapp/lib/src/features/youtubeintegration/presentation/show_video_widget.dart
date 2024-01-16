import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';
import 'package:flutterapp/src/features/youtubeintegration/domain/queried_video.dart';

class ShowVideoWidget extends StatefulWidget {
  final QueriedVideo video;

  const ShowVideoWidget({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override 
  ShowVideoWidgetState createState() => ShowVideoWidgetState();
}

class ShowVideoWidgetState extends State<ShowVideoWidget> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Visibility( 
      visible: isVisible,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: (widget.video.thumbnail != null) 
                      ? Image.network(widget.video.thumbnail!, width: 100, height: 100)
                      : Image.asset('asset/Error404.gif', width: 100, height: 100),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible( 
                              child: Text(widget.video.title ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: customColourMap['BLUE'],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(widget.video.channel ?? "", style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: customColourMap['PINK'],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(widget.video.vidId ?? "", style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,  // Change this
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 35.0,
                  width: 35.0,
                  decoration: BoxDecoration(
                    color: customColourMap['RED'],
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    iconSize: 20.0,
                    onPressed: () {
                      setState(() {
                        isVisible = false;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}