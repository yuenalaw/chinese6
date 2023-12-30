// json 
// {
//   "message": msg,
//   "video": {
//      "keywords_img": [
          //   {
          //       "img": "https://unsplash.com/photos/SFEvfN01-ao/download?ixid=M3w1NDE4MDB8MHwxfHJhbmRvbXx8fHx8fHx8fDE3MDM5MzQ5NDl8",
          //       "keyword": "亚洲"
          //   },
          // ],
//       "lessons": [
//         {
//           "segment": {
//             "duration":,
//             "segment":,
//             "sentences": {
//               "entries": [
//                 {
//                   "pinyin": ,
//                   "similarsounds":[],
//                   "translation": [[word, [translations]],
//                 }
//               ],
//               "sentence":,
//             },
//             "start":,
//           }
//         },
//         "user_sentence": {
//           "entries": [
//             {
//               "pinyin": 
//               "similarsounds",
//               "translation"
//             }
//           ]
//         }
//       ],
//       "source": "YouTube",
//       "title": title,
//     }
//   }
// }

import 'lesson.dart';
import 'keyword_img.dart';

class Video {
    final List<Lesson> lessons;
    final String source;
    final String title;
    final List<KeywordImg> keywordsImg;

    Video({
      required this.lessons,
      required this.source,
      required this.title,
      required this.keywordsImg,
    });

    factory Video.fromJson(Map<String, dynamic> json) {
      var lessonObjsJson = json['video']['lessons'] as List;
      List<Lesson> lessons = lessonObjsJson.map((lessonJson) => Lesson.fromJson(lessonJson)).toList();

      var keywordImgObjsJson = json['video']['keywords_img'] as List;
      List<KeywordImg> keywordsImg = keywordImgObjsJson.map((keywordImgJson) => KeywordImg.fromJson(keywordImgJson)).toList();

      String source = json['video']['source'];
      String title = json['video']['title'];

      return Video(
        lessons: lessons,
        source: source,
        title: title,
        keywordsImg: keywordsImg,
      );
    }
}