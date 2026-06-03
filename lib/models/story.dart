class Story {
  Story({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'author': author,
        'createdAt': createdAt.toIso8601String(),
      };

  static Story fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        author: json['author'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
