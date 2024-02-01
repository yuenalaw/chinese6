import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';

class CheckButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  const CheckButton({Key? key, required this.enabled, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(20.0),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: enabled ? customColourMap['CORRECT_ANS'] : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(width: 2, color: Colors.black),
        ),
        onPressed: enabled ? onTap : null,
        child: const Text(
          '检查',
          style: TextStyle(color: Colors.white,fontSize: 24,),

        ),
      ),
    );
  }
}
