import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/application/fake_data/fake_streak.dart';
import 'package:flutterapp/src/features/useroverview/data/useroverview_repository.dart';
import 'package:flutterapp/src/features/useroverview/domain/streak.dart';

class StreakService {
  StreakService(this.ref);
  final Ref ref;

  Future<Streak> _fetchStreak() async {
    final streak = await ref.read(userOverviewRepositoryProvider).getStreak();
    return streak;
    //return Streak.fromJson(fakeStreak);
  }

  Future<Streak> getStreak() async {
    return await _fetchStreak();
  }

  Future<Streak> updateStudyDay() async {
    await ref.read(userOverviewRepositoryProvider).addNewStudyDay();
    return await _fetchStreak();
  }
}

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(ref);
});