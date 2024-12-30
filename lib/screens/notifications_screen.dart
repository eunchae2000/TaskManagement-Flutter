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
      body: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    return FutureBuilder<List<dynamic>>(
      future: _notificationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No notifications found'));
        } else {
          return _buildListView(snapshot.data!);
        }
      },
    );
  }

  Widget _buildListView(List<dynamic> notifications) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationTile(notification);
      },
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return ListTile(
      leading: Icon(
        notification['type'] == 'task' ? Icons.task : Icons.account_circle_rounded,
        color: Colors.blue,
      ),
      title: Text(notification['action'] ?? 'No Action'),
      subtitle: Text('From: ${notification['sender_name'] ?? 'Unknown'}'),
      trailing: Text(notification['status'] ?? 'No Status'),
    );
  }
}
