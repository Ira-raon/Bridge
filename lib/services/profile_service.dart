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
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    return await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
  }
}