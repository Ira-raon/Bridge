import 'package:flutter/foundation.dart';
import '../models/story.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class LifeService {
  LifeService._();

  static final instance = LifeService._();

  final _supabase = Supabase.instance.client;
  String? get currentUserId =>
    _supabase.auth.currentUser?.id;



  Future<void> addStory({
    required String title,
    required String content,
  }) async {

    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Not signed in');
    }

    final profile = await _supabase
      .from('profiles')
      .select('display_name')
      .eq('id', user.id)
      .single();

    await _supabase
      .from('life_library')
      .insert({

        'user_id': user.id,

        'author_name': profile['display_name'],

        'title': title,

        'content': content,

      });
  // Refresh the stories list after adding a new story
  }


  Future<List<Map<String, dynamic>>> getStories() async {
    final data = await _supabase
        .from('life_library')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
  Future<void> deleteStory(String id) async {

    await _supabase
        .from('life_library')
        .delete()
        .eq('id', id);

  }
  Future<void> toggleHelped(String storyId) async {

    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final existing = await _supabase
        .from('life_library_helped')
        .select()
        .eq('story_id', storyId)
        .eq('user_id', user.id);

    if (existing.isEmpty) {

      await _supabase
          .from('life_library_helped')
          .insert({

        'story_id': storyId,

        'user_id': user.id,

      });

    } else {

      await _supabase
          .from('life_library_helped')
          .delete()
          .eq('story_id', storyId)
          .eq('user_id', user.id);

    }
  }
  Future<void> saveStory(String storyId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    await _supabase
        .from('life_library_saved')
        .insert({
          'story_id': storyId,
          'user_id': user.id,
        });
  }
  Future<void> unsaveStory(String storyId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    await _supabase
        .from('life_library_saved')
        .delete()
        .eq('story_id', storyId)
        .eq('user_id', user.id);
  }
  Future<bool> isSaved(String storyId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) return false;

    final data = await _supabase
        .from('life_library_saved')
        .select()
        .eq('story_id', storyId)
        .eq('user_id', user.id);

    return data.isNotEmpty;
  }
  Future<void> toggleSaved(String storyId) async {
    if (await isSaved(storyId)) {
      await unsaveStory(storyId);
    } else {
      await saveStory(storyId);
    }
  }
  Future<List<Map<String,dynamic>>> getReflections(
      String storyId) async {

    final data = await _supabase
        .from('life_library_reflections')
        .select()
        .eq('story_id', storyId)
        .order(
          'created_at',
          ascending: false,
        );

    return List<Map<String,dynamic>>
        .from(data);
  }
  Future<void> addReflection({
    required String storyId,
    required String reflection,
  }) async {

    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final profile = await _supabase
        .from('profiles')
        .select('display_name')
        .eq('id', user.id)
        .single();

    await _supabase
        .from('life_library_reflections')
        .insert({

          'story_id': storyId,

          'user_id': user.id,

          'author_name':
              profile['display_name'],

          'reflection': reflection,

        });
  }
  Future<int> getHelpedCount(String storyId) async {

    final data = await _supabase
        .from('life_library_helped')
        .select()
        .eq('story_id', storyId);

    return data.length;
  }
  Future<bool> hasHelped(String storyId) async {

    final user = _supabase.auth.currentUser;

    if (user == null) return false;

    final data = await _supabase
        .from('life_library_helped')
        .select()
        .eq('story_id', storyId)
        .eq('user_id', user.id);

    return data.isNotEmpty;
  }
  Future<List<Map<String, dynamic>>> getSavedStories() async {

    final user = _supabase.auth.currentUser;
  
    if (user == null) return [];
  
    final data = await _supabase
        .from('life_library_saved')
        .select('''
          story_id,
          life_library(*)
        ''')
        .eq('user_id', user.id);
  
    return List<Map<String, dynamic>>.from(data);
  }
}
