class NewsDetailed {
  final int id;
  final String title;
  String content;
  final DateTime publishedAt;

  NewsDetailed({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
  });

  factory NewsDetailed.fromJson(Map<String, dynamic> json) {
    return NewsDetailed(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      publishedAt: DateTime.parse(json['published_at']),
    );
  }
}