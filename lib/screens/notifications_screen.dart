import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  Future<List<dynamic>>? _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _scheduleService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error fetching notifications',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found'));
          } else {
            final notifications = snapshot.data!;
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: Icon(
                    notification['type'] == 'task' ? Icons.task : Icons.people,
                    color: Colors.blue,
                  ),
                  title: Text(notification['action'] ?? 'No Action'),
                  subtitle: Text('From: ${notification['sender_name'] ?? 'Unknown'}'),
                  trailing: Text(notification['status'] ?? 'No Status'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationDetailScreen(notification: notification),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;

  NotificationDetailScreen({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(notification['action'] ?? 'Notification Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['action'] ?? 'No Action',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              notification['message'] ?? 'No Message',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'From: ${notification['sender_name'] ?? 'Unknown'}',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
