import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/lessonoverview/domain/keyword_img.dart';

class KeywordCarousel extends StatelessWidget {
  final List<KeywordImg> keywordsImg;

  const KeywordCarousel({Key? key, required this.keywordsImg}) : super(key: key);

  @override 
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox( 
        height: 200,
        child: ListView.builder( 
          scrollDirection: Axis.horizontal,
          itemCount: keywordsImg.length,
          itemBuilder: (context, index) {
            var keywordImg = keywordsImg[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox( 
                width: 160,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Column( 
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[ 
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              keywordImg.img,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Image.asset('assets/Error404.gif');
                              }
                            ),
                          ),
                        ),
                        Text(keywordImg.keyword),
                      ]
                    ),
                  ),
                ),
              ),
            );
          }
        )
      ),
    );
  }
}