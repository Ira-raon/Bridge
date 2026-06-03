import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/story.dart';
import '../services/life_service.dart';

class LifeLibraryScreen extends StatefulWidget {
  const LifeLibraryScreen({super.key, this.currentUser});

  final String? currentUser;

  @override
  State<LifeLibraryScreen> createState() => _LifeLibraryScreenState();
}

class _LifeLibraryScreenState extends State<LifeLibraryScreen> {
  final LifeService _service = LifeService.instance;
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Life library'),
          bottom: const TabBar(tabs: [Tab(text: 'Uploads'), Tab(text: 'Saved')]),
        ),
        body: TabBarView(
          children: [
            // Uploads
            ValueListenableBuilder<List<Story>>(
              valueListenable: _service.stories,
              builder: (context, list, _) {
                final uploads = widget.currentUser == null
                    ? list
                    : list.where((s) => s.author == widget.currentUser).toList();

                if (uploads.isEmpty) {
                  return const Center(child: Text('No stories yet. Tap + to add.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: uploads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final s = uploads[i];
                    return Card(
                      child: ListTile(
                        title: Text(s.title),
                        subtitle: Text('by ${s.author} — ${s.createdAt.toLocal().toString().split('.').first}'),
                        onTap: () => _showStory(context, s),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _service.removeById(s.id),
                            ),
                            ValueListenableBuilder<Set<String>>(
                              valueListenable: _service.savedIds,
                              builder: (context, saved, __) {
                                final savedHere = saved.contains(s.id);
                                return IconButton(
                                  icon: Icon(savedHere ? Icons.bookmark : Icons.bookmark_border),
                                  onPressed: () => _service.toggleSaved(s.id),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Saved
            ValueListenableBuilder<List<Story>>(
              valueListenable: _service.stories,
              builder: (context, list, _) {
                return ValueListenableBuilder<Set<String>>(
                  valueListenable: _service.savedIds,
                  builder: (context, saved, __) {
                    final savedStories = list.where((s) => saved.contains(s.id)).toList();
                    if (savedStories.isEmpty) {
                      return const Center(child: Text('No saved stories yet.'));
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: savedStories.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final s = savedStories[i];
                        return Card(
                          child: ListTile(
                            title: Text(s.title),
                            subtitle: Text('by ${s.author} — ${s.createdAt.toLocal().toString().split('.').first}'),
                            onTap: () => _showStory(context, s),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _service.removeById(s.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark),
                                  onPressed: () => _service.toggleSaved(s.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addStory(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _addStory(BuildContext context) async {
    final res = await showDialog<_StoryDraft>(
      context: context,
      builder: (context) => const _AddStoryDialog(),
    );

    if (res == null) return;

    final story = Story(
      id: _uuid.v4(),
      title: res.title,
      content: res.content,
      author: res.author,
    );

    _service.add(story);
  }

  void _showStory(BuildContext context, Story s) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.title),
        content: SingleChildScrollView(child: Text(s.content)),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }
}

class _StoryDraft {
  _StoryDraft({required this.title, required this.content, required this.author});

  final String title;
  final String content;
  final String author;
}

class _AddStoryDialog extends StatefulWidget {
  const _AddStoryDialog();

  @override
  State<_AddStoryDialog> createState() => _AddStoryDialogState();
}

class _AddStoryDialogState extends State<_AddStoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _author = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _author.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add story'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 6,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
            Navigator.of(context).pop(_StoryDraft(
              title: _title.text.trim(),
              content: _content.text.trim(),
              author: _author.text.trim(),
            ));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
