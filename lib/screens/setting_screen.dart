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

      setState(() {
        user = fetchedUser;
      });
    } catch (error) {
      throw Exception(error);
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
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: user.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      user['user_profile'] == null
                          ? Icon(
                              Icons.account_circle,
                              size: 120,
                              color: Color(0xffff4700),
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
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user['user_email'],
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                          user: user,
                                        )));
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Color(0xff2f4858)),
                              foregroundColor:
                                  WidgetStatePropertyAll(Color(0xffddf2ff))),
                          child: Text(
                            'Edit Profile',
                            style: TextStyle(fontSize: 17),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Color(0x20ff4700),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomTextButton(
                                onPressed: () {},
                                leadingIcon: Icons.language_rounded,
                                text: 'Language'),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.notifications_active_rounded,
                                          color: Color(0xff2f4858),
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        'Push Notifications',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xff2f4858)),
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
                                      activeColor: Color(0xff2f4858),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Color(0x20ff4700),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
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
                      )
                    ],
                  )
                : Center(
                    child: Text('No user data found'),
                  ),
          ),
        ));
  }
}
