import 'package:brand_online/authorization/entity/RoadMapResponse.dart';

class RestartLesson {
  final int lessonId;
  final String title;
  final String videoUrl;
  final double overallPercentage;
  final int chapterId;
  final List<Materials> materials;

  RestartLesson({
    required this.lessonId,
    required this.title,
    required this.videoUrl,
    required this.overallPercentage,
    required this.chapterId,
    required this.materials,
  });

  factory RestartLesson.fromJson(Map<String, dynamic> json) {
    return RestartLesson(
      lessonId: json['lesson_id'],
      title: json['title'],
      videoUrl: json['video_url'],
      overallPercentage: json['overall_percentage'],
      chapterId: json['chapter_number'],
      materials: (json['materials'] as List<dynamic>)
      .map((e) => Materials.fromJson(e))
      .toList(),
    );
  }
}
