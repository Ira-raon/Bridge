class DiscussionMessage {
  const DiscussionMessage({
    required this.id,
    required this.author,
    required this.body,
    required this.sentAt,
    this.isSystem = false,
  });

  final String id;
  final String author;
  final String body;
  final DateTime sentAt;
  final bool isSystem;
}

class DiscussionForumPost {
  const DiscussionForumPost({
    required this.id,
    required this.author,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final String author;
  final String body;
  final DateTime sentAt;
}

class DiscussionForum {
  const DiscussionForum({
    required this.id,
    required this.topicId,
    required this.title,
    required this.createdAt,
    required this.popularityScore,
    required this.posts,
  });

  final String id;
  final String topicId;
  final String title;
  final DateTime createdAt;
  final int popularityScore;
  final List<DiscussionForumPost> posts;

  DiscussionForum copyWith({
    int? popularityScore,
    List<DiscussionForumPost>? posts,
  }) {
    return DiscussionForum(
      id: id,
      topicId: topicId,
      title: title,
      createdAt: createdAt,
      popularityScore: popularityScore ?? this.popularityScore,
      posts: posts ?? this.posts,
    );
  }
}

class DiscussionRoom {
  const DiscussionRoom({
    required this.id,
    required this.topicId,
    required this.topicTitle,
    required this.matchName,
    required this.messages,
    required this.lastUpdated,
  });

  final String id;
  final String topicId;
  final String topicTitle;
  final String matchName;
  final List<DiscussionMessage> messages;
  final DateTime lastUpdated;

  DiscussionRoom copyWith({
    List<DiscussionMessage>? messages,
    DateTime? lastUpdated,
  }) {
    return DiscussionRoom(
      id: id,
      topicId: topicId,
      topicTitle: topicTitle,
      matchName: matchName,
      messages: messages ?? this.messages,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}