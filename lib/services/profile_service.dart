import 'package:flutter/foundation.dart';

import '../models/match_profile.dart';

class ProfileService {
  ProfileService._privateConstructor();

  static final ProfileService _instance = ProfileService._privateConstructor();

  static ProfileService get instance => _instance;

  final ValueNotifier<UserPreferences?> currentPreferences = ValueNotifier<UserPreferences?>(null);

  void save(UserPreferences preferences) {
    currentPreferences.value = preferences;
  }
}