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
  final String createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final dynamic createdAtValue = json['createdAt'] ?? json['created_at'];

    return Notification(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      createdAt: createdAtValue != null ? createdAtValue.toString() : '',
    );
  }
}