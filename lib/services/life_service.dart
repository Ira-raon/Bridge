import 'package:flutter/foundation.dart';
import '../models/story.dart';

class LifeService {
  LifeService._privateConstructor();

  static final LifeService _instance = LifeService._privateConstructor();

  static LifeService get instance => _instance;

  final ValueNotifier<List<Story>> stories = ValueNotifier<List<Story>>([]);
  final ValueNotifier<Set<String>> savedIds = ValueNotifier<Set<String>>({});

  List<Story> getAll() => List.unmodifiable(stories.value);

  void add(Story story) {
    final list = List<Story>.from(stories.value);
    list.insert(0, story);
    stories.value = list;
  }

  void removeById(String id) {
    final list = stories.value.where((s) => s.id != id).toList();
    stories.value = list;
    // also remove from savedIds if present
    final saved = Set<String>.from(savedIds.value);
    if (saved.remove(id)) savedIds.value = saved;
  }

  Story? findById(String id) {
    try {
      return stories.value.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Story> getSavedStories() {
    final ids = savedIds.value;
    return stories.value.where((s) => ids.contains(s.id)).toList();
  }

  bool isSaved(String id) => savedIds.value.contains(id);

  void save(String id) {
    final s = Set<String>.from(savedIds.value);
    if (s.add(id)) savedIds.value = s;
  }

  void unsave(String id) {
    final s = Set<String>.from(savedIds.value);
    if (s.remove(id)) savedIds.value = s;
  }

  void toggleSaved(String id) {
    if (isSaved(id)) {
      unsave(id);
    } else {
      save(id);
    }
  }
}
