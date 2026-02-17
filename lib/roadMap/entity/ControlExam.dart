import 'DailyReview.dart';
import 'RestartLesson.dart';
import 'daily_entity.dart';
import 'TaskEntity.dart';

class ControlExam {
  final String? date;
  final bool isOpen;

  ControlExam({this.date, required this.isOpen});

  factory ControlExam.fromJson(Map<String, dynamic> json) {
    return ControlExam(
      date: json['date'] as String?,
      isOpen: json['is_open'] == true,
    );
  }
}

/// Попытка прохождения mock exam.
class MockExamAttempt {
  final int answeredCount;
  final int correctCount;
  final int incorrectCount;
  final double percentage;
  final bool isCompleted;
  final String? startedAt;
  final String? completedAt;

  MockExamAttempt({
    required this.answeredCount,
    required this.correctCount,
    required this.incorrectCount,
    required this.percentage,
    required this.isCompleted,
    this.startedAt,
    this.completedAt,
  });

  factory MockExamAttempt.fromJson(Map<String, dynamic> json) {
    return MockExamAttempt(
      answeredCount: (json['answered_count'] ?? 0) as int,
      correctCount: (json['correct_count'] ?? 0) as int,
      incorrectCount: (json['incorrect_count'] ?? 0) as int,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      isCompleted: json['is_completed'] == true,
      startedAt: json['started_at'] as String?,
      completedAt: json['completed_at'] as String?,
    );
  }
}

/// Mock exam из ответа restart/главной.
class MockExam {
  final int id;
  final String title;
  final int gradeId;
  final String gradeName;
  final String subjectName;
  final int taskCount;
  final String status;
  final MockExamAttempt attempt;
  final String? createdAt;

  MockExam({
    required this.id,
    required this.title,
    required this.gradeId,
    required this.gradeName,
    required this.subjectName,
    required this.taskCount,
    required this.status,
    required this.attempt,
    this.createdAt,
  });

  factory MockExam.fromJson(Map<String, dynamic> json) {
    return MockExam(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      gradeId: (json['grade_id'] ?? 0) as int,
      gradeName: (json['grade_name'] ?? '') as String,
      subjectName: (json['subject_name'] ?? '') as String,
      taskCount: (json['task_count'] ?? 0) as int,
      status: (json['status'] ?? '') as String,
      attempt: json['attempt'] != null
          ? MockExamAttempt.fromJson(json['attempt'] as Map<String, dynamic>)
          : MockExamAttempt(
              answeredCount: 0,
              correctCount: 0,
              incorrectCount: 0,
              percentage: 0,
              isCompleted: false,
            ),
      createdAt: json['created_at'] as String?,
    );
  }
}

/// Один ответ пользователя в сынақе (элемент массива answers).
class MockExamAnswer {
  final int taskId;
  final String taskType;
  final bool isCorrect;
  final Map<String, dynamic>? userAnswer;
  final Map<String, dynamic>? correctAnswer;
  final String? answeredAt;

  MockExamAnswer({
    required this.taskId,
    required this.taskType,
    required this.isCorrect,
    this.userAnswer,
    this.correctAnswer,
    this.answeredAt,
  });

  static Map<String, dynamic>? _normalizeAnswer(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    if (raw is List) {
      return {'segments': raw.map((e) => e?.toString() ?? '').toList()};
    }
    return null;
  }

  factory MockExamAnswer.fromJson(Map<String, dynamic> json) {
    return MockExamAnswer(
      taskId: (json['task_id'] ?? 0) as int,
      taskType: (json['task_type'] ?? '') as String,
      isCorrect: json['is_correct'] == true,
      userAnswer: _normalizeAnswer(json['user_answer']),
      correctAnswer: _normalizeAnswer(json['correct_answer']),
      answeredAt: json['answered_at'] as String?,
    );
  }
}

/// Ответ API GET /edu/mock-exams/:id/tasks (задания + ответы при завершённом сынақе).
class MockExamTasksResponse {
  final MockExam exam;
  final bool isCompleted;
  final List<Task> tasks;
  final List<MockExamAnswer> answers;

  MockExamTasksResponse({
    required this.exam,
    required this.isCompleted,
    required this.tasks,
    this.answers = const [],
  });

  factory MockExamTasksResponse.fromJson(Map<String, dynamic> json) {
    final tasksRaw = json['tasks'];
    final tasksList = tasksRaw is List
        ? (tasksRaw)
            .map((e) => Task.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <Task>[];
    final answersRaw = json['answers'];
    final answersList = answersRaw is List
        ? (answersRaw)
            .map((e) => MockExamAnswer.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <MockExamAnswer>[];
    return MockExamTasksResponse(
      exam: MockExam.fromJson(json['exam'] as Map<String, dynamic>),
      isCompleted: json['is_completed'] == true,
      tasks: tasksList,
      answers: answersList,
    );
  }
}

class RestartLessonsResponse {
  final List<RestartLesson> lessons;
  final ControlExam? controlExam;
  final MockExam? mockExam;
  final DailyReview? dailyReview;
  final List<DailySession>? dailySubjectTasks;

  RestartLessonsResponse({
    required this.lessons,
    this.controlExam,
    this.mockExam,
    this.dailyReview,
    this.dailySubjectTasks,
  });

  factory RestartLessonsResponse.fromJson(Map<String, dynamic> json) {
    return RestartLessonsResponse(
      lessons: ((json['lessons'] as List?) ?? [])
          .map((e) => RestartLesson.fromJson(e as Map<String, dynamic>))
          .toList(),
      controlExam: json['control_exam'] != null
          ? ControlExam.fromJson(json['control_exam'] as Map<String, dynamic>)
          : null,
      mockExam: json['mock_exam'] != null
          ? MockExam.fromJson(json['mock_exam'] as Map<String, dynamic>)
          : null,
      dailyReview: json['daily_review'] == null
          ? null
          : DailyReview.fromJson(json['daily_review'] as Map<String, dynamic>),
      dailySubjectTasks: json['daily_subject_tasks'] == null
          ? null
          : (json['daily_subject_tasks'] as List)
              .map((e) => DailySession.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
