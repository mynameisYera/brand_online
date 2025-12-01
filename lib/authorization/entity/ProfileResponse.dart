
import 'SelectedGrade.dart';

class ProfileResponse {
  final int id;
  final int role;
  final int grade;
  final int? group;
  final int? curator;
  final int? parent;
  final String strike;
  final String points;
  final int permanent_balance;
  final int temporary_balance;
  late final String multiplier;
  final SelectedGrade? selectedGrade;
  final int? repeatLessonsCount;

  final int permanentBalance;
  final int temporaryBalance;
  final List<GradeBalance> gradeBalances;

  ProfileResponse({
    required this.id,
    required this.role,
    required this.grade,
    this.group,
    this.curator,
    this.parent,
    required this.strike,
    required this.points,
    required this.permanent_balance,
    required this.temporary_balance,
    required this.multiplier,
    required this.selectedGrade,
    required this.permanentBalance,
    required this.temporaryBalance,
    required this.gradeBalances,
    this.repeatLessonsCount,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] ?? 0,
      role: json['role'] ?? 0,
      grade: json['grade'] ?? 0,
      group: json['group'] != null ? int.tryParse(json['group'].toString()) : null,
      curator: json['curator'] != null ? int.tryParse(json['curator'].toString()) : null,
      parent: json['parent'] != null ? int.tryParse(json['parent'].toString()) : null,
      strike: json['strike'].toString(),
      points: json['points'].toString(),
      repeatLessonsCount: json['repeat_lessons_count'] != null ? int.tryParse(json['repeat_lessons_count'].toString()) : null,
      permanent_balance: json['permanent_balance'] ?? 0,
      temporary_balance: json['temporary_balance'] ?? 0,
      multiplier: json['multiplier'].toString(),
      selectedGrade: json['selected_grade'] != null
          ? SelectedGrade.fromJson(json['selected_grade'])
          : null,
      permanentBalance: json['permanent_balance'] ?? 0,
      temporaryBalance: json['temporary_balance'] ?? 0,
      gradeBalances: (json['grade_balances'] as List<dynamic>? ?? [])
          .map((e) => GradeBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class GradeBalance {
  final int gradeId;
  final String subjectName;
  final String gradeName;
  final int temporaryBalance;

  GradeBalance({
    required this.gradeId,
    required this.subjectName,
    required this.gradeName,
    required this.temporaryBalance,
  });

  factory GradeBalance.fromJson(Map<String, dynamic> json) {
    return GradeBalance(
      gradeId: json['grade_id'] ?? 0,
      subjectName: json['subject_name'] ?? '',
      gradeName: json['grade_name'] ?? '',
      temporaryBalance: json['temporary_balance'] ?? 0,
    );
  }
}