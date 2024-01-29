import 'package:flutter/material.dart';

class Task {
  Task(this.headerValue, {this.expandedValue = const Text(''), this.isExpanded = false, this.isDone = false});

  String headerValue;
  Widget expandedValue;
  bool isExpanded;
  bool isDone;
}
