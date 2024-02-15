import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/useroverview/application/fake_data/fake_streak.dart';
import 'package:flutterapp/src/features/useroverview/data/useroverview_repository.dart';
import 'package:flutterapp/src/features/useroverview/domain/streak.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Function to check if two DateTime objects are on the same day
  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Future<void> updateStudyDay() async {
    await ref.read(userOverviewRepositoryProvider).addNewStudyDay();
  }
}


final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(ref);
});