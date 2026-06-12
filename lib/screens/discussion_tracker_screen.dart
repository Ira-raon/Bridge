import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/discussion_topic.dart';
import '../models/match_profile.dart';
import '../services/discussion_service.dart';
import '../services/match_service.dart';
import 'discussion_chatroom_screen.dart';
import '../services/discussion_service_v2.dart';

class DiscussionTrackerScreen extends StatefulWidget {
  const DiscussionTrackerScreen({super.key, this.initialMatch});

  final CommunityMember? initialMatch;

  @override
  State<DiscussionTrackerScreen> createState() => _DiscussionTrackerScreenState();
}

class _DiscussionTrackerScreenState extends State<DiscussionTrackerScreen> {
  final DiscussionService _service = DiscussionService.instance;
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discussion tracker'),
        actions: [
  IconButton(
    icon: const Icon(Icons.storage),
    onPressed: () async {
      final rooms =
          await DiscussionServiceV2.instance.getRooms();

      debugPrint(rooms.toString());
    },
  ),
],
      ),
      body: ValueListenableBuilder<List<DiscussionTopic>>(
        valueListenable: _service.topics,
        builder: (context, topics, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _TrackerHeader(initialMatch: widget.initialMatch),
              const SizedBox(height: 18),
              if (topics.isEmpty)
                const _EmptyTrackerCard()
              else
                Column(
                  children: topics
                      .map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                            child: _TopicCard(topic: topic, service: _service),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              _SectionHeader(
                title: 'Past discussions',
                subtitle: 'Review earlier sessions to see what changed over time.',
              ),
              const SizedBox(height: 12),
              if (_service.recentSessions.isEmpty)
                const _EmptySessionsCard()
              else
                Column(
                  children: _service.recentSessions
                      .map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SessionCard(session: session),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTopicDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New topic'),
      ),
    );
  }

  Future<void> _openTopicDialog(BuildContext context, {CommunityMember? initialMatch}) async {
    final matches = MatchService.instance.communityMembers;
    final draft = await showDialog<_TopicDraft>(
      context: context,
      builder: (context) => _TopicDialog(
        matches: matches,
        initialMatch: initialMatch ?? widget.initialMatch,
      ),
    );

    if (draft == null) {
      return;
    }

    await DiscussionServiceV2.instance.createRoom(
      topicTitle: draft.title,
    );

    _service.addTopic(
      DiscussionTopic(
        id: _uuid.v4(),
        matchId: draft.match.id,
        matchName: draft.match.name,
        roomId: 'room-${_uuid.v4()}',
        category: draft.category,
        title: draft.title,
        cadence: draft.cadence,
        goal: draft.goal,
        createdAt: DateTime.now(),
        progressScore: 0,
        sessions: const [],
      ),
    );
  }
}

class _TrackerHeader extends StatelessWidget {
  const _TrackerHeader({required this.initialMatch});

  final CommunityMember? initialMatch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Track every discussion topic separately.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a cadence for each pair, keep sessions structured, and review the progress after every conversation.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F7074)),
            ),
            if (initialMatch != null) ...[
              const SizedBox(height: 12),
              Chip(label: Text('Starting from ${initialMatch!.name}')),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.service});

  final DiscussionTopic topic;
  final DiscussionService service;

  @override
  Widget build(BuildContext context) {
    final recent = topic.sessions.take(2).toList();
    final forum = service.findForumByTopicId(topic.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${topic.matchName} • ${topic.category.label} • ${topic.cadence.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF61777A)),
                      ),
                    ],
                  ),
                ),
                Chip(label: Text('${topic.progressScore}%')),
              ],
            ),
            const SizedBox(height: 10),
            Text(topic.goal, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: topic.progressScore / 100),
            ),
            const SizedBox(height: 12),
            if (forum != null) ...[
              Chip(label: Text('Forum live: ${forum.popularityScore} popularity')),
              const SizedBox(height: 8),
            ],
            if (recent.isNotEmpty) ...[
              Text(
                'Recent sessions',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...recent.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• ${session.summary}', style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => DiscussionChatroomScreen(topic: topic)),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Open chatroom'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _addSession(context, topic),
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('Add reflection'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSession(BuildContext context, DiscussionTopic topic) async {
    final result = await showDialog<_SessionDraft>(
      context: context,
      builder: (context) => _SessionDialog(topic: topic),
    );

    if (result == null) {
      return;
    }

    service.addSession(
      topicId: topic.id,
      summary: result.summary,
      reflection: result.reflection,
      nextStep: result.nextStep,
      progressDelta: result.progressDelta,
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final DiscussionSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(session.summary, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(session.reflection, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text('Next step: ${session.nextStep}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Text('Progress moved by +${session.progressDelta}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _EmptyTrackerCard extends StatelessWidget {
  const _EmptyTrackerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text('No active topics yet. Add one to start tracking sessions and progress.'),
      ),
    );
  }
}

class _EmptySessionsCard extends StatelessWidget {
  const _EmptySessionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text('Past discussion sessions will show here once you add reflections.'),
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

class _TopicDraft {
  const _TopicDraft({required this.match, required this.category, required this.title, required this.goal, required this.cadence});

  final CommunityMember match;
  final AdviceTopic category;
  final String title;
  final String goal;
  final DiscussionCadence cadence;
}

class _TopicDialog extends StatefulWidget {
  const _TopicDialog({required this.matches, required this.initialMatch});

  final List<CommunityMember> matches;
  final CommunityMember? initialMatch;

  @override
  State<_TopicDialog> createState() => _TopicDialogState();
}

class _TopicDialogState extends State<_TopicDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _goalController;
  late CommunityMember _selectedMatch;
  AdviceTopic _category = AdviceTopic.careerAdvice;
  DiscussionCadence _cadence = DiscussionCadence.weekly;

  @override
  void initState() {
    super.initState();
    _selectedMatch = widget.initialMatch ?? widget.matches.first;
    _titleController = TextEditingController(text: '');
    _goalController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New discussion topic'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CommunityMember>(
                value: _selectedMatch,
                decoration: const InputDecoration(labelText: 'Match'),
                items: widget.matches
                    .map((match) => DropdownMenuItem(value: match, child: Text(match.name)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMatch = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AdviceTopic>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Topic area'),
                items: AdviceTopic.values
                    .map((topic) => DropdownMenuItem(value: topic, child: Text(topic.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Topic title'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(labelText: 'Goal for this topic'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              SegmentedButton<DiscussionCadence>(
                segments: DiscussionCadence.values
                    .map((cadence) => ButtonSegment(value: cadence, label: Text(cadence.label)))
                    .toList(),
                selected: {_cadence},
                onSelectionChanged: (selection) {
                  setState(() {
                    _cadence = selection.first;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              _TopicDraft(
                match: _selectedMatch,
                category: _category,
                title: _titleController.text.trim(),
                goal: _goalController.text.trim(),
                cadence: _cadence,
              ),
            );
          },
          child: const Text('Save topic'),
        ),
      ],
    );
  }
}

class _SessionDraft {
  const _SessionDraft({required this.summary, required this.reflection, required this.nextStep, required this.progressDelta});

  final String summary;
  final String reflection;
  final String nextStep;
  final int progressDelta;
}

class _SessionDialog extends StatefulWidget {
  const _SessionDialog({required this.topic});

  final DiscussionTopic topic;

  @override
  State<_SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<_SessionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _reflectionController = TextEditingController();
  final _nextStepController = TextEditingController();
  int _selectedDelta = 10;

  @override
  void dispose() {
    _summaryController.dispose();
    _reflectionController.dispose();
    _nextStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add reflection for ${widget.topic.title}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(labelText: 'Session summary'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reflectionController,
                decoration: const InputDecoration(labelText: 'Reflection'),
                maxLines: 3,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nextStepController,
                decoration: const InputDecoration(labelText: 'Next step'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedDelta,
                decoration: const InputDecoration(labelText: 'Progress made'),
                items: const [
                  DropdownMenuItem(value: 0, child: Text('No change')),
                  DropdownMenuItem(value: 10, child: Text('Small step')),
                  DropdownMenuItem(value: 20, child: Text('Good progress')),
                  DropdownMenuItem(value: 30, child: Text('Major breakthrough')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDelta = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              _SessionDraft(
                summary: _summaryController.text.trim(),
                reflection: _reflectionController.text.trim(),
                nextStep: _nextStepController.text.trim(),
                progressDelta: _selectedDelta,
              ),
            );
          },
          child: const Text('Save reflection'),
        ),
      ],
    );
  }
}