enum AdviceTopic { socialLife, careerAdvice, personalRelationships }

enum SupportStyle { empathetic, blunt, both }

enum ExperiencePreference { sameExperience, similarSituation, noPreference }

enum UserRole { seeker, sharer }

enum AgeBand { youth, youngAdult, adult, older }

extension AdviceTopicLabel on AdviceTopic {
  String get label => switch (this) {
        AdviceTopic.socialLife => 'Social life',
        AdviceTopic.careerAdvice => 'Career advice',
        AdviceTopic.personalRelationships => 'Personal relationships',
      };
}

extension SupportStyleLabel on SupportStyle {
  String get label => switch (this) {
        SupportStyle.empathetic => 'Empathetic',
        SupportStyle.blunt => 'Blunt',
        SupportStyle.both => 'Both',
      };
}

extension ExperiencePreferenceLabel on ExperiencePreference {
  String get label => switch (this) {
        ExperiencePreference.sameExperience => 'Same experience',
        ExperiencePreference.similarSituation => 'Similar situation',
        ExperiencePreference.noPreference => 'No preference',
      };
}

extension AgeBandLabel on AgeBand {
  String get label => switch (this) {
        AgeBand.youth => 'Youth',
        AgeBand.youngAdult => 'Young adult',
        AgeBand.adult => 'Adult',
        AgeBand.older => 'Older generation',
      };
}

class UserPreferences {
  const UserPreferences({
    required this.displayName,
    required this.premium,
    required this.role,
    required this.adviceTopics,
    required this.supportStyles,
    required this.experiencePreference,
    required this.careerField,
    required this.preferSameCareerField,
  });

  final String displayName;
  final bool premium;
  final UserRole role;
  final Set<AdviceTopic> adviceTopics;
  final Set<SupportStyle> supportStyles;
  final ExperiencePreference experiencePreference;
  final String careerField;
  final bool preferSameCareerField;
}

class CommunityMember {
  const CommunityMember({
    required this.id,
    required this.name,
    required this.role,
    required this.ageBand,
    required this.adviceTopics,
    required this.supportStyles,
    required this.experienceTags,
    required this.careerFields,
    required this.community,
    required this.bio,
  });

  final String id;
  final String name;
  final UserRole role;
  final AgeBand ageBand;
  final Set<AdviceTopic> adviceTopics;
  final Set<SupportStyle> supportStyles;
  final Set<String> experienceTags;
  final Set<String> careerFields;
  final String community;
  final String bio;
}

class MatchResult {
  const MatchResult({
    required this.member,
    required this.score,
    required this.reasons,
  });

  final CommunityMember member;
  final int score;
  final List<String> reasons;
}