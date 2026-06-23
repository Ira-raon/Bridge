import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/discussion_topic.dart';
import '../models/match_profile.dart';
import '../services/discussion_service.dart';
import '../services/match_service.dart';
import 'discussion_chatroom_screen.dart';
import '../services/discussion_service_v2.dart';
import '../widgets/app_navigation_bar.dart';

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DiscussionServiceV2.instance.getRooms(),
        builder: (context, snapshot) {

           if (!snapshot.hasData) {
                return const Center(
              child: CircularProgressIndicator(),
            );
          }

        final rooms = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _TrackerHeader(initialMatch: widget.initialMatch),
              const SizedBox(height: 18),
              if (rooms.isEmpty)
                const _EmptyTrackerCard()
              else
                Column(
                  children: rooms
                      .map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                            child: _TopicCard(room: topic),   
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
              // if (_service.recentSessions.isEmpty)
              //   const _EmptySessionsCard()
              const Card(
                child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                    'Past discussion reflections will appear here.',
                 ),
                ),
              ),
              // else
                Column(
                  children: _service.recentSessions
                      .map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                          child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(session.summary),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: const AppNavigationBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTopicDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New topic'),
      ),
    );
  }

  Future<void> _openTopicDialog(BuildContext context, {CommunityMember? initialMatch}) async {
    final matches = await MatchService.instance.getCommunityMembers();
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

    final room = await DiscussionServiceV2.instance.createRoom(
      topicTitle: draft.title,
      participantId: draft.match.id,
      participantName: draft.match.name
    );

    // _service.addTopic(
    //   DiscussionTopic(
    //     id: _uuid.v4(),
    //     matchId: draft.match.id,
    //     matchName: draft.match.name,
    //     roomId: room['id'].toString(), // Assuming the room ID is returned from createRoom
    //     category: draft.category,
    //     title: draft.title,
    //     cadence: draft.cadence,
    //     goal: draft.goal,
    //     createdAt: DateTime.now(),
    //     progressScore: 0,
    //     sessions: const [],
    //   ),
    // );
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
  const _TopicCard({required this.room});

  final Map<String, dynamic> room;

  @override
  Widget build(BuildContext context) {
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
                        room['topic_title'] ?? 'Untitled',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        room['participant_name'] ?? 'Bridge Member',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF61777A)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 10,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.push(
                          context,
                        MaterialPageRoute(
                          builder: (_) => DiscussionChatroomScreen(
                          roomId: room['id'].toString(),
                          topicTitle: room['topic_title'] ?? 'Untitled',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Open chatroom'),
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

class _EmptyTrackerCard extends StatelessWidget {
  const _EmptyTrackerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text('No active topics yet. Add one to start a discussion room.'),
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