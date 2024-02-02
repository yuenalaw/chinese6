import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_service.dart';
import 'package:flutterapp/src/features/makereviews/domain/search_result.dart';

class SearchResultsController extends StateNotifier<AsyncValue<List<SearchResult>>> {

  SearchResultsController({ required this.makeReviewService, required this.query }): super(const AsyncValue.loading()) {
    fetchImages();
  }
  final String query;
  final MakeReviewService makeReviewService;

  Future<void> fetchImages() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => makeReviewService.fetchImageSearchResults(query)
    );
  }
}

final searchResultsProvider = 
  StateNotifierProvider.family<SearchResultsController, AsyncValue<List<SearchResult>>, String>((ref, query) {
    return SearchResultsController(
      makeReviewService: ref.watch(makeReviewServiceProvider),
      query: query,
    );
  });