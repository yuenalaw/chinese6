import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class CachingNetworkImage extends StatefulWidget {
  final String url;
  CachingNetworkImage(this.url);

  @override
  _CachingNetworkImageState createState() => _CachingNetworkImageState();
}

class _CachingNetworkImageState extends State<CachingNetworkImage> {
  Image _image = Image.asset('assets/Error404.gif');

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(widget.url);

    if (url == null) {
      var resp = await http.get(Uri.parse(widget.url));
      if (resp.statusCode != 200) throw Exception('get error: statusCode= ${resp.statusCode}');

      await prefs.setString(widget.url, widget.url);
    }

    if (mounted) setState(() => _image = Image.network(widget.url));
  }

  @override
  Widget build(BuildContext context) => _image == null ? Center(child: CircularProgressIndicator()) : _image;
}