import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectionService {
  ConnectionService._();

  static final instance = ConnectionService._();

  final _supabase = Supabase.instance.client;

 Future<void> sendRequest(String recipientId) async {
  final currentUser = _supabase.auth.currentUser;

  if (currentUser == null) {
    throw Exception('Not signed in');
  }

  final existing = await _supabase
      .from('connections')
      .select()
      .or(
        'and(requester_id.eq.${currentUser.id},recipient_id.eq.$recipientId),'
        'and(requester_id.eq.$recipientId,recipient_id.eq.${currentUser.id})',
      );

  if (existing.isNotEmpty) {
    throw Exception(
      'You already have a connection request with this user.',
    );
  }

  await _supabase.from('connections').insert({
    'requester_id': currentUser.id,
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