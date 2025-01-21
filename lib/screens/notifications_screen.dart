import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  final ScheduleService _scheduleService = ScheduleService();
  Future<List<dynamic>>? _notificationsFuture;
  late TabController _tabController;
  final Map<String, int> _unreadCounts = {
    'all': 0,
    'task': 0,
    'friends': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationsFuture = _scheduleService.fetchNotifications();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _onTabSelected(int index) {
    String notificationType = '';

    if (index == 0) {
      notificationType = 'task';
    } else if (index == 1) {
      notificationType = 'friends';
    }

    _scheduleService.notificationsAsRead(notificationType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        bottom: TabBar(
          onTap: _onTabSelected,
          controller: _tabController,
          tabs: [
            _buildTab('All', _unreadCounts['all']!),
            _buildTab('Task', _unreadCounts['task']!),
            _buildTab('Member', _unreadCounts['friends']!),
          ],
          indicatorColor: Color(0xffff4700),
          labelColor: Color(0xffff4700),
          unselectedLabelColor: Color(0xff637899),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notifications found'));
          } else {
            _calculateUnreadCounts(snapshot.data!);

            return TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList(snapshot.data!, 'all'),
                _buildNotificationList(snapshot.data!, 'task'),
                _buildNotificationList(snapshot.data!, 'friends'),
              ],
            );
          }
        },
      ),
    );
  }

  void _calculateUnreadCounts(List<dynamic> notifications) {
    _unreadCounts['all'] = notifications
        .where(
            (notification) => notification['notifications_status'] == 'unread')
        .length;
    _unreadCounts['task'] = notifications
        .where((notification) =>
            notification['notifications_type'] == 'task' &&
            notification['notifications_status'] == 'unread')
        .length;
    _unreadCounts['friends'] = notifications
        .where((notification) =>
            notification['notifications_type'] == 'friends' &&
            notification['notifications_status'] == 'unread')
        .length;
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

  Widget _buildTab(String label, int unreadCount) {
    return Tab(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text('${label}'),
          ),
          if (unreadCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.circle_rounded,
                size: 7,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(List<dynamic> notifications, String type) {
    final filteredNotifications = notifications
        .where((notification) =>
            type == 'all' || notification['notifications_type'] == type)
        .toList();

    if (filteredNotifications.isEmpty) {
      return const Center(child: Text('No notifications'));
    }

    return ListView(
      children: filteredNotifications.map<Widget>((notification) {
        return Column(
          children: [
            _buildNotificationTile(notification),
            Divider(),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final isTask = notification['notifications_type'] == 'task';
    print(isTask);

    return ListTile(
      leading: notification['user_profile'] == null
          ? Icon(
              Icons.account_circle,
              size: 50,
              color: Color(0xffffe7d6),
            )
          : ClipOval(
              child: Image.network(
                notification['user_profile']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${notification['sender_name']}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Icon(
                Icons.circle_rounded,
                size: 6,
                color: Colors.grey,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                formatTimeAgo(notification['notifications_createdAt']),
                style: TextStyle(fontSize: 10),
              ),
            ],
          )
        ],
      ),
      subtitle: Text(
        isTask
            ? (notification['notifications_action'] == 'request'
                ? 'sent a task participation request'
                : notification['notifications_action'] == 'response'
                    ? ' received a response to your task participation'
                    : ' task action not recognized')
            : ' sent a member request',
      ),
      trailing: notification['notifications_status'] == 'unread'
          ? Icon(
              Icons.circle,
              color: Color(0xffff4700),
              size: 8,
            )
          : SizedBox.shrink(),
    );
  }
}
