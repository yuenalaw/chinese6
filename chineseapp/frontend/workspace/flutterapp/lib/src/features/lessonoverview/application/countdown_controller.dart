import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CountdownController extends StateNotifier<int> {
  CountdownController() : super(30){
    startCountdown();
  }

  void startCountdown() {
    state = 30;
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (state > 1) {
        state --;
      } else {
        t.cancel();
        state = 30; // reset countdown
        startCountdown();
      }
    });
  }
}

final countdownControllerProvider = 
  StateNotifierProvider<CountdownController, int>((ref) {
    return CountdownController();
  });
