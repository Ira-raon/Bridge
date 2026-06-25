import 'package:flutter/material.dart';
import '../widgets/app_navigation_bar.dart';
import '../services/connection_service.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  final _connectionService =
    ConnectionService.instance;

  final _notificationService =
    NotificationService.instance;

  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
       bottomNavigationBar: const AppNavigationBar(currentIndex: 0),
      body: FutureBuilder(
      future: Future.wait([
        _connectionService.getPendingRequests(),
        _notificationService.getNotifications(),
        ]),
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
          final requests =
            snapshot.data?[0]
                as List<Map<String,dynamic>>? ?? [];

          final notifications =
            snapshot.data?[1]
                as List<Map<String,dynamic>>? ?? [];

          if (requests.isEmpty && notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
                children: [
                
                  // Connection Requests
              
                  ...requests.map((request) {
                  
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
                                    await _connectionService
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
                                    await _connectionService
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
                  }),
              
                  // Chat Notifications
              
                  ...notifications.map(
                    (notification) => Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.notifications,
                        ),
                        title: Text(
                          notification['title'] ?? '',
                        ),
                        subtitle: Text(
                          notification['body'] ?? '',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          );
        },
      ),
    );
  }
}