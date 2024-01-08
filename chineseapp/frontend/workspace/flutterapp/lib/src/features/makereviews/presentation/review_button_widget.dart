import 'package:flutter/material.dart';

class ReviewButton extends StatelessWidget {
  final bool isReview;

  const ReviewButton({Key? key, required this.isReview}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(isReview ? 'Edit Review' : 'Add Review');
  }
}
