import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/edit_profile_screen.dart';
import 'package:task_management/screens/faq_screen.dart';
import 'package:task_management/screens/login_screen.dart';
import 'package:task_management/screens/send_feedback_screen.dart';
import 'package:task_management/widgets/setting_textButton.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  Map<String, dynamic> user = {};
  bool isNotificationEnabled = true;

  bool isLoading = false;

  Future<void> logout() async {
    setState(() {
      isLoading = true;
    });

    await _scheduleService.logout();

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _fetchUser() async {
    try {
      final getUser = await _scheduleService.getUser();
      List<dynamic> userList = getUser['user'];
      Map<String, dynamic> fetchedUser = userList.isNotEmpty ? userList[0] : {};

      if (fetchedUser.isEmpty) {
        if (!mounted) return;
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
      if (!mounted) return;
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
        title: null,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: user.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  user['user_profile'] == null
                      ? Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Color(0xffffe7d6),
                        )
                      : ClipOval(
                          child: Image.network(
                            user['user_profile']!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    user['user_name'],
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user['user_email'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                          user: user,
                                        )));
                          },
                          leadingIcon: Icons.person_rounded,
                          text: 'Edit User'),
                      CustomTextButton(
                          onPressed: () {},
                          leadingIcon: Icons.language_rounded,
                          text: 'Language'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Color(0xffffe7d6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_active_outlined,
                                    color: Color(0xffff4700),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Text(
                                  'Push Notifications',
                                  style: TextStyle(
                                      fontSize: 16, color: Color(0xffff4700)),
                                ),
                              ],
                            ),
                            Theme(
                              data: ThemeData(useMaterial3: false),
                              child: Switch(
                                value: isNotificationEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    isNotificationEnabled = value;
                                  });
                                },
                                activeColor: Color(0xffff4700),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                      height: 20,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FAQScreen()));
                          },
                          leadingIcon: Icons.help_rounded,
                          text: 'FAQ'),
                      CustomTextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SendFeedbackScreen()));
                          },
                          leadingIcon: Icons.feedback_rounded,
                          text: 'Send Feedback'),
                      CustomTextButton(
                          onPressed: () {},
                          leadingIcon: Icons.support_rounded,
                          text: 'Help & Support'),
                      CustomTextButton(
                          onPressed: () {
                            logout();
                          },
                          leadingIcon: Icons.logout_rounded,
                          text: 'Log out'),
                    ],
                  ),
                ],
              )
            : Center(
                child: Text('No user data found'),
              ),
      ),
    );
  }
}
