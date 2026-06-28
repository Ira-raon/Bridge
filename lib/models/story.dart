class Story {
  Story({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.helpCount,
    required this.reflectionCount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String userId;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final int helpCount;
  final int reflectionCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'authorName': authorName,
        'createdAt': createdAt.toIso8601String(),
        'helpCount': helpCount,
        'reflectionCount': reflectionCount,
      };

  static Story fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        userId: json['userId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        authorName: json['authorName'] as String,
        helpCount: json['helpCount'] as int,
        reflectionCount: json['reflectionCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
} 