import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  Map<String, dynamic> user = {};

  Future<void> _fetchUser() async {
    try {
      final getUser = await _scheduleService.getUser();
      List<dynamic> userList = getUser['user'];
      Map<String, dynamic> fetchedUser = userList.isNotEmpty ? userList[0] : {};

      if (fetchedUser.isEmpty) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('No tasks found for the selected category and date')),
        );
      }

      setState(() {
        user = fetchedUser;
      });
    } catch (error) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
      body: user.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User ID: ${user['user_id']}'),
                Text('User Name: ${user['user_name']}'),
                Text('User Email: ${user['user_email']}'),
                user['user_profile'] == null
                    ? Icon(
                        Icons.account_circle,
                        size: 50,
                        color: Colors.grey,
                      )
                    : ClipOval(
                        child: Image.network(
                          user['user_profile']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
              ],
            )
          : Center(
              child: Text('No user data found'),
            ),
    );
  }
}
