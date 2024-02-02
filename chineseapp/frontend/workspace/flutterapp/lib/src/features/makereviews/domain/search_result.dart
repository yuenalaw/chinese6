import 'package:googleapis/customsearch/v1.dart' as customSearch;

class SearchResult {
  final customSearch.Result result;

  SearchResult({required this.result});
  SearchResult.escapeLineBreakInSnippet(this.result) {
    this.result.snippet = this.result.snippet!.replaceAll("\n", "");
  }

  @override 
  String toString() {
    return 'title:${this.result.title}, snippet:${this.result.snippet}';
  }

  String? getContextLink() {
    return this.result.image?.contextLink;
  }
  
}