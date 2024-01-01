class Streak {
  final int current;

  Streak({
    required this.current,
  });

  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      current: json["streak"],
    );
  }
}