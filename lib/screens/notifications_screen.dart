import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  Future<List<dynamic>>? _notificationsFuture;
  bool showFullTaskList = false;
  bool showFullFriendList = false;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _scheduleService.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(25.0),
        child: AppBar(
          title: Text('Notifications'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: _buildNotificationList(),
    );
  }

  String formatTimeAgo(String notificationCreateAt) {
    DateTime notificationDateTime = DateTime.parse(notificationCreateAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(notificationDateTime);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else {
        return '${difference.inHours}h';
      }
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${notificationDateTime.year}-${notificationDateTime.month}-${notificationDateTime.day}';
    }
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
    final taskNotifications = notifications
        .where((notification) => notification['notifications_type'] == 'task')
        .toList();
    final friendNotifications = notifications
        .where(
            (notification) => notification['notifications_type'] == 'friends')
        .toList();

    if (taskNotifications.isEmpty && friendNotifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView(
      children: [
        _buildNotificationSection(
          title: 'Tasks',
          notifications: taskNotifications,
          showFullList: showFullTaskList,
          toggleShowFullList: () {
            setState(() {
              showFullTaskList = !showFullTaskList;
            });
          },
        ),
        _buildNotificationSection(
          title: 'Friends',
          notifications: friendNotifications,
          showFullList: showFullFriendList,
          toggleShowFullList: () {
            setState(() {
              showFullFriendList = !showFullFriendList;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required List<dynamic> notifications,
    required bool showFullList,
    required VoidCallback toggleShowFullList,
  }) {
    final unreadCount = notifications
        .where(
            (notification) => notification['notifications_status'] == 'unread')
        .length;

    if (notifications.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'No $title notifications available',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }


    final displayedNotifications =
        showFullList ? notifications : notifications.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (notifications.length > 3)
                    IconButton(
                      onPressed: toggleShowFullList,
                      icon: Icon(
                        showFullList
                            ? Icons.expand_less
                            : Icons.more_horiz_rounded,
                        size: 24,
                      ),
                    )
                ],
              ),
              if (unreadCount > 0) _buildUnreadCountCircle(unreadCount),
            ],
          ),
        ),
        ...displayedNotifications.map<Widget>(
            (notification) => _buildNotificationTile(notification)),
      ],
    );
  }

  Widget _buildUnreadCountCircle(int count) {
    return Container(
      width: 45,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Color(0xffFF4700),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    return ListTile(
      leading: Icon(
        notification['notifications_type'] == 'task'
            ? Icons.task_alt_rounded
            : Icons.account_circle_rounded,
        color: Color(0xffff4700),
        size: 50,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(notification['sender_name'] ?? 'Unknown'),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Color(0xffd9d9d9),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 5),
              Text(
                formatTimeAgo(notification['notifications_createdAt']),
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      subtitle: Text(
        notification['notifications_type'] == 'task'
            ? (notification['notifications_action'] == 'request'
                ? 'Sent a task participation request'
                : notification['notifications_action'] == 'response'
                    ? 'Received a response to your task participation'
                    : 'Task action not recognized')
            : 'Sent a member request',
      ),
      trailing: Text(notification['notifications_status'] ?? 'No Status'),
    );
  }
}
