class SelectedGrade {
  final int id;
  final String name;
  final String subjectName;
  final bool cashbackPending;

  SelectedGrade({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.cashbackPending,
  });

  factory SelectedGrade.fromJson(Map<String, dynamic> json) {
    return SelectedGrade(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      cashbackPending: json['cashback_pending'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject_name': subjectName,
    };
  }
}