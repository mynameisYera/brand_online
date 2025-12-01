class SubjectModel {
  final int id;
  final String name;
  final String subjectName;
  final bool cashbackPending;

  SubjectModel({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.cashbackPending,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      name: json['name'],
      subjectName: json['subject_name'],
      cashbackPending: json['cashback_pending'] ?? false
    );
  }
}