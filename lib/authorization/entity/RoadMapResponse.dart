
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
      id: json['id'] ?? 0,
      name: (json['name'] ?? '') as String,
      url: (json['url'] ?? '') as String,
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

/// Порядок шагов на карточке урока (видео и группы заданий).
/// Бэкенд может вернуть, например: ["video", "group_1", "group_2", "group_3"]
/// или ["group_1", "video", "group_2", "group_3"].
const List<String> _defaultStepOrder = ['video', 'group_1', 'group_2', 'group_3'];

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
  /// Порядок кнопок на карточке: "video", "group_1", "group_2", "group_3".
  final List<String>? stepOrder;

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
    this.stepOrder,
  });

  /// Фактический порядок шагов: из бэкенда или по умолчанию [видео, группа1, группа2, группа3].
  List<String> get effectiveStepOrder =>
      (stepOrder != null && stepOrder!.isNotEmpty) ? stepOrder! : _defaultStepOrder;

  /// Выполнен ли шаг (видео или группа заданий).
  bool isStepCompleted(String stepType) {
    switch (stepType) {
      case 'video':
        return videoWatched;
      case 'group_1':
        return group1Completed;
      case 'group_2':
        return group2Completed;
      case 'group_3':
        return group3Completed;
      default:
        return false;
    }
  }

  /// Выполнены ли все шаги до [currentIndex] (не включая).
  bool arePreviousStepsCompleted(int currentIndex) {
    final order = effectiveStepOrder;
    for (int i = 0; i < currentIndex && i < order.length; i++) {
      if (!isStepCompleted(order[i])) return false;
    }
    return true;
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final stepOrderRaw = json['step_order'];
    List<String>? stepOrder;
    if (stepOrderRaw is List) {
      stepOrder = stepOrderRaw.map((e) => e.toString()).toList();
      if (stepOrder.isEmpty) stepOrder = null;
    }
    return Lesson(
      lessonId: (json['lesson_id'] ?? 0) as int,
      lessonTitle: (json['lesson_title'] ?? '') as String,
      lessonNumber: (json['lesson_number'] ?? 0) as int,
      videoUrl: (json['video_url'] ?? '') as String,
      videoWatched: json['video_watched'] == true,
      group1Completed: json['group1_completed'] == true,
      group2Completed: json['group2_completed'] == true,
      group3Completed: json['group3_completed'] == true,
      cashbackActive: json['cashback_active'] == true,
      isPublished: json['is_published'] == true,
      materials: ((json['materials'] as List<dynamic>?) ?? [])
          .map((e) => Materials.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      stepOrder: stepOrder,
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
      if (stepOrder != null) 'step_order': stepOrder,
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
      chapterId: (json['chapter_id'] ?? 0) as int,
      chapterName: (json['chapter_name'] ?? '') as String,
      chapterNumber: (json['chapter_number'] ?? 0) as int,
      lessons: ((json['lessons'] as List<dynamic>?) ?? [])
          .map((e) => Lesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
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
      chapters: ((json['chapters'] as List<dynamic>?) ?? [])
          .map((e) => Chapter.fromJson(Map<String, dynamic>.from(e as Map)))
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


