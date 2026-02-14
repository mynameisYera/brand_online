import 'package:brand_online/authorization/entity/RoadMapResponse.dart';

class RestartLesson {
  final int lessonId;
  final String title;
  final String? videoUrl;
  final double overallPercentage;
  final int chapterNumber;
  final List<Materials> materials;
  final List<LessonAction> actions;

  RestartLesson({
    required this.lessonId,
    required this.title,
    this.videoUrl,
    required this.overallPercentage,
    required this.chapterNumber,
    required this.materials,
    this.actions = const [],
  });

  /// Для совместимости с кодом, использующим chapterId.
  int get chapterId => chapterNumber;

  factory RestartLesson.fromJson(Map<String, dynamic> json) {
    final materialsRaw = json['materials'];
    final materialsList = materialsRaw is List
        ? (materialsRaw)
            .map((e) => Materials.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <Materials>[];
    final actionsRaw = json['actions'];
    final actionsList = actionsRaw is List
        ? (actionsRaw)
            .map((e) =>
                LessonAction.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <LessonAction>[];
    return RestartLesson(
      lessonId: (json['lesson_id'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      videoUrl: json['video_url'] as String?,
      overallPercentage:
          ((json['overall_percentage'] ?? 0.0) as num).toDouble(),
      chapterNumber: (json['chapter_number'] ?? 0) as int,
      materials: materialsList,
      actions: actionsList,
    );
  }
}
