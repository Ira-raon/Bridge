import 'package:flutter/material.dart';

import '../models/match_profile.dart';
import '../services/profile_service.dart';
import 'platform_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({
    super.key,
    this.isEditing = false,
  });

  final bool isEditing;

  @override
  State<ProfileSetupScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileSetupScreen> {
  bool _loadingProfile = true;
  final _nameController = TextEditingController();
  final _shareController = TextEditingController();
  final _careerFieldController = TextEditingController();
  final Set<AdviceTopic> _selectedTopics = {AdviceTopic.careerAdvice};
  final Set<SupportStyle> _selectedStyles = {SupportStyle.empathetic};
  LifeStage _lifeStage = LifeStage.preferNotToSay;
  DateTime? _selectedDob;
  ExperiencePreference _experiencePreference = ExperiencePreference.sameExperience;
  UserRole _selectedRole = UserRole.seeker;
  // bool _premiumAccess = false;
  bool _preferSameCareerField = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile =
        await ProfileService.instance.getCurrentProfile();

    if (profile == null) {
      if (mounted) {
        setState(() {
          _loadingProfile = false;
        });
      }

      return;
    }

    _nameController.text = profile.displayName;
    _careerFieldController.text = profile.careerField;
    _shareController.text = profile.additionalNotes;
    _selectedRole = profile.role;
    _selectedTopics
      ..clear()
      ..addAll(profile.adviceTopics.isEmpty
          ? {AdviceTopic.careerAdvice}
          : profile.adviceTopics);
    _selectedStyles
      ..clear()
      ..addAll(profile.supportStyles.isEmpty
          ? {SupportStyle.empathetic}
          : profile.supportStyles);
    _experiencePreference = profile.experiencePreference;
    _preferSameCareerField = profile.preferSameCareerField;
    _selectedDob = profile.dateOfBirth;
    _lifeStage = profile.lifeStage;

    if (mounted) {
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shareController.dispose();
    _careerFieldController.dispose();
    super.dispose();
  }

  Future<void> _openPlatform(BuildContext context) async {
  final preferences = UserPreferences(
    displayName: _nameController.text.trim().isEmpty
        ? 'New Bridge member'
        : _nameController.text.trim(),
    // premium: _premiumAccess,
    role: _selectedRole,
    adviceTopics: _selectedTopics.isEmpty
        ? {AdviceTopic.careerAdvice}
        : _selectedTopics,
    supportStyles: _selectedStyles.isEmpty
        ? {SupportStyle.both}
        : _selectedStyles,
    experiencePreference: _experiencePreference,
    careerField: _careerFieldController.text.trim(),
    preferSameCareerField: _preferSameCareerField,
    additionalNotes: _shareController.text.trim(),
    lifeExperiences: const {},
    lifeStage: _lifeStage,
    dateOfBirth: _selectedDob,
  );

  try {
    await ProfileService.instance.saveProfile(
      preferences,
    );

    if (!context.mounted) return;

    if (widget.isEditing) {
    Navigator.of(context).pop();
  } else {
    Navigator.of(context).pushReplacement(
     MaterialPageRoute<void>(
        builder: (_) => const PlatformScreen(),
      ),
    );
}
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Failed to save profile: $e',
         ),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile setup'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _SectionHeader(
            title: 'Tell the platform what you want',
            subtitle: 'First-time setup helps Bridge connect you with the right people.',
          ),
          const SizedBox(height: 20),
          if (widget.isEditing)
            _ProfileSummaryCard(dateOfBirth: _selectedDob)
          else
            _ProfileCard(nameController: _nameController),
          const SizedBox(height: 18),
          if (!widget.isEditing) ...[
            const _PreferenceLabel(
              title: 'What best describes you?',
              subtitle: 'This helps Bridge know how you want to participate.',
            ),
            const SizedBox(height: 12),
            SegmentedButton<UserRole>(
              segments: UserRole.values
                  .map(
                    (role) => ButtonSegment<UserRole>(
                      value: role,
                      label: Text(role.label),
                    ),
                  )
                  .toList(),
              selected: {_selectedRole},
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedRole = selection.first;
                });
              },
            ),
            const SizedBox(height: 18),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date of birth'),
              subtitle: Text(
                _selectedDob == null
                    ? 'Select date of birth'
                    : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDob ?? DateTime(2000),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );

                if (picked != null) {
                  setState(() {
                    _selectedDob = picked;
                  });
                }
              },
            ),
          ] else ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date of birth'),
              subtitle: Text(
                _selectedDob == null
                    ? 'Not set'
                    : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
              ),
              trailing: const Icon(Icons.lock_outline),
            ),
          ],
          const SizedBox(height: 18),
          DropdownButtonFormField<LifeStage>(
            value: _lifeStage,
            decoration: const InputDecoration(
              labelText: 'Life stage',
            ),
            items: LifeStage.values
                .map(
                  (stage) => DropdownMenuItem(
                    value: stage,
                    child: Text(stage.label),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _lifeStage = value;
                });
              }
            },
          ),
          const SizedBox(height: 18),
          const _PreferenceLabel(
            title: 'What are you looking for?',
            subtitle: 'Choose the advice areas that matter most right now.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AdviceTopic.values.map((topic) {
              final selected = _selectedTopics.contains(topic);
              return ChoiceChip(
                label: Text(topic.label),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedTopics.add(topic);
                    } else {
                      _selectedTopics.remove(topic);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const _PreferenceLabel(
            title: 'Who would you like to speak with?',
            subtitle: 'Match by tone and the kind of conversation you want.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: SupportStyle.values.map((style) {
              final selected = _selectedStyles.contains(style);
              return ChoiceChip(
                label: Text(style.label),
                selected: selected,
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _selectedStyles.add(style);
                    } else {
                      _selectedStyles.remove(style);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          const _PreferenceLabel(
            title: 'Experience match',
            subtitle: 'Tell Bridge whether you want the same experience or a similar situation.',
          ),
          const SizedBox(height: 12),
          SegmentedButton<ExperiencePreference>(
            segments: ExperiencePreference.values
                .map(
                  (pref) => ButtonSegment<ExperiencePreference>(
                    value: pref,
                    label: Text(pref.label),
                  ),
                )
                .toList(),
            selected: {_experiencePreference},
            onSelectionChanged: (selection) {
              setState(() {
                _experiencePreference = selection.first;
              });
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _careerFieldController,
            decoration: const InputDecoration(
              labelText: 'Current career field or industry',
              prefixIcon: Icon(Icons.work_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _preferSameCareerField,
            title: const Text('Prefer the same career field'),
            subtitle: const Text('When asking for career advice, boost people in the same line of work.'),
            onChanged: (value) {
              setState(() {
                _preferSameCareerField = value;
              });
            },
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _shareController,
            decoration: const InputDecoration(
              labelText: 'Anything else the matcher should know?',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: () => _openPlatform(context),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
                widget.isEditing
                  ? 'Save Profile'
                  : 'Continue to Exchange Platform',
          ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.nameController});

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.person, color: scheme.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'A few choices here will shape your first matches and who you see first.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
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

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.dateOfBirth});

  final DateTime? dateOfBirth;

  @override
  Widget build(BuildContext context) {
    final dobText = dateOfBirth == null
        ? 'Not set'
        : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Date of birth: $dobText',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceLabel extends StatelessWidget {
  const _PreferenceLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
