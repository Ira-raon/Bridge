import 'package:supabase_flutter/supabase_flutter.dart';

class DiscussionServiceV2 {
  DiscussionServiceV2._();

  static final instance = DiscussionServiceV2._();

  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRooms() async {
    final response = await _supabase
        .from('discussion_rooms')
        .select()
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createRoom({
    required String topicTitle,
    required String participantId,
    required String participantName,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not signed in');
    }

    final response = await _supabase
    .from('discussion_rooms')
    .insert({
      'topic_title': topicTitle,
      'created_by': user.id,
      'participant_id': participantId,
      'participant_name': participantName,
    })
    .select()
    .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getMessages(
    String roomId,
  ) async {
    final response = await _supabase
        .from('discussion_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> sendMessage({
  required String roomId,
  required String body,
}) async {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    throw Exception('User not signed in');
  }

  final profile = await _supabase
      .from('profiles')
      .select('display_name')
      .eq('id', user.id)
      .single();

  await _supabase.from('discussion_messages').insert({
    'room_id': roomId,
    'sender_id': user.id,
    'sender_name':
        profile['display_name'] ?? 'Bridge Member',
    'body': body,
  });
}
}