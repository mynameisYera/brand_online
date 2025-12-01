import 'ControlExam.dart';
import 'RestartLesson.dart';

class RestartResponse {
  final List<RestartLesson> lessons;
  final ControlExam controlExam;


  RestartResponse({
    required this.lessons,
    required this.controlExam,
  });

  factory RestartResponse.fromJson(Map<String, dynamic> json) {
    return RestartResponse(
      lessons: (json['lessons'] as List)
          .map((e) => RestartLesson.fromJson(e))
          .toList(),
      controlExam: ControlExam.fromJson(json['control_exam']),
    );
  }
}