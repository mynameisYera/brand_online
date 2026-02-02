class SubjectModel {
  final int id;
  final String name;
  final String subjectName;
  final bool cashbackPending;
  final int percentage;

  SubjectModel({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.cashbackPending,
    required this.percentage,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final rawPercentage =
        json['percentage'] ?? json['progress'] ?? json['completion'] ?? json['percent'];
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      subjectName: json['subject_name'],
      cashbackPending: json['cashback_pending'] ?? false,
      percentage: _normalizePercentage(rawPercentage),
    );
  }

  static int _normalizePercentage(dynamic raw) {
    if (raw == null) return 0;
    final double value =
        (raw is num) ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0;
    if (value <= 1) {
      return (value * 100).round();
    }
    return value.round();
  }
}