

// Профиль пользователя
class Profile {
  final int id;
  final int role;
  final int grade;
  final int? group;
  final int? curator;
  final int? parent;
  final int strike;
  final int points;
  late String multiplier;

  Profile({
    required this.id,
    required this.role,
    required this.grade,
    this.group,
    this.curator,
    this.parent,
    required this.strike,
    required this.points,
    required this.multiplier,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      role: json['role'],
      grade: json['grade'],
      group: json['group'],
      curator: json['curator'],
      parent: json['parent'],
      strike: json['strike'],
      points: json['points'],
      multiplier: json['multiplier'].toString(), // 👈 Преобразование в String
    );
  }
}

class AnagramItem {
  final int itemId;
  final String content;
  AnagramItem({required this.itemId, required this.content});

  factory AnagramItem.fromJson(Map<String, dynamic> j) =>
      AnagramItem(itemId: j['item_id'], content: j['content'] ?? '');
}

// Модель одного задания
class Task {
  final int id;
  final int lessonId;
  final String taskType;
  final int group;
  final String content;
  final int number;
  final String? videoSolutionUrl;
  final String? audioUrl;
  final int state;
  final List<Choice> choices;
  final List<AnagramItem> anagramItems;
  final MatchingPairs? matchingPairs;
  final Answer? answer;
  final List<String> anagramSegments;      // варианты сегментов
  final List<String> anagramAnswer;        // правильная последовательность
  final int? anagramRequiredCount;         // сколько сегментов надо выбрать

  Task({
    required this.id,
    required this.lessonId,
    required this.taskType,
    required this.group,
    required this.content,
    required this.number,
    this.videoSolutionUrl,
    this.anagramItems = const [],
    this.audioUrl,
    required this.state,
    required this.choices,
    this.matchingPairs,
    this.answer,
    required this.anagramSegments,
    required this.anagramAnswer,
    required this.anagramRequiredCount,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      lessonId: json['lesson_id'],
      taskType: json['task_type'],
      group: json['group'],
      content: json['content'],
      number: json['number'] ?? 0,
      videoSolutionUrl: json['video_solution_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      state: json['state'],
      choices: ((json['choices'] as List?) ?? [])
          .map((choice) => Choice.fromJson(Map<String, dynamic>.from(choice as Map)))
          .toList(),
      matchingPairs: (json['matching_pairs'] is Map<String, dynamic>)
          ? MatchingPairs.fromJson(json['matching_pairs'])
          : null,
      answer: json['answer'] != null ? Answer.fromJson(json['answer']) : null,
      anagramItems: (json['anagram_items'] as List? ?? [])
          .map((e) => AnagramItem.fromJson(e))
          .toList(),
      anagramSegments: List<String>.from(json['anagram_segments'] ?? const []),
      anagramAnswer: List<String>.from(json['anagram_answer'] ?? const []),
      anagramRequiredCount: json['anagram_required_count'],
    );
  }
}

// Варианты ответа для multiple-choice
class Choice {
  final int id;
  final String content;
  final bool isCorrect;

  Choice({required this.id, required this.content, required this.isCorrect});

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'],
      content: json['content'],
      isCorrect: json['is_correct'],
    );
  }
}

// Модель ответа для fill-in-the-blank
class Answer {
  final int id;
  final String correctAnswer;

  Answer({required this.id, required this.correctAnswer});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'],
      correctAnswer: json['correct_answer'],
    );
  }
}

// Модель сопоставления (matching-pairs)
class MatchingPairs {
  final List<MatchingItem> leftItems;
  final List<MatchingItem> rightItems;

  MatchingPairs({required this.leftItems, required this.rightItems});

  factory MatchingPairs.fromJson(Map<String, dynamic> json) {
    return MatchingPairs(
      leftItems: (json['left_items'] as List)
          .map((item) => MatchingItem.fromJson(item))
          .toList(),
      rightItems: (json['right_items'] as List)
          .map((item) => MatchingItem.fromJson(item))
          .toList(),
    );
  }
}

// Элемент для matching-pairs
class MatchingItem {
  final int id;
  final String content;

  MatchingItem({required this.id, required this.content});

  factory MatchingItem.fromJson(Map<String, dynamic> json) {
    return MatchingItem(
      id: json['left_id'] ?? json['right_id'],
      content: json['content'],
    );
  }
}

// Главная модель
class DataModel {
  final Profile profile;
  final List<Task> tasks;

  DataModel({required this.profile, required this.tasks});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      profile: Profile.fromJson(json['profile']),
      tasks:
          (json['tasks'] as List).map((task) => Task.fromJson(task)).toList(),
    );
  }
}
