import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('User creation failed');
    }

    try {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'email': email,
        'display_name': displayName,
      });
    
      print('PROFILE CREATED');
    } catch (e) {
      print('PROFILE ERROR: $e');
      rethrow;
    }
      }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser {
    return _supabase.auth.currentUser;
  }
}