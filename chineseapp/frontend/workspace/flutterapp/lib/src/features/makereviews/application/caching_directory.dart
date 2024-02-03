
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachingDirectory {
  final String? cacheExt;
  CachingDirectory({this.cacheExt});

  Future<String?> getCacheFile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString(key);

    if (cachedUrl == null) {
      debugPrint('"$key" NOT FOUND in cache');
    } else {
      debugPrint('"$key" found in cache');
    }

    return cachedUrl;
  }

  Future<void> setCacheFile(String key, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, url);
  }
}