class News {
  final int id;
  final String title;
  final DateTime publishedAt;

  News({
    required this.id,
    required this.title,
    required this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title'],
      publishedAt: DateTime.parse(json['published_at']),
    );
  }
}

class Notification {
  final int id;
  final String title;
  final String body;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });


factory Notification.fromJson(Map<String, dynamic> json) {
  return Notification(
    id: json['id'],
    title: json['title'],
    body: json['body'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
}