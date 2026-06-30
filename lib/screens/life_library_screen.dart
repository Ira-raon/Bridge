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
           FutureBuilder<List<Map<String, dynamic>>>(
            future: _service.getStories(),
            builder: (context, snapshot) {
            
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              final stories = snapshot.data ?? [];

              if (stories.isEmpty) {
                return const Center(
                  child: Text(
                    'No stories yet. Be the first to share one.',
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stories.length,
                itemBuilder: (context, index) {
                
                  final story = stories[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                          onTap: () {
                            _showStory(
                              context,
                              story,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              
                                Text(
                                  story['title'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'Shared by ${story['author_name']} • '
                                  '${DateTime.parse(story['created_at']).toLocal().toString().split(".").first}',
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                  
                                    FilledButton.icon(
                                      onPressed: () async {
                                      
                                        await _service.toggleHelped(
                                          story['id'],
                                        );

                                        if (!context.mounted) return;

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Thanks for letting them know their story helped.',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.favorite_outline),
                                      label: const Text('Helped Me'),
                                    ),

                                    const Spacer(),

                                    if (story['user_id'] ==
                                        _service.currentUserId)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                        ),
                                        onPressed: () async {
                                        
                                          await _service.deleteStory(
                                            story['id'],
                                          );

                                          if (!context.mounted) return;

                                          setState(() {});
                                        },
                                      ),

                                    IconButton(
                                      icon: const Icon(
                                        Icons.bookmark_border,
                                      ),
                                      onPressed: () async {
                                      
                                        await _service.toggleSaved(
                                          story['id'],
                                        );

                                        if (!context.mounted) return;

                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    );
                  },
                );
              },
            ),
            
           // Saved
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _service.getSavedStories(),
            builder: (context, snapshot) {
            
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
          
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
          
              final savedStories = snapshot.data ?? [];
          
              if (savedStories.isEmpty) {
                return const Center(
                  child: Text(
                    'No saved stories yet.',
                  ),
                );
              }
          
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: savedStories.length,
                itemBuilder: (context, index) {
                
                  final story =
                      savedStories[index]['life_library'];
          
                  return Card(
                    margin:
                        const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                    
                      title: Text(
                        story['title'],
                      ),
          
                      subtitle: Text(
                        'Shared by ${story['author_name']}',
                      ),
          
                      onTap: () {
                        _showStory(
                          context,
                          story,
                        );
                      },
          
                      trailing: IconButton(
                        icon: const Icon(Icons.bookmark),
                        onPressed: () async {
                        
                          await _service.toggleSaved(
                            story['id'],
                          );
          
                          setState(() {});
          
                        },
                      ),
                    ),
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

    await _service.addStory(
      title: res.title,
      content: res.content,
    );

    if (!mounted) return;

    setState(() {});
  }

  void _showStory(
    BuildContext context,
    Map<String, dynamic> story,
  ) {
    final reflectionController =
    TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(story['title']),
        content: SizedBox(
          width: 500,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _service.getReflections(
              story['id'],
            ),
            builder: (context, snapshot) {

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final reflections =
                  snapshot.data ?? [];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      story['content'],
                    ),

                    const SizedBox(height: 24),
                    FutureBuilder<int>(
                      future: _service.getHelpedCount(
                        story['id'],
                      ),
                      builder: (context, snapshot) {
                      
                        final helped =
                            snapshot.data ?? 0;

                        return Row(
                          children: [
                          
                            const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              'Helped $helped ${helped == 1 ? "person" : "people"}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    const Divider(),

                      Text(
                        'How did this story help you?',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller: reflectionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'Share what you learned or what you did differently...',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () async {
                          
                            if (reflectionController.text.trim().isEmpty) {
                              return;
                            }

                            await _service.addReflection(
                              storyId: story['id'],
                              reflection:
                                  reflectionController.text.trim(),
                            );

                            if (!context.mounted) return;

                            Navigator.pop(context);

                            _showStory(
                              context,
                              story,
                            );
                          },
                          child: const Text(
                            'Share Reflection',
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Reflections',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),

                      const SizedBox(height: 12),

                    if (reflections.isEmpty)
                      const Text(
                        'No reflections yet.',
                      ),

                    ...reflections.map(
                      (reflection) => Card(
                        child: ListTile(
                          title: Text(
                            reflection[
                                'author_name'],
                          ),
                          subtitle: Text(
                            reflection[
                                'reflection'],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StoryDraft {
  _StoryDraft({
    required this.title, 
    required this.content});

  final String title;
  final String content;
  
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


  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
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
            
            ));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
