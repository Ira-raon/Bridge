import 'package:flutter/material.dart';

import '../services/connection_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  final _service = ConnectionService.instance;

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _service.getPendingRequests(),
        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {

                final request = requests[index];

                final requester =
                    request['requester'];

                final name =
                    requester?['display_name']
                    ?? 'Bridge Member';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          '$name wants to connect.',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [

                            FilledButton(
                              onPressed: () async {

                                await _service
                                    .acceptRequest(
                                  request['id'],
                                );

                                _refresh();
                              },
                              child: const Text(
                                'Accept',
                              ),
                            ),

                            const SizedBox(width: 12),

                            OutlinedButton(
                              onPressed: () async {

                                await _service
                                    .declineRequest(
                                  request['id'],
                                );

                                _refresh();
                              },
                              child: const Text(
                                'Decline',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}