import 'package:flutter/material.dart';
import '../models/match_profile.dart';
import '../services/match_service.dart';
import 'life_library_screen.dart';
import '../widgets/app_navigation_bar.dart';
import '../services/profile_service.dart';
import '../services/connection_service.dart';
import 'notifications_screen.dart';
import 'discussion_tracker_screen.dart';
import '../services/discussion_service_v2.dart';

class PlatformScreen extends StatefulWidget {
  const PlatformScreen({super.key});

  @override
  State<PlatformScreen> createState() => _PlatformScreenState();
}

class _PlatformScreenState extends State<PlatformScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exchange platform'),
        actions: [
          IconButton(
            tooltip: 'Life library',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LifeLibraryScreen())),
            icon: const Icon(Icons.menu_book_rounded),
          ),
           Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                      builder: (_) => NotificationsScreen(),
                      ),
                    );
                     if (mounted) {
                        setState(() {});
                      }
                   },
                      icon: FutureBuilder<List<Map<String, dynamic>>>(
                        future: ConnectionService.instance
                            .getPendingRequests(),
                        builder: (context, snapshot) {
                        
                          final count =
                              snapshot.data?.length ?? 0;

                          return Stack(
                            children: [
                            
                              const Icon(
                                Icons.notifications,
                              ),

                              if (count > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 8,
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      )
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 0),
      body: ListView(
  padding: const EdgeInsets.all(24),
  children: [
    _PlatformHero(selectedIndex: selectedIndex),

    const SizedBox(height: 18),

    const _RecommendedMatchesSection(),

    const SizedBox(height: 18),

    const _ActiveDiscussionsPreview(),

    const SizedBox(height: 18),

    const _SavedMomentsPreview(),

    const SizedBox(height: 18),

    const _QuickActionsSection(),
  ],
),
    );
  }
}

class _RecommendedMatchesSection extends StatelessWidget {
  const _RecommendedMatchesSection();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserPreferences?>(
      future: ProfileService.instance.getCurrentProfile(),
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final preferences = profileSnapshot.data;

        if (preferences == null) {
          return const _EmptyMatchesCard();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: 'Recommended matches',
              subtitle:
                  'Ranked by shared topic, tone, and experience.',
            ),
            const SizedBox(height: 14),

            FutureBuilder<List<MatchResult>>(
              future: MatchService.instance.recommend(
                preferences,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const _EmptyMatchesCard();
                }

                final matches = snapshot.data ?? [];

                if (matches.isEmpty) {
                  return const _EmptyMatchesCard();
                }

                return Column(
                  children: matches.map(
                    (match) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: _MatchCard(
                          match: match,
                          onPlanTopic: () async {
                            final controller = TextEditingController();
                        
                            final topicTitle = await showDialog<String>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: Text(
                                    'Plan a discussion with ${match.member.name}',
                                  ),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: 'Topic title',
                                      hintText: 'e.g. Career advice',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                          controller.text.trim(),
                                        );
                                      },
                                      child: const Text('Create'),
                                    ),
                                  ],
                                );
                              },
                            );
                        
                            if (topicTitle == null || topicTitle.isEmpty) {
                              return;
                            }
                        
                            try {
                              await DiscussionServiceV2.instance.createRoom(
                                topicTitle: topicTitle,
                                participantId: match.member.id,
                                participantName: match.member.name,
                              );
                        
                              if (!context.mounted) return;
                        
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Discussion created with ${match.member.name}',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                        
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString(),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ).toList(),
                  
                );
              },
            ),
          ],
        );
      },
    );
  }
}
class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match, required this.onPlanTopic});

  final MatchResult match;
  final VoidCallback onPlanTopic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Text(match.member.name.isNotEmpty ? match.member.name[0].toUpperCase() : '?'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.member.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        '${match.member.community} • ${match.member.ageBand.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF61777A),
                            ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${match.score}'),
                  backgroundColor: scheme.primaryContainer,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              match.member.bio,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F7074),
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: match.reasons
                  .map(
                    (reason) => Chip(
                      label: Text(reason),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: onPlanTopic,
                    icon: const Icon(Icons.topic_outlined),
                    label: const Text('Plan topic'),
                  ),
                  FilledButton.tonalIcon(
                    label: const Text('Connect'),
                    icon: const Icon(Icons.link_rounded),
                    onPressed: () async {
  try {
    await ConnectionService.instance.sendRequest(
      match.member.id,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connection request sent to ${match.member.name}',
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
      ),
    );
  }
},
                  
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

class _EmptyMatchesCard extends StatelessWidget {
  const _EmptyMatchesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'No recommendations yet. Finish your profile preferences to see ranked matches.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _PlatformHero extends StatelessWidget {
  const _PlatformHero({required this.selectedIndex});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final mood = switch (selectedIndex) {
      0 => 'Curated feed',
      1 => 'Discovery mode',
      _ => 'Direct messages',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF123D38), Color(0xFF1F766E)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFBDE8E2),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A trusted place to trade knowledge, lived experience, and practical wisdom.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.blur_on_rounded, color: Colors.white, size: 44),
        ],
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

class _ExchangeCard extends StatelessWidget {
  const _ExchangeCard({
    required this.title,
    required this.subtitle,
    required this.tag,
  });

  final String title;
  final String subtitle;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Chip(
                  label: Text(tag),
                  backgroundColor: scheme.primaryContainer,
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5F7074),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ActiveDiscussionsPreview extends StatelessWidget {
  const _ActiveDiscussionsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Active discussions',
          subtitle: 'Continue conversations that matter.',
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            title: const Text('No active discussions yet'),
            subtitle: const Text(
              'Plan a topic to begin your first discussion.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DiscussionTrackerScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
class _SavedMomentsPreview extends StatelessWidget {
  const _SavedMomentsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Saved moments',
          subtitle: 'Words and lessons worth keeping.',
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            title: const Text('Nothing saved yet'),
            subtitle: const Text(
              'Save advice from chats and stories.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Saved Moments screen later
            },
          ),
        ),
      ],
    );
  }
}
class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Quick actions',
          subtitle: 'Jump to what you need.',
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LifeLibraryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Life Library'),
            ),

            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiscussionTrackerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Discussions'),
            ),

            FilledButton.icon(
              onPressed: () {
                // Connections screen later
              },
              icon: const Icon(Icons.people_outline),
              label: const Text('Connections'),
            ),
          ],
        ),
      ],
    );
  }
}
