import 'package:brand_online/authorization/entity/SelectedGrade.dart';
import 'package:brand_online/roadMap/entity/TaskEntity.dart';

// Модель профиля для ежедневных заданий
class DailyProfile {
  final int id;
  final int role;
  final int grade;
  final int? group;
  final int strike;
  final int points;
  final int multiplier;
  final SelectedGrade selectedGrade;
  final int permanentBalance;
  final int temporaryBalance;
  final List<GradeBalance> gradeBalances;
  final int repeatLessonsCount;

  DailyProfile({
    required this.id,
    required this.role,
    required this.grade,
    this.group,
    required this.strike,
    required this.points,
    required this.multiplier,
    required this.selectedGrade,
    required this.permanentBalance,
    required this.temporaryBalance,
    required this.gradeBalances,
    required this.repeatLessonsCount,
  });

  factory DailyProfile.fromJson(Map<String, dynamic> json) {
    return DailyProfile(
      id: json['id'] ?? 0,
      role: json['role'] ?? 0,
      grade: json['grade'] ?? 0,
      group: json['group'],
      strike: json['strike'] ?? 0,
      points: json['points'] ?? 0,
      multiplier: json['multiplier'] ?? 0,
      selectedGrade: SelectedGrade.fromJson(json['selected_grade'] ?? {}),
      permanentBalance: json['permanent_balance'] ?? 0,
      temporaryBalance: json['temporary_balance'] ?? 0,
      gradeBalances: (json['grade_balances'] as List? ?? [])
          .map((item) => GradeBalance.fromJson(item))
          .toList(),
      repeatLessonsCount: json['repeat_lessons_count'] ?? 0,
    );
  }

  // Преобразование DailyProfile в Profile
  Profile toProfile() {
    return Profile(
      id: id,
      role: role,
      grade: grade,
      group: group,
      curator: null,
      parent: null,
      strike: strike,
      points: points,
      multiplier: multiplier.toString(),
    );
  }
}

// Модель баланса по классу
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

// Модель сессии
class DailySession {
  final String date;
  final int gradeId;
  final String gradeName;
  final String subjectName;
  final int targetCount;
  final int questionsCompleted;
  final int remainingTasks;
  final int totalShown;
  final int correctFirstTry;
  final int points;
  final bool isCompleted;
  final int totalTasks;
  final int completedTasks;

  DailySession({
    required this.date,
    required this.gradeId,
    required this.gradeName,
    required this.subjectName,
    required this.targetCount,
    required this.questionsCompleted,
    required this.remainingTasks,
    required this.totalShown,
    required this.correctFirstTry,
    required this.points,
    required this.isCompleted,
    required this.totalTasks,
    required this.completedTasks,
  });

  factory DailySession.fromJson(Map<String, dynamic> json) {
    return DailySession(
      date: json['date'] ?? '',
      gradeId: json['grade_id'] ?? 0,
      gradeName: json['grade_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      targetCount: json['target_count'] ?? 0,
      questionsCompleted: json['questions_completed'] ?? 0,
      remainingTasks: json['remaining_tasks'] ?? 0,
      totalShown: json['total_shown'] ?? 0,
      correctFirstTry: json['correct_first_try'] ?? 0,
      points: json['points'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
    );
  }
}


// Варианты ответа для multiple-choice
class DailyChoice {
  final int id;
  final String content;
  final bool isCorrect;

  DailyChoice({
    required this.id,
    required this.content,
    required this.isCorrect,
  });

  factory DailyChoice.fromJson(Map<String, dynamic> json) {
    return DailyChoice(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

// Модель задания для ежедневных заданий
class DailyTask {
  final int id;
  final int lessonId;
  final String taskType;
  final int group;
  final String content;
  final int? number;
  final String? videoSolutionUrl;
  final String? audioUrl;
  final int state;
  final List<DailyChoice> choices;
  final List<dynamic> matchingPairs;
  final List<String> anagramSegments;
  final List<String> anagramAnswer;
  final int anagramRequiredCount;
  final dynamic answer;

  DailyTask({
    required this.id,
    required this.lessonId,
    required this.taskType,
    required this.group,
    required this.content,
    this.number,
    this.videoSolutionUrl,
    this.audioUrl,
    required this.state,
    required this.choices,
    required this.matchingPairs,
    required this.anagramSegments,
    required this.anagramAnswer,
    required this.anagramRequiredCount,
    this.answer,
  });

  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] ?? 0,
      lessonId: json['lesson_id'] ?? 0,
      taskType: json['task_type'] ?? '',
      group: json['group'] ?? 0,
      content: json['content'] ?? '',
      number: json['number'],
      videoSolutionUrl: json['video_solution_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      state: json['state'] ?? 0,
      choices: (json['choices'] as List? ?? [])
          .map((choice) => DailyChoice.fromJson(choice))
          .toList(),
      matchingPairs: json['matching_pairs'] as List? ?? [],
      anagramSegments: List<String>.from(json['anagram_segments'] ?? const []),
      anagramAnswer: List<String>.from(json['anagram_answer'] ?? const []),
      anagramRequiredCount: json['anagram_required_count'] ?? 0,
      answer: json['answer'],
    );
  }
}

// Главная модель для ежедневных заданий
class DailyEntity {
  final DailyProfile profile;
  /// Сессия приходит с бэкенда только в части эндпоинтов; при отсутствии
  /// подставляется сессия из [profile.selectedGrade] для совместимости UI.
  final DailySession session;
  final List<Task> tasks;

  DailyEntity({
    required this.profile,
    required this.session,
    required this.tasks,
  });

  factory DailyEntity.fromJson(Map<String, dynamic> json) {
    final profile = DailyProfile.fromJson(json['profile'] ?? {});
    final sessionJson = json['session'];
    final DailySession session = sessionJson != null && sessionJson is Map<String, dynamic> && sessionJson.isNotEmpty
        ? DailySession.fromJson(sessionJson)
        : _sessionFromProfile(profile);
    return DailyEntity(
      profile: profile,
      session: session,
      tasks: (json['tasks'] as List? ?? [])
          .map((task) => Task.fromJson(task))
          .toList(),
    );
  }

  static DailySession _sessionFromProfile(DailyProfile profile) {
    final sg = profile.selectedGrade;
    return DailySession(
      date: '',
      gradeId: sg.id,
      gradeName: sg.name,
      subjectName: sg.subjectName,
      targetCount: 0,
      questionsCompleted: 0,
      remainingTasks: 0,
      totalShown: 0,
      correctFirstTry: 0,
      points: 0,
      isCompleted: false,
      totalTasks: 0,
      completedTasks: 0,
    );
  }
}
