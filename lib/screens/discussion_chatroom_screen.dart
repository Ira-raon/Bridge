import 'package:flutter/material.dart';
import '../services/discussion_service_v2.dart';
import '../models/discussion_room.dart';
import '../models/discussion_topic.dart';
import '../services/discussion_service.dart';

class DiscussionChatroomScreen extends StatefulWidget {
  const DiscussionChatroomScreen({
    super.key,
    required this.roomId,
    required this.topicTitle,
  });

  final String roomId;
  final String topicTitle;
  

  @override
  State<DiscussionChatroomScreen> createState() => _DiscussionChatroomScreenState();
}

class _DiscussionChatroomScreenState extends State<DiscussionChatroomScreen> {
  final DiscussionService _service = DiscussionService.instance;
  final _messageController = TextEditingController();
  final _dbService = DiscussionServiceV2.instance;

  List<Map<String, dynamic>> _messages = [];

  bool _loading = true;

  Future<void> _loadMessages() async {
  try {
    final messages =
        await _dbService.getMessages(
      widget.roomId,
    );

    if (!mounted) return;

    setState(() {
      _messages = messages;
      _loading = false;
    });
  } catch (e) {
    print(e);
  }
}
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicTitle),
        actions: [
          IconButton(
            tooltip: 'Save session',
            onPressed: () => _saveSession(context),
            icon: const Icon(Icons.checklist_rounded),
          ),
        ],
      ),
      body: _loading
                ? const Center(
              child: CircularProgressIndicator(),
                  ): Column(
            children: [
              Expanded(
                child: ListView(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _RoomHeader(topicTitle: widget.topicTitle),
                    const SizedBox(height: 12),
                    // ...room.messages.map((message) => _MessageBubble(message: message))
                    ..._messages.map(
                     (message) => ListTile(
                      title: Text(
                       message['sender_name'] ?? '',
                        ),
                       subtitle: Text(
                        message['body'] ?? '',
                       ),
                     ),
                    ),
                    const SizedBox(height: 12),
                    // if (forum != null) ...[
                    //   _ForumPanel(forum: forum),
                    //   const SizedBox(height: 12),
                    // ],
                  ],
                ),
              ),
              _Composer(
                controller: _messageController,
                onSend: () async{
                  final text = _messageController.text.trim();
                  if (text.isEmpty) return;
                  // _service.addRoomMessage(
                  //   roomId: room.id,
                  //   author: 'You',
                  //   body: text,
                  // );
                  await _dbService.sendMessage(
                   roomId: widget.roomId,
                    body: text,
                    );

                   _messageController.clear();

                    await _loadMessages();
                  // _messageController.clear();
                  // setState(() {});
                },
              ),
            ],
      ),
      
    
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _saveSession(context),
      //   icon: const Icon(Icons.flag_rounded),
      //   label: const Text('Close session'),
      // ),
    );
  }

  Future<void> _saveSession(BuildContext context) async {
    final result = await showDialog<_SessionDraft>(
      context: context,
      builder: (context) => _SessionFinishDialog(topic: widget.topicTitle),
    );

    if (result == null) return;

    _service.addSession(
      topicId: widget.roomId,
      summary: result.summary,
      reflection: result.reflection,
      nextStep: result.nextStep,
      progressDelta: result.progressDelta,
    );
  }
}

class _RoomHeader extends StatelessWidget {
  const _RoomHeader({
    required this.topicTitle,
  });

  final String topicTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topicTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Discussion room',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Every pair gets its own room so the session stays structured and easy to review later.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final DiscussionMessage message;

  @override
  Widget build(BuildContext context) {
    final isYou = message.author == 'You';
    final isSystem = message.isSystem;
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isYou ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSystem
              ? scheme.surfaceContainerHighest
              : isYou
                  ? scheme.primaryContainer
                  : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E7EA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.author, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(message.body),
          ],
        ),
      ),
    );
  }
}

class _ForumPanel extends StatelessWidget {
  const _ForumPanel({required this.forum});

  final DiscussionForum forum;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Forum created for popular topic', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(forum.title),
            const SizedBox(height: 4),
            Text('Popularity score: ${forum.popularityScore}'),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.onSend});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Write a message',
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(onPressed: onSend, child: const Text('Send')),
          ],
        ),
      ),
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

class _SessionFinishDialog extends StatefulWidget {
  const _SessionFinishDialog({required this.topic});

  final String topic;

  @override
  State<_SessionFinishDialog> createState() => _SessionFinishDialogState();
}

class _SessionFinishDialogState extends State<_SessionFinishDialog> {
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
      title: Text('Close ${widget.topic} session'),
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
            if (!_formKey.currentState!.validate()) return;
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