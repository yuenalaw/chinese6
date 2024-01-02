  /*return 
  {'message': 'Sentence task has been added to the queue', 'callback': task_id}, 202
*/

class UpdateSentenceCallback {
  final String taskId;

  UpdateSentenceCallback({
    required this.taskId,
  });

  factory UpdateSentenceCallback.fromJson(Map<String, dynamic> json) {
    return UpdateSentenceCallback(
      taskId: json['callback'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'callback': taskId,
    };
  }
}