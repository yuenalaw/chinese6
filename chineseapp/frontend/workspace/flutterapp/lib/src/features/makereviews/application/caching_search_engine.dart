import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutterapp/src/features/makereviews/domain/cse_results.dart';
import 'package:http/http.dart' as http;
import 'caching_directory.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CachingSearchEngine {
  CachingSearchEngine();

  Future<Results> imageSearch(String q) async {
    String? json;

    final prefs = await SharedPreferences.getInstance();
    json = prefs.getString(q);

    if (json == null) {
      var params = {
        'cx': dotenv.env['CX_ID']!,
        'key': dotenv.env['KEY'],
        'searchType': 'image',
        'q': q,
        'num':'3',
        'imageSize': 'medium',
      };

      var query = Uri(queryParameters: params).query;
      var url = 'https://www.googleapis.com/customsearch/v1?$query';
      var resp = await http.get(Uri.parse(url));
      if (resp.statusCode != 200) throw Exception('get error: statusCode= ${resp.statusCode}');

      json = resp.body;
      print('json body is $json');
      await prefs.setString(q, json);
    }

    return Results.fromRawJson(json);
  }
}