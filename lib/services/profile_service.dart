import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/match_profile.dart';

class ProfileService {
  ProfileService._privateConstructor();

  static final ProfileService _instance =
      ProfileService._privateConstructor();

  static ProfileService get instance => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> saveProfile(
    UserPreferences preferences,
  ) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No authenticated user');
    }

    await _supabase.from('profiles').update({
      'display_name': preferences.displayName,
      'role': preferences.role.name,
      'advice_topics':
          preferences.adviceTopics.map((e) => e.name).toList(),
      'support_styles':
          preferences.supportStyles.map((e) => e.name).toList(),
      'experience_preference':
          preferences.experiencePreference.name,
      'career_field': preferences.careerField,
      'prefer_same_career_field':
          preferences.preferSameCareerField,
      'additional_notes':
          preferences.additionalNotes,
      'onboarding_complete': true,
      'life_stage': preferences.lifeStage.name,
      'date_of_birth': preferences.dateOfBirth,
    }).eq('id', user.id);

  }
  Future<bool> profileExists() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
     return false;
    }

    final response = await _supabase
        .from('profiles')
        .select('onboarding_complete')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      return false;
    }

    return response['onboarding_complete'] == true;
  }
  Future<UserPreferences?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;
  
    if (user == null) {
      return null;
    }
  
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
  
    return UserPreferences(
      displayName: response['display_name'] ?? 'Bridge Member',
  
      role: UserRole.values.firstWhere(
        (e) => e.name == response['role'],
        orElse: () => UserRole.seeker,
      ),
  
      adviceTopics: (response['advice_topics'] as List?)
              ?.map(
                (e) => AdviceTopic.values.firstWhere(
                  (topic) => topic.name == e,
                ),
              )
              .toSet() ??
          {},
  
      supportStyles: (response['support_styles'] as List?)
              ?.map(
                (e) => SupportStyle.values.firstWhere(
                  (style) => style.name == e,
                ),
              )
              .toSet() ??
          {},
  
      experiencePreference:
          ExperiencePreference.values.firstWhere(
        (e) => e.name == response['experience_preference'],
        orElse: () =>
            ExperiencePreference.sameExperience,
      ),
  
      careerField: response['career_field'] ?? '',
  
      preferSameCareerField:
          response['prefer_same_career_field'] ?? false,
  
      additionalNotes:
          response['additional_notes'] ?? '',
  
      lifeExperiences: const {},
      lifeStage: LifeStage.values.firstWhere(
        (e) => e.name == response['life_stage'],
        orElse: () => LifeStage.preferNotToSay,
      ),
      dateOfBirth: response['date_of_birth'] != null
          ? DateTime.parse(response['date_of_birth'])
          : null,
    );
  }
}