import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/application/streak_service.dart';
import 'package:flutterapp/src/features/useroverview/domain/streak.dart';

class StreakController extends StateNotifier<AsyncValue<Streak>> {
  StreakController({ required this.streakService}) : super(const AsyncValue.loading()) {
    getStreak();
  }

  Future<void> getStreak() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => streakService.getStreak()
    );
  }

  Future<void> setNewStudyDate() async {
    state = const AsyncLoading();
    await streakService.updateStudyDay();
    state = await AsyncValue.guard(
      () => streakService.getStreak()
    );
  }

  final StreakService streakService; 
}

final streakControllerProvider = 
  StateNotifierProvider<StreakController, AsyncValue<Streak>>((ref) {
    return StreakController(
      streakService: ref.watch(streakServiceProvider)
    );
  });