import 'match_profile.dart';

enum DiscussionCadence { daily, weekly, monthly }

extension DiscussionCadenceLabel on DiscussionCadence {
  String get label => switch (this) {
        DiscussionCadence.daily => 'Daily',
        DiscussionCadence.weekly => 'Weekly',
        DiscussionCadence.monthly => 'Monthly',
      };
}

class DiscussionSession {
  const DiscussionSession({
    required this.id,
    required this.happenedAt,
    required this.summary,
    required this.reflection,
    required this.nextStep,
    required this.progressDelta,
  });

  final String id;
  final DateTime happenedAt;
  final String summary;
  final String reflection;
  final String nextStep;
  final int progressDelta;
}

class DiscussionTopic {
  const DiscussionTopic({
    required this.id,
    required this.matchId,
    required this.matchName,
    required this.roomId,
    required this.category,
    required this.title,
    required this.cadence,
    required this.goal,
    required this.createdAt,
    required this.progressScore,
    required this.sessions,
  });

  final String id;
  final String matchId;
  final String matchName;
  final String roomId;
  final AdviceTopic category;
  final String title;
  final DiscussionCadence cadence;
  final String goal;
  final DateTime createdAt;
  final int progressScore;
  final List<DiscussionSession> sessions;

  DiscussionTopic copyWith({
    List<DiscussionSession>? sessions,
    int? progressScore,
  }) {
    return DiscussionTopic(
      id: id,
      matchId: matchId,
      matchName: matchName,
      roomId: roomId,
      category: category,
      title: title,
      cadence: cadence,
      goal: goal,
      createdAt: createdAt,
      progressScore: progressScore ?? this.progressScore,
      sessions: sessions ?? this.sessions,
    );
  }
}