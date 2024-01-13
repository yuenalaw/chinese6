import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/application/countdown_controller.dart';

class CountdownWidget extends ConsumerWidget {
  const CountdownWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int countdown = ref.watch(countdownControllerProvider);
    return Center(
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            const TextSpan(text: 'Next refresh in '),
            TextSpan(
              text: '$countdown',
              style: const TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' seconds'),
          ],
        ),
      ),
    );
  }
}

