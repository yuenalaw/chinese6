import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/spacedrepetition/application/srs_service.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/cards_today.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/context.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/exercise.dart';
import 'package:flutterapp/src/features/spacedrepetition/domain/obtain_context.dart';

class SRSCardsTodayController extends StateNotifier<AsyncValue<CardsToday>> {
  SRSCardsTodayController({ required this.srsService }) : super(const AsyncValue.loading()) {
    getCardsToday();
  }

  final SRSService srsService;

  Future<void> getCardsToday() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => srsService.getReviewCards()
    );
  }
}

class SRSGameTodayController extends StateNotifier<AsyncValue<List<List<Exercise>>>> {
  SRSGameTodayController({ required this.srsService }) : super(const AsyncValue.loading()) {
    getGameToday();
  }

  final SRSService srsService;

  Future<void> getGameToday() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => srsService.getNewGame()
    );
  }
}

class SRSContextController extends StateNotifier<AsyncValue<Context>> {
    ObtainContext obtainContext;

    SRSContextController({ required this.srsService, required this.obtainContext }) : super(const AsyncValue.loading()) {
    getContext();
  }

  final SRSService srsService;

  Future<void> getContext() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => srsService.getContext(obtainContext: obtainContext)
    );
  }
}

class SRSReviewUpdateController extends ChangeNotifier {
  
  final List<Exercise> exercises;
  int currentExerciseIndex = 0;

  SRSReviewUpdateController({ required this.srsService, required this.exercises });

  final SRSService srsService;

  void checkExercises() {
    if (currentExerciseIndex >= exercises.length) {
      batchUpdateReviews();
    }
  }

  void nextExercise() {
    currentExerciseIndex += 1;
    checkExercises();
    notifyListeners();
  }

  Future<void> batchUpdateReviews() async {
    await srsService.batchUpdateReviews(exercises: exercises);
  }
}

final srsGameTodayProvider = 
  StateNotifierProvider<SRSGameTodayController, AsyncValue<List<List<Exercise>>>>((ref) {
    return SRSGameTodayController(
      srsService: ref.watch(srsServiceProvider),
      );
  });

final srsCardsTodayProvider = 
  StateNotifierProvider<SRSCardsTodayController, AsyncValue<CardsToday>>((ref) {
    return SRSCardsTodayController(
      srsService: ref.watch(srsServiceProvider),
      );
  });

final srsContextProvider =
  StateNotifierProvider.family<SRSContextController, AsyncValue<Context>, ObtainContext>((ref, obtainContext) {
    return SRSContextController(
      srsService: ref.watch(srsServiceProvider),
      obtainContext: obtainContext,
    );
  });

final srsReviewUpdateProvider =
  ChangeNotifierProvider.family<SRSReviewUpdateController, List<Exercise>>((ref, exercises) {
    return SRSReviewUpdateController(
      srsService: ref.watch(srsServiceProvider),
      exercises: exercises,
    );
  });