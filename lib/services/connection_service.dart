import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionService {
  ConnectionService._();

  static final instance = ConnectionService._();

  final _supabase = Supabase.instance.client;

  Future<void> sendRequest(String recipientId) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Not signed in');
    }

    await _supabase.from('connections').insert({
      'requester_id': user.id,
      'recipient_id': recipientId,
      'status': 'pending',
    });
  }

Future<List<Map<String, dynamic>>> getPendingRequests() async {
  final user = _supabase.auth.currentUser;

  if (user == null) {
    return [];
  }

  final response = await _supabase
      .from('connections')
      .select('''
        *,
        requester:profiles!connections_requester_id_fkey(
          display_name
        )
      ''')
      .eq('recipient_id', user.id)
      .eq('status', 'pending');

  return List<Map<String, dynamic>>.from(response);
}
Future<void> acceptRequest(String connectionId) async {
  await _supabase
      .from('connections')
      .update({
        'status': 'accepted',
      })
      .eq('id', connectionId);
}
Future<void> declineRequest(String connectionId) async {
  await _supabase
      .from('connections')
      .update({
        'status': 'declined',
      })
      .eq('id', connectionId);
}
}