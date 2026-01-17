import 'DailyReview.dart';
import 'RestartLesson.dart';
import 'daily_entity.dart';

class ControlExam {
  final String? date;
  final bool isOpen;

  ControlExam({this.date, required this.isOpen});

  factory ControlExam.fromJson(Map<String, dynamic> json) {
    return ControlExam(
      date: json['date'],
      isOpen: json['is_open'],
    );
  }
}

class RestartLessonsResponse {
  final List<RestartLesson> lessons;
  final ControlExam? controlExam;
  final DailyReview? dailyReview;
  final List<DailySession>? dailySubjectTasks;

  RestartLessonsResponse({
    required this.lessons,
    this.controlExam,
    this.dailyReview,
    this.dailySubjectTasks,
  });

  factory RestartLessonsResponse.fromJson(Map<String, dynamic> json) {
    return RestartLessonsResponse(
      lessons: (json['lessons'] as List)
          .map((e) => RestartLesson.fromJson(e))
          .toList(),
      controlExam: json['control_exam'] != null
          ? ControlExam.fromJson(json['control_exam'])
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
