import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/discussion_room.dart';
import '../models/discussion_topic.dart';
import '../models/match_profile.dart';

class DiscussionService {
  DiscussionService._privateConstructor();

  static final DiscussionService _instance = DiscussionService._privateConstructor();

  static DiscussionService get instance => _instance;

  final _uuid = const Uuid();

  final ValueNotifier<List<DiscussionTopic>> topics = ValueNotifier<List<DiscussionTopic>>([
    DiscussionTopic(
      id: 'topic-career-transition',
      matchId: 'sandra-retiree',
      matchName: 'Sandra',
      roomId: 'room-career-transition',
      category: AdviceTopic.careerAdvice,
      title: 'Career transition planning',
      cadence: DiscussionCadence.weekly,
      goal: 'Work through a career change with practical next steps.',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      progressScore: 64,
      sessions: [
        DiscussionSession(
          id: 'session-career-1',
          happenedAt: DateTime.now().subtract(const Duration(days: 10)),
          summary: 'Talked through the first reason for changing roles.',
          reflection: 'I understand the next move better and feel less stuck.',
          nextStep: 'Update the profile and shortlist two roles.',
          progressDelta: 18,
        ),
        DiscussionSession(
          id: 'session-career-2',
          happenedAt: DateTime.now().subtract(const Duration(days: 3)),
          summary: 'Reviewed portfolio gaps and interview concerns.',
          reflection: 'We narrowed the advice to a realistic 2-week plan.',
          nextStep: 'Draft interview stories and schedule a follow-up.',
          progressDelta: 22,
        ),
      ],
    ),
    DiscussionTopic(
      id: 'topic-relationships-support',
      matchId: 'ruth-retired-nurse',
      matchName: 'Ruth',
      roomId: 'room-relationships-support',
      category: AdviceTopic.personalRelationships,
      title: 'Relationship boundaries',
      cadence: DiscussionCadence.monthly,
      goal: 'Build calmer habits for hard conversations.',
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
      progressScore: 48,
      sessions: [
        DiscussionSession(
          id: 'session-relationships-1',
          happenedAt: DateTime.now().subtract(const Duration(days: 18)),
          summary: 'Talked about boundaries that keep repeating.',
          reflection: 'The advice was empathetic and helped me name the pattern.',
          nextStep: 'Write down a boundary script for the next conversation.',
          progressDelta: 14,
        ),
      ],
    ),
  ]);

  final ValueNotifier<List<DiscussionRoom>> rooms = ValueNotifier<List<DiscussionRoom>>([
    DiscussionRoom(
      id: 'room-career-transition',
      topicId: 'topic-career-transition',
      topicTitle: 'Career transition planning',
      matchName: 'Sandra',
      messages: [
        DiscussionMessage(
          id: 'msg-career-1',
          author: 'Sandra',
          body: 'Let us keep this focused on the role change and the next two weeks.',
          sentAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        DiscussionMessage(
          id: 'msg-career-2',
          author: 'You',
          body: 'I need a simple plan I can actually follow.',
          sentAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DiscussionRoom(
      id: 'room-relationships-support',
      topicId: 'topic-relationships-support',
      topicTitle: 'Relationship boundaries',
      matchName: 'Ruth',
      messages: const [],
      lastUpdated: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ]);

  final ValueNotifier<List<DiscussionForum>> forums = ValueNotifier<List<DiscussionForum>>([]);

  List<DiscussionSession> get recentSessions {
    final all = topics.value
        .expand(
          (topic) => topic.sessions.map(
            (session) => _TopicSessionPair(topic: topic, session: session),
          ),
        )
        .toList()
      ..sort((a, b) => b.session.happenedAt.compareTo(a.session.happenedAt));
    return all.map((pair) => pair.session).toList();
  }

  DiscussionTopic? findTopic(String id) {
    try {
      return topics.value.firstWhere((topic) => topic.id == id);
    } catch (_) {
      return null;
    }
  }

  DiscussionRoom? findRoomByTopicId(String topicId) {
    try {
      return rooms.value.firstWhere((room) => room.topicId == topicId);
    } catch (_) {
      return null;
    }
  }

  DiscussionForum? findForumByTopicId(String topicId) {
    try {
      return forums.value.firstWhere((forum) => forum.topicId == topicId);
    } catch (_) {
      return null;
    }
  }

  void addTopic(DiscussionTopic topic) {
    final list = List<DiscussionTopic>.from(topics.value);
    list.insert(0, topic);
    topics.value = list;
    _ensureRoomForTopic(topic);
  }

  void addSession({
    required String topicId,
    required String summary,
    required String reflection,
    required String nextStep,
    required int progressDelta,
  }) {
    final list = List<DiscussionTopic>.from(topics.value);
    final index = list.indexWhere((topic) => topic.id == topicId);
    if (index == -1) {
      return;
    }

    final topic = list[index];
    final updatedSessions = List<DiscussionSession>.from(topic.sessions)
      ..insert(
        0,
        DiscussionSession(
          id: 'session-${DateTime.now().microsecondsSinceEpoch}',
          happenedAt: DateTime.now(),
          summary: summary,
          reflection: reflection,
          nextStep: nextStep,
          progressDelta: progressDelta,
        ),
      );

    final nextProgress = (topic.progressScore + progressDelta).clamp(0, 100);
    final updatedTopic = topic.copyWith(
      sessions: updatedSessions,
      progressScore: nextProgress,
    );
    list[index] = updatedTopic;
    topics.value = list;

    _appendRoomSessionMessage(updatedTopic, summary, reflection, nextStep);
    _ensureForumForTopic(updatedTopic);
  }

  void addRoomMessage({
    required String roomId,
    required String author,
    required String body,
    bool isSystem = false,
  }) {
    final list = List<DiscussionRoom>.from(rooms.value);
    final index = list.indexWhere((room) => room.id == roomId);
    if (index == -1) {
      return;
    }

    final room = list[index];
    final updatedMessages = List<DiscussionMessage>.from(room.messages)
      ..insert(
        0,
        DiscussionMessage(
          id: _uuid.v4(),
          author: author,
          body: body,
          sentAt: DateTime.now(),
          isSystem: isSystem,
        ),
      );

    list[index] = room.copyWith(
      messages: updatedMessages,
      lastUpdated: DateTime.now(),
    );
    rooms.value = list;
  }

  void addForumPost({
    required String forumId,
    required String author,
    required String body,
  }) {
    final list = List<DiscussionForum>.from(forums.value);
    final index = list.indexWhere((forum) => forum.id == forumId);
    if (index == -1) {
      return;
    }

    final forum = list[index];
    final updatedPosts = List<DiscussionForumPost>.from(forum.posts)
      ..insert(
        0,
        DiscussionForumPost(
          id: _uuid.v4(),
          author: author,
          body: body,
          sentAt: DateTime.now(),
        ),
      );

    list[index] = forum.copyWith(
      popularityScore: forum.popularityScore + 1,
      posts: updatedPosts,
    );
    forums.value = list;
  }

  void _ensureRoomForTopic(DiscussionTopic topic) {
    if (findRoomByTopicId(topic.id) != null) {
      return;
    }

    final list = List<DiscussionRoom>.from(rooms.value)
      ..insert(
        0,
        DiscussionRoom(
          id: topic.roomId,
          topicId: topic.id,
          topicTitle: topic.title,
          matchName: topic.matchName,
          messages: [
            DiscussionMessage(
              id: _uuid.v4(),
              author: 'Bridge',
              body: 'Chatroom created for ${topic.title}. Keep the discussion focused and structured.',
              sentAt: DateTime.now(),
              isSystem: true,
            ),
          ],
          lastUpdated: DateTime.now(),
        ),
      );
    rooms.value = list;
  }

  void _appendRoomSessionMessage(
    DiscussionTopic topic,
    String summary,
    String reflection,
    String nextStep,
  ) {
    addRoomMessage(
      roomId: topic.roomId,
      author: 'Bridge',
      body: 'Session recap: $summary\nReflection: $reflection\nNext step: $nextStep',
      isSystem: true,
    );
  }

  void _ensureForumForTopic(DiscussionTopic topic) {
    final popularityScore = topic.sessions.length + topic.progressScore;
    if (popularityScore < 120 || findForumByTopicId(topic.id) != null) {
      return;
    }

    final list = List<DiscussionForum>.from(forums.value)
      ..insert(
        0,
        DiscussionForum(
          id: 'forum-${topic.id}',
          topicId: topic.id,
          title: '${topic.title} forum',
          createdAt: DateTime.now(),
          popularityScore: popularityScore,
          posts: [
            DiscussionForumPost(
              id: _uuid.v4(),
              author: 'Bridge',
              body: 'This topic became popular, so a forum was created for wider discussion.',
              sentAt: DateTime.now(),
            ),
          ],
        ),
      );
    forums.value = list;
  }
}

class _TopicSessionPair {
  const _TopicSessionPair({required this.topic, required this.session});

  final DiscussionTopic topic;
  final DiscussionSession session;
}