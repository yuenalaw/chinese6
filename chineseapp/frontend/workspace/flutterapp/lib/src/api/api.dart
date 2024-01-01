class LanguageBackendAPI {
  LanguageBackendAPI();

  static const String _apiHost = "localhost";
  static const int _apiPort = 5000;
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

  Uri addReview() => _buildUri(
    endpoint: "addnewreview",
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

  Uri _buildUri({
    required String endpoint,
    required Map<String, dynamic> Function() parametersBuilder,
  }) {
    Map<String, dynamic> parameters = parametersBuilder();
    return Uri(
      scheme: "http",
      host: _apiHost,
      port: _apiPort,
      path: "$_apiPath$endpoint",
      queryParameters: parameters.isNotEmpty ? parameters : null
    );
  }
}