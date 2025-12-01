class DailyReview {
  final DateTime? date;
  final int gradeId;
  final String gradeName;
  final String subjectName;
  final int targetCount;
  final int questionsCompleted;
  final int remainingTasks;
  final int totalShown;
  final int correctWithoutHelp;
  final int incorrectAttempts;
  final int points;
  final double percentage;
  final bool isCompleted;
  final bool isOpen;

  DailyReview({
    required this.date,
    required this.gradeId,
    required this.gradeName,
    required this.subjectName,
    required this.targetCount,
    required this.questionsCompleted,
    required this.remainingTasks,
    required this.totalShown,
    required this.correctWithoutHelp,
    required this.incorrectAttempts,
    required this.points,
    required this.percentage,
    required this.isCompleted,
    required this.isOpen,
  });

  factory DailyReview.fromJson(Map<String, dynamic> j) => DailyReview(
    date: (j['date'] as String?)?.isNotEmpty == true
        ? DateTime.parse(j['date'])
        : null,
    gradeId: (j['grade_id'] ?? 0) as int,
    gradeName: (j['grade_name'] ?? '') as String,
    subjectName: (j['subject_name'] ?? '') as String,
    targetCount: (j['target_count'] ?? 0) as int,
    questionsCompleted: (j['questions_completed'] ?? 0) as int,
    remainingTasks: (j['remaining_tasks'] ?? 0) as int,
    totalShown: (j['total_shown'] ?? 0) as int,
    correctWithoutHelp: (j['correct_without_help'] ?? 0) as int,
    incorrectAttempts: (j['incorrect_attempts'] ?? 0) as int,
    points: (j['points'] ?? 0) as int,
    percentage: (j['percentage'] ?? 0.0) as double,
    isCompleted: (j['is_completed'] ?? false) as bool,
    isOpen: (j['is_open'] ?? false) as bool,
  );

  double get progress =>
      targetCount == 0 ? 0 : questionsCompleted / targetCount;

  String get cta =>
      isCompleted ? 'Аяқталды' : (questionsCompleted > 0 ? 'Жалғастыру' : 'Бастау');
}