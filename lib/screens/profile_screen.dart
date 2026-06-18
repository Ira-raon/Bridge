import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/match_profile.dart';
import '../services/auth_service.dart';
import 'auth_screen.dart';
import 'profile_setup_screen.dart';
import '../widgets/app_navigation_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'No signed-in user was found.';
      });

      return;
    }

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        _profile = data;
        _loading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = 'Could not load your profile right now.';
      });
    }
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
        actions: [
          IconButton(
            tooltip: 'Edit preferences',
            onPressed: _openProfileSetup,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ProfileHero(profile: _profile),
          const SizedBox(height: 18),
          _DetailCard(
            title: 'About you',
            children: [
              _DetailChip(label: 'Date of birth', value: _dateOfBirthValue()),
              _DetailChip(label: 'Life stage', value: _lifeStageValue()),
            ],
          ),
          const SizedBox(height: 12),
          if (_errorMessage != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_errorMessage!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
          _SectionHeader(
            title: 'Profile snapshot',
            subtitle: 'A quick view of the settings shaping your matches.',
          ),
          const SizedBox(height: 12),
          _DetailCard(
            title: 'Core identity',
            children: [
              _DetailChip(label: 'Role', value: _stringValue('role')),
              _DetailChip(label: 'Career field', value: _stringValue('career_field')),
              _DetailChip(label: 'Experience preference', value: _stringValue('experience_preference')),
              _DetailChip(
                label: 'Prefer same career field',
                value: _boolValue('prefer_same_career_field'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailCard(
            title: 'Advice topics',
            children: _chipsForList('advice_topics'),
          ),
          const SizedBox(height: 12),
          _DetailCard(
            title: 'Support style',
            children: _chipsForList('support_styles'),
          ),
          const SizedBox(height: 12),
          _DetailCard(
            title: 'Life experiences',
            children: _chipsForList('life_experiences'),
          ),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Actions',
            subtitle: 'Update your profile or sign out of the app.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
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
                label: const Text('Sign out'),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 2),
    );
  }

  Future<void> _openProfileSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(isEditing: true),
      ),
    );

    if (!mounted) return;

    await _loadProfile();
  }

  String _stringValue(String key) {
    final value = _profile?[key];

    if (value == null) {
      return 'Not set';
    }

    return value.toString();
  }

  String _boolValue(String key) {
    final value = _profile?[key];

    if (value is bool) {
      return value ? 'Yes' : 'No';
    }

    return 'Not set';
  }

  String _dateOfBirthValue() {
    final value = _profile?['date_of_birth'];

    if (value == null) {
      return 'Not set';
    }

    final dob = value is DateTime ? value : DateTime.tryParse(value.toString());

    if (dob == null) {
      return 'Not set';
    }

    return '${dob.day}/${dob.month}/${dob.year}';
  }

  String _lifeStageValue() {
    final value = _profile?['life_stage'];

    if (value == null) {
      return 'Not set';
    }

    return LifeStage.values
        .firstWhere(
          (stage) => stage.name == value.toString(),
          orElse: () => LifeStage.preferNotToSay,
        )
        .label;
  }

  List<Widget> _chipsForList(String key) {
    final value = _profile?[key];

    final items = value is List
        ? value.map((entry) => entry.toString()).toList()
        : const <String>[];

    if (items.isEmpty) {
      return [const _DetailChip(label: 'Status', value: 'Not set')];
    }

    return items
        .map(
          (item) => Chip(
            label: Text(item),
            visualDensity: VisualDensity.compact,
          ),
        )
        .toList();
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final Map<String, dynamic>? profile;

  @override
  Widget build(BuildContext context) {
    final displayName = (profile?['display_name'] ?? 'Bridge member').toString();
    final email = (profile?['email'] ?? Supabase.instance.client.auth.currentUser?.email ?? '').toString();
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123D38), Color(0xFF1F766E)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              child: Text(
                initial,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email.isEmpty ? 'Your Bridge profile' : email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF61777A),
              ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        radius: 10,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          label.isNotEmpty ? label[0].toUpperCase() : '?',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      label: Text('$label: $value'),
    );
  }
}