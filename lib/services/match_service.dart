import '../models/match_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchService {
  MatchService._privateConstructor();
  final _supabase = Supabase.instance.client;

  static final MatchService _instance = MatchService._privateConstructor();

  static MatchService get instance => _instance;

  Future<List<Map<String, dynamic>>> getProfiles() async {
  final currentUser = _supabase.auth.currentUser;

  if (currentUser == null) {
    return [];
  }

  final response = await _supabase
      .from('profiles')
      .select()
      .neq('id', currentUser.id);

  return List<Map<String, dynamic>>.from(response);
}
  Future<List<CommunityMember>> getCommunityMembers() async {
  final currentUser = _supabase.auth.currentUser;

  if (currentUser == null) {
    return [];
  }

  final response = await _supabase
      .from('profiles')
      .select()
      .eq('onboarding_complete', true)
      .neq('id', currentUser.id);

  return response
      .map<CommunityMember>(
        (profile) => CommunityMember.fromProfile(profile),
      )
      .toList();
}

  Future<List<MatchResult>> recommend(UserPreferences preferences, {int limit = 4}) async {
    final members = await instance.getCommunityMembers();
    final results = members
        .map((member) => _score(preferences, member))
        .where((result) => result.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return results.take(limit).toList();
  }

  MatchResult _score(UserPreferences preferences, CommunityMember member) {
    var score = 0;
    final reasons = <String>[];

    final topicOverlap = preferences.adviceTopics.intersection(member.adviceTopics);
    if (topicOverlap.isNotEmpty) {
      score += 24 + (topicOverlap.length - 1) * 6;
      reasons.add('Matches ${topicOverlap.first.label.toLowerCase()} focus');
    }

    final styleOverlap = preferences.supportStyles.intersection(member.supportStyles);
    if (styleOverlap.isNotEmpty) {
      score += 18 + (styleOverlap.length - 1) * 4;
      reasons.add('Preferred tone: ${styleOverlap.first.label.toLowerCase()}');
    }

    final myRole = preferences.role;
final theirRole = member.role;

bool compatible = false;

if (myRole == UserRole.both ||
    theirRole == UserRole.both) {
  compatible = true;
} else if (myRole == UserRole.seeker &&
           theirRole == UserRole.sharer) {
  compatible = true;
} else if (myRole == UserRole.sharer &&
           theirRole == UserRole.seeker) {
  compatible = true;
}

if (compatible) {
  score += 30;
  reasons.add('Compatible roles');
} else {
  score = 0;
}

    if (preferences.experiencePreference == ExperiencePreference.sameExperience) {
      final sharedExperience = member.experienceTags.any(
        (tag) => _sharedExperienceHints.any((hint) => tag.contains(hint)),
      );
      if (sharedExperience) {
        score += 18;
        reasons.add('Shared experience');
      }
    } else if (preferences.experiencePreference == ExperiencePreference.similarSituation) {
      score += 8;
      reasons.add('Similar situation');
    }

    final wantsCareerMatch = preferences.adviceTopics.contains(AdviceTopic.careerAdvice) && preferences.preferSameCareerField;
    final careerField = preferences.careerField.trim().toLowerCase();
    if (wantsCareerMatch && careerField.isNotEmpty) {
      final fieldMatch = member.careerFields.any((field) => field.toLowerCase() == careerField);
      if (fieldMatch) {
        score += 20;
        reasons.add('Same career field');
      }
    }

    //if (preferences.premium && member.role == UserRole.seeker && member.ageBand != AgeBand.older) {
    //   score += 8;
    //   reasons.add('Premium expands peer options');
    // }

    if (score < 0) {
      score = 0;
    }

    return MatchResult(member: member, score: score, reasons: reasons);
  }

  static const List<String> _sharedExperienceHints = [
    'retirement',
    'caregiving',
    'first job',
    'relationships',
    'new city',
    'career change',
    'family dynamics',
    'social anxiety',
  ];
}