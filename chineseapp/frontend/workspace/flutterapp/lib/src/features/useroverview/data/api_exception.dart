sealed class APIException implements Exception {
  APIException(this.message);
  final String message;
}

class NoInternetConnectionException extends APIException {
  NoInternetConnectionException() : super('No Internet connection');
}