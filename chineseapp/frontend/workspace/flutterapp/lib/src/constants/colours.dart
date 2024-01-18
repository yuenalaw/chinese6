import 'package:flutter/widgets.dart';

const Map<String, Color> wordUposMap = {
  'NOUN': Color(0xffa8e6ce),
  'PROPN': Color(0xffdcedc2),
  'AUX': Color(0xffffd3b5), //was
  'VERB': Color(0xffffaaa6),
  'ADP': Color(0xffff8c94), //in
  'default': Color.fromARGB(255, 255, 255, 255),
};

const Map<String, Color> customColourMap = {
  'CORRECT_ANS': Color(0xffa8e6ce),
  'WRONG_ANS': Color(0xffff8c94),
  'BUTTONS': Color(0xffe0bbe4),
  'BLUE': Color(0xffc6dbda),
  'PINK': Color(0xfffee1e8),
  'RED': Color(0xffff9aa2),
};