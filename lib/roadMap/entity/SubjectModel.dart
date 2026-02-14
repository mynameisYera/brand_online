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
    this.percentage = 0,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    final rawPercentage =
        json['percentage'] ?? json['progress'] ?? json['completion'] ?? json['percent'];
    return SubjectModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      subjectName: (json['subject_name'] ?? '') as String,
      cashbackPending: json['cashback_pending'] == true,
      percentage: int.tryParse((json['percentage'] ?? 0).toString()) ?? 0,
    );
  }
}