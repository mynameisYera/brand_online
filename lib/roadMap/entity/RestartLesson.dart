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
      lessonId: (json['lesson_id'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      videoUrl: json['video_url']?.toString() ?? '',
      overallPercentage: (json['overall_percentage'] ?? 0.0).toDouble(),
      chapterId: (json['chapter_number'] ?? 0) as int,
      materials: (json['materials'] is List<dynamic>
              ? (json['materials'] as List<dynamic>)
              : <dynamic>[])
          .map((e) => Materials.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
