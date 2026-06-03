import '../models/match_profile.dart';

class MatchService {
  MatchService._privateConstructor();

  static final MatchService _instance = MatchService._privateConstructor();

  static MatchService get instance => _instance;

  List<CommunityMember> get communityMembers => List.unmodifiable(_community);

  final List<CommunityMember> _community = const [
    CommunityMember(
      id: 'ruth-retired-nurse',
      name: 'Ruth',
      role: UserRole.sharer,
      ageBand: AgeBand.older,
      adviceTopics: {AdviceTopic.personalRelationships, AdviceTopic.socialLife},
      supportStyles: {SupportStyle.empathetic, SupportStyle.both},
      experienceTags: {'retirement transition', 'caregiving', 'community support'},
      careerFields: {'healthcare', 'nursing', 'care'},
      community: 'Retired nurse',
      bio: 'Gentle, steady guidance from someone who has supported people through change for decades.',
    ),
    CommunityMember(
      id: 'malik-care-community',
      name: 'Malik',
      role: UserRole.sharer,
      ageBand: AgeBand.older,
      adviceTopics: {AdviceTopic.personalRelationships, AdviceTopic.careerAdvice},
      supportStyles: {SupportStyle.blunt, SupportStyle.both},
      experienceTags: {'care community', 'family dynamics', 'work-life balance'},
      careerFields: {'community work', 'care', 'social services'},
      community: 'Care community mentor',
      bio: 'Direct advice from a long-time community organiser who has seen a lot and says what matters.',
    ),
    CommunityMember(
      id: 'sandra-retiree',
      name: 'Sandra',
      role: UserRole.sharer,
      ageBand: AgeBand.older,
      adviceTopics: {AdviceTopic.socialLife, AdviceTopic.careerAdvice},
      supportStyles: {SupportStyle.empathetic},
      experienceTags: {'retired', 'career change', 'new chapters'},
      careerFields: {'education', 'teaching', 'mentorship'},
      community: 'Retired teacher',
      bio: 'A calm listener with a lot of life experience and practical wisdom about big transitions.',
    ),
    CommunityMember(
      id: 'jay-young-peer',
      name: 'Jay',
      role: UserRole.seeker,
      ageBand: AgeBand.youngAdult,
      adviceTopics: {AdviceTopic.careerAdvice, AdviceTopic.socialLife},
      supportStyles: {SupportStyle.both},
      experienceTags: {'first job', 'moving cities', 'building confidence'},
      careerFields: {'tech', 'product', 'startup'},
      community: 'Peer seeker',
      bio: 'A younger user looking for advice, but also able to swap notes on the same stage of life.',
    ),
    CommunityMember(
      id: 'nina-young-peer',
      name: 'Nina',
      role: UserRole.seeker,
      ageBand: AgeBand.youngAdult,
      adviceTopics: {AdviceTopic.personalRelationships, AdviceTopic.socialLife},
      supportStyles: {SupportStyle.empathetic, SupportStyle.both},
      experienceTags: {'relationships', 'social anxiety', 'new city'},
      careerFields: {'healthcare', 'community work'},
      community: 'Peer seeker',
      bio: 'Wants conversation with people who understand the same life stage and can trade advice both ways.',
    ),
  ];

  List<MatchResult> recommend(UserPreferences preferences, {int limit = 4}) {
    final results = _community
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

    if (member.role == UserRole.sharer) {
      score += 30;
      reasons.add('Older sharer');
      if (member.ageBand == AgeBand.older) {
        score += 18;
      }
    } else if (preferences.premium) {
      score += 10;
      reasons.add('Premium peer match');
      if (member.ageBand == AgeBand.youngAdult) {
        score += 6;
      }
    } else {
      score -= 100;
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

    if (preferences.premium && member.role == UserRole.seeker && member.ageBand != AgeBand.older) {
      score += 8;
      reasons.add('Premium expands peer options');
    }

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