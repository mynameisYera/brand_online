class LeaderboardEntry {
  final String firstName;
  final String lastName;
  final int points;
  final int weeklyPoints;
  final int monthlyPoints;
  final int grade;
  final int strike;

  LeaderboardEntry({
    required this.firstName,
    required this.lastName,
    required this.points,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.grade,
    required this.strike,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      points: json['points'] ?? 0,
      weeklyPoints: json['weekly_points'] ?? 0,
      monthlyPoints: json['monthly_points'] ?? 0,
      grade: json['grade'] ?? 0,
      strike: json['strike'] ?? 0, // 🔑 если strike null, ставим 0
    );
  }
}