import 'package:flutter/material.dart';
import '../models/match_profile.dart';
import '../services/match_service.dart';
import 'life_library_screen.dart';

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
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed_rounded),
            label: 'Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Messages',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _PlatformHero(selectedIndex: selectedIndex),
          const SizedBox(height: 18),
          const _RecommendedMatchesSection(),
          const SizedBox(height: 18),
          const _SectionHeader(
            title: 'Open exchanges',
            subtitle: 'Requests that match your profile and interests.',
          ),
          const SizedBox(height: 14),
          const _ExchangeCard(
            title: 'Mentorship swap',
            subtitle: 'Share career lessons in return for design feedback.',
            tag: 'Active now',
          ),
          const SizedBox(height: 12),
          const _ExchangeCard(
            title: 'Local knowledge circle',
            subtitle: 'Collect neighborhood tips and offer a process template.',
            tag: '3 invites',
          ),
          const SizedBox(height: 18),
          const _SectionHeader(
            title: 'Post a new exchange',
            subtitle: 'Start a conversation with a clear offer and request.',
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              labelText: 'What are you offering?',
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'What are you looking for?',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send_rounded),
            label: const Text('Publish exchange'),
          ),
        ],
      ),
    );
  }
}

class _RecommendedMatchesSection extends StatelessWidget {
  const _RecommendedMatchesSection();

  @override
  Widget build(BuildContext context) {
    const effectivePreferences = UserPreferences(
      displayName: 'Bridge member',
     // premium: false,
      role: UserRole.seeker,
      adviceTopics: {AdviceTopic.careerAdvice},
      supportStyles: {SupportStyle.empathetic},
      experiencePreference: ExperiencePreference.sameExperience,
      careerField: '',
      preferSameCareerField: false,
      additionalNotes: '',
      lifeExperiences: {},
    );

    final matches =
        MatchService.instance.recommend(effectivePreferences);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Recommended matches',
          subtitle: 'Ranked by shared topic, tone, and experience.',
        ),
        const SizedBox(height: 14),

        if (matches.isEmpty)
          const _EmptyMatchesCard()
        else
          Column(
            children: matches
                .map(
                  (match) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MatchCard(
                      match: match,
                      onPlanTopic: () {},
                    ),
                  ),
                )
                .toList(),
          ),
      ],
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Connection request sent to ${match.member.name}')),
                      );
                    },
                    icon: const Icon(Icons.link_rounded),
                    label: const Text('Connect'),
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
