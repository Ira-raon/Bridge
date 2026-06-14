enum AdviceTopic {careerAdvice, socialLife, personalRelationships}

enum SupportStyle { empathetic, blunt, both }

enum ExperiencePreference { sameExperience, similarSituation, noPreference }

enum UserRole {seeker, sharer, both,}

enum AgeBand { youth, youngAdult, adult, older }

enum LifeExperience {
  careerChange,
  entrepreneurship,
  parenthood,
  grief,
  immigration,
  retirement,
  higherEducation,
  financialHardship,
  relationshipBreakdown,
  healthChallenge,
}

enum LifeStage {student, earlyCareer, midCareer, retired}

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
    //required this.premium,
    required this.role,
    required this.adviceTopics,
    required this.supportStyles,
    required this.experiencePreference,
    required this.careerField,
    required this.preferSameCareerField,
    required this.additionalNotes,
    required this.lifeExperiences,
  });

  final String displayName;
  //final bool premium;
  final UserRole role;
  final Set<AdviceTopic> adviceTopics;
  final Set<SupportStyle> supportStyles;
  final ExperiencePreference experiencePreference;
  final String careerField;
  final bool preferSameCareerField;
  final Set<LifeExperience> lifeExperiences;
  final String additionalNotes;
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

  factory CommunityMember.fromProfile(
  Map<String, dynamic> json,
) {
  return CommunityMember(
    id: json['id'],
    name: json['display_name'] ?? 'Bridge Member',

    role: UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.seeker,
    ),

    ageBand: AgeBand.youngAdult,

    adviceTopics: (json['advice_topics'] as List?)
            ?.map(
              (e) => AdviceTopic.values.firstWhere(
                (topic) => topic.name == e,
              ),
            )
            .toSet() ??
        {},

    supportStyles: (json['support_styles'] as List?)
            ?.map(
              (e) => SupportStyle.values.firstWhere(
                (style) => style.name == e,
              ),
            )
            .toSet() ??
        {},

    experienceTags: {},

    careerFields: {
      if (json['career_field'] != null)
        json['career_field'].toString().toLowerCase(),
    },

    community: 'Bridge Member',

    bio: json['additional_notes'] ?? '',
  );
}
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
extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.seeker => 'Looking for guidance',
        UserRole.sharer => 'Sharing my experience',
        UserRole.both => 'Both',
      };
}
extension LifeExperienceLabel on LifeExperience {
  String get label => switch (this) {
        LifeExperience.careerChange => 'Career change',
        LifeExperience.entrepreneurship => 'Started a business',
        LifeExperience.parenthood => 'Parenthood',
        LifeExperience.grief => 'Grief and loss',
        LifeExperience.immigration => 'Immigration',
        LifeExperience.retirement => 'Retirement',
        LifeExperience.higherEducation => 'Higher education',
        LifeExperience.financialHardship => 'Financial hardship',
        LifeExperience.relationshipBreakdown => 'Relationship breakdown',
        LifeExperience.healthChallenge => 'Health challenge',
      };
}