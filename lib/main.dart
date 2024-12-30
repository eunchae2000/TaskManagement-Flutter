import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/screens/calendar_screen.dart';
import 'package:task_management/screens/login_screen.dart';
import 'package:task_management/screens/members_screen.dart';
import 'package:task_management/screens/notifications_screen.dart';
import 'package:task_management/screens/register_screen.dart';
import 'package:task_management/screens/search_screen.dart';
import 'package:task_management/screens/setting_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ScheduleProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'FredokaSemiBold',
      ),
      home: LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    CalendarScreen(),
    SearchScreen(),
    SettingScreen(),
    MembersScreen(),
    NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          clipBehavior: Clip.hardEdge,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 30.0,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  size: 30.0,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  size: 30.0,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.people,
                  size: 30.0,
                ),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.notifications,
                  size: 30.0,
                ),
                label: "",
              ),
            ],
            type: BottomNavigationBarType.fixed,
            backgroundColor: Color(0xff637899),
            selectedItemColor: Color(0xffFF4700),
            unselectedItemColor: Color(0xffDDF2FF),
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            elevation: 10,
            showUnselectedLabels: false,
          ),
        ),
      ),
    );
  }
}
