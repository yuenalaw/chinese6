class LanguageBackendAPI {
  LanguageBackendAPI();


  static const String _apiHost = "10.0.2.2"; 
  static const int _apiPort = 5001;
  static const String _apiPath = "/";
  
  Uri video(String videoId) => _buildUri(
    endpoint: "getlesson/$videoId",
    parametersBuilder: () => {},
  );

  Uri word(String word) => _buildUri(
    endpoint: "getword/$word",
    parametersBuilder: () => {},
  );

  Uri userWordSentence(String word, String videoId, String lineChanged) => _buildUri(
    endpoint: "getusersentence/$word/$videoId/$lineChanged",
    parametersBuilder: () => {},
  );

  Uri updateSentence() => _buildUri(
    endpoint: "updatesentence", 
    parametersBuilder: () => {},
  );

  Uri updateImage() => _buildUri(
    endpoint: "updateimagepath",
    parametersBuilder: () => {},
  );

  Uri updateNote() => _buildUri(
    endpoint: "updatenote",
    parametersBuilder: () => {},
  );

  Uri addReview() => _buildUri(
    endpoint: "addnewreview",
    parametersBuilder: () => {},
  );

  Uri getCardsToday() => _buildUri(
    endpoint:"getcardstoday",
    parametersBuilder: () => {},
  );

  Uri updateReviewStats() => _buildUri(
    endpoint: "updatereview",
    parametersBuilder: () => {},
  );

  Uri batchUpdateReviews() => _buildUri(
    endpoint: "batchupdatereviews",
    parametersBuilder: () => {},
  );

  Uri getContext(String videoId, int lineChanged) => _buildUri(
    endpoint: "getcontext/$videoId/$lineChanged",
    parametersBuilder: () => {},
  );

  Uri getLibrary() => _buildUri(
    endpoint: "getlibrary",
    parametersBuilder: () => {},
  );

  Uri getStreak() => _buildUri(
    endpoint: "getstreak",
    parametersBuilder: () => {},
  );

  Uri addNewStudyDay() => _buildUri(
    endpoint: "addstudydate",
    parametersBuilder: () => {},
  );

  Uri updateTitle() => _buildUri(
    endpoint: "updatetitle",
    parametersBuilder: () => {},
  );

  Uri postYouTubeRequest() => _buildUri(
    endpoint: "vid", 
    parametersBuilder: () => {},
  );

  Uri postDisneyRequest() => _buildUri(
    endpoint: "posttranscriptdisney", 
    parametersBuilder: () => {},
  );

  Uri checkSentenceTask(String taskId) => _buildUri(
    endpoint: "updatesentencetask/$taskId",
    parametersBuilder: () => {},
  );

  Uri getUpdatedSentence(String videoId, int lineChanged) => _buildUri(
    endpoint: "getupdatedsentence/$videoId/$lineChanged",
    parametersBuilder: () => {},
  );

  Uri _buildUri({
    required String endpoint,
    required Map<String, dynamic> Function() parametersBuilder,
  }) {
    Map<String, dynamic> parameters = parametersBuilder();
    Uri uri = Uri(
      scheme: "http",
      host: _apiHost,
      port: _apiPort,
      path: "$_apiPath$endpoint",
      queryParameters: parameters.isNotEmpty ? parameters : null
    );
    return uri;
  }
}