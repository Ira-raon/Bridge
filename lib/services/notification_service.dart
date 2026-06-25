import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({
          'is_read': true,
        })
        .eq('id', id);
  }
}