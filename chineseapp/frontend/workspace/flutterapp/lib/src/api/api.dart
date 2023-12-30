class LanguageBackendAPI {
  LanguageBackendAPI();

  static const String _apiHost = "localhost";
  static const int _apiPort = 5000;
  static const String _apiPath = "/";
  
  Uri video(String videoId) => _buildUri(
    endpoint: "vid/$videoId",
    parametersBuilder: () => {},
  );

  Uri _buildUri({
    required String endpoint,
    required Map<String, dynamic> Function() parametersBuilder,
  }) {
    return Uri(
      scheme: "http",
      host: _apiHost,
      port: _apiPort,
      path: "$_apiPath$endpoint",
      queryParameters: parametersBuilder(),
    );
  }
}