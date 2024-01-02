class PleaseWaitVidOrSentence {
  final String message;

  PleaseWaitVidOrSentence({
    required this.message,
  });

  factory PleaseWaitVidOrSentence.fromJson(Map<String, dynamic> json) {
    return PleaseWaitVidOrSentence(
      message: json['message'],
    );
  }
}