import 'package:flutter/material.dart';

import 'profile_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FBFC), Color(0xFFE7F2F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical -
                    48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.forum_rounded, color: Colors.white),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Bridge',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF12342F),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A space where people exchange information, experience, and wisdom.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF56706A),
                        ),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment<bool>(
                                value: true,
                                label: Text('Sign in'),
                              ),
                              ButtonSegment<bool>(
                                value: false,
                                label: Text('Sign up'),
                              ),
                            ],
                            selected: {isSignIn},
                            onSelectionChanged: (selection) {
                              setState(() {
                                isSignIn = selection.first;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          if (!isSignIn) ...[
                            const SizedBox(height: 14),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Display name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _continue,
                              child: Text(
                                isSignIn ? 'Sign in' : 'Create account',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: _continue,
                            child: const Text('Continue to profile setup'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FeatureChipRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChipRow extends StatelessWidget {
  const _FeatureChipRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _FeatureChip(icon: Icons.school_rounded, label: 'Knowledge'),
        _FeatureChip(icon: Icons.groups_rounded, label: 'Experience'),
        _FeatureChip(icon: Icons.lightbulb_rounded, label: 'Wisdom'),
      ],
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(label),
      side: const BorderSide(color: Color(0xFFD8E3E6)),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    );
  }
}
