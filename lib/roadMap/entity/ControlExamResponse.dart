import 'TaskEntity.dart';

class ControlExamResponse {
  final List<Task> tasks;

  ControlExamResponse({required this.tasks});

  factory ControlExamResponse.fromJson(Map<String, dynamic> json) {
    return ControlExamResponse(
      tasks: (json['tasks'] as List).map((e) => Task.fromJson(e)).toList(),
    );
  }
}

class Answer {
  final String correctAnswer;

  Answer({required this.correctAnswer});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(correctAnswer: json['correct_answer']);
  }
}