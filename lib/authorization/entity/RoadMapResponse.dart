
class Materials {
  final int id;
  final String name;
  final String url;



  Materials({
    required this.id,
    required this.name,
    required this.url,

  });

  factory Materials.fromJson(Map<String, dynamic> json) {
    return Materials(
      id: json['id'],
      name: json['name'],
      url: json['url'],

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
    };
  }
}

class Lesson {
  final int lessonId;
  final String lessonTitle;
  final int lessonNumber;
  final String videoUrl;
  late bool videoWatched;
  late final bool group1Completed;
  late final bool group2Completed;
  late final bool group3Completed;
  final bool isPublished;
  final bool cashbackActive;
  final List<Materials> materials;

  Lesson({
    required this.lessonId,
    required this.lessonTitle,
    required this.lessonNumber,
    required this.videoUrl,
    required this.videoWatched,
    required this.group1Completed,
    required this.group2Completed,
    required this.group3Completed,
    required this.cashbackActive,
    required this.isPublished,
    required this.materials,

  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lesson_id'],
      lessonTitle: json['lesson_title'],
      lessonNumber: json['lesson_number'],
      videoUrl: json['video_url'],
      videoWatched: json['video_watched'],
      group1Completed: json['group1_completed'],
      group2Completed: json['group2_completed'],
      group3Completed: json['group3_completed'],
      cashbackActive: json['cashback_active'] ?? false,
      isPublished: json['is_published'],
      materials: (json['materials'] as List<dynamic>)
      .map((e) => Materials.fromJson(e))
      .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'lesson_title': lessonTitle,
      'lesson_number': lessonNumber,
      'video_url': videoUrl,
      'video_watched': videoWatched,
      'group1_completed': group1Completed,
      'cashback_active': cashbackActive,
      'group2_completed': group2Completed,
      'group3_completed': group3Completed,
      'is_published': isPublished,
      'materials': materials,
    };
  }
}

class Chapter {
  final int chapterId;
  final String chapterName;
  final int chapterNumber;
  final List<Lesson> lessons;

  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.chapterNumber,
    required this.lessons,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapter_id'],
      chapterName: json['chapter_name'],
      chapterNumber: json['chapter_number'],
      lessons: (json['lessons'] as List).map((e) => Lesson.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'chapter_number': chapterNumber,
      'lessons': lessons.map((e) => e.toJson()).toList(),
    };
  }
}



class LessonResponse {
  final List<Chapter> chapters;
  final bool hasNoSubscription;
  final String? noSubTitle;
  final String? noSubMessage;
  final String? noSubButtonText;
  final String? noSubWhatsAppUrl;

  LessonResponse({
    required this.chapters,
    this.hasNoSubscription = false,
    this.noSubTitle,
    this.noSubMessage,
    this.noSubButtonText,
    this.noSubWhatsAppUrl,
  });

  /// Обычный fromJson (если 200)
  factory LessonResponse.fromJson(Map<String, dynamic> json) {
    return LessonResponse(
      chapters: (json['chapters'] as List<dynamic>)
          .map((e) => Chapter.fromJson(e))
          .toList(),
    );
  }

  /// ✅ Этот фабричный метод для случая 403
  factory LessonResponse.noSubscription({
    required String title,
    required String message,
    required String buttonMessage,
    required String whatsappUrl,
  }) {
    return LessonResponse(
      chapters: [],
      hasNoSubscription: true,
      noSubTitle: title,
      noSubMessage: message,
      noSubButtonText: buttonMessage,
      noSubWhatsAppUrl: whatsappUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'hasNoSubscription': hasNoSubscription,
      'noSubTitle': noSubTitle,
      'noSubMessage': noSubMessage,
      'noSubButtonText': noSubButtonText,
      'noSubWhatsAppUrl': noSubWhatsAppUrl,
    };
  }
}


