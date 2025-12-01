import 'LeaderboardEntry.dart';

class LeaderboardResponse {
  final List<LeaderboardEntry> top20;
  final int yourRank;
  final LeaderboardEntry you;
  final int firstPlace;
  final int secondPlace;
  final int thirdPlace;

  LeaderboardResponse({
    required this.top20,
    required this.yourRank,
    required this.you,
    required this.firstPlace,
    required this.secondPlace,
    required this.thirdPlace
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      top20: (json['top_20'] as List)
          .map((item) => LeaderboardEntry.fromJson(item))
          .toList(),
      yourRank: json['your_rank'] ?? -1,
      you: LeaderboardEntry.fromJson(json['you']),
      firstPlace: json['first_place'] ?? 0,
      secondPlace: json['second_place'] ?? 0,
      thirdPlace: json['third_place'] ?? 0,
    );
  }
}