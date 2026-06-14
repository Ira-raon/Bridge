import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'profile_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
                padding: const EdgeInsets.all(24),
                  child: Column(
                     children: [
                      CircleAvatar(
                         radius: 36,
                          child: Text(
                           (_profile?['display_name'] ?? 'B')
                               .substring(0, 1)
                               .toUpperCase(),
                             ),
                      ),
               const SizedBox(height: 12),
                Text(
                  _profile?['display_name'] ?? 'Bridge Member',
                    style: Theme.of(context)
                      .textTheme
                      .headlineSmall,
                ),
                Text(
                  _profile?['email'] ?? '',
                ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Preferences',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Chip(
          label: 
            Text('Role: ${
              _profile?['role'] ?? 'Not set'
              }'
            ),
          ),
           Chip(
            label: Text('Career Field: ${_profile?['career_field'] ?? 'Not set'}'),
          ),
            

          Chip(label: Text('Experience Preference: ${_profile?['experience_preference'] ?? 'Not set'}'),),
          Chip(label: Text('Prefer Same Career Field: ${_profile?['prefer_same_career_field'] ?? 'Not set'}'),),
          Chip(label: Text('Advice Topics: ${(_profile?['advice_topics'] as List<dynamic>?)?.join(', ') ?? 'Not set'}'),),
          Chip(label: Text('Support Styles: ${(_profile?['support_styles'] as List<dynamic>?)?.join(', ') ?? 'Not set'}'),),
          Chip(label: Text('Life Experiences: ${(_profile?['life_experiences'] as List<dynamic>?)?.join(', ') ?? 'Not set'}'),),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileSetupScreen(isEditing: true,),
                ),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Preferences'),
          ),

          const SizedBox(height: 12),

          FilledButton.tonalIcon(
            onPressed: () async {
              await AuthService().signOut();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const AuthScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}