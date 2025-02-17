import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/screens/calendar_screen.dart';
import 'package:task_management/screens/login_screen.dart';
import 'package:task_management/screens/members_screen.dart';
import 'package:task_management/screens/notifications_screen.dart';
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
        fontFamily: 'NunitoBold',
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
    MembersScreen(),
    NotificationsScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    print(_pages[_currentIndex]);
    print(_currentIndex);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        title: null,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Color(0xff637899),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.search_rounded, 1),
            _buildNavItem(Icons.people_alt_rounded, 2),
            _buildNavItem(Icons.notifications_rounded, 3),
            _buildNavItem(Icons.settings_rounded, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xffFF4700) : Color(0xffDDF2FF),
            size: isSelected ? 26 : 26,
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Color(0xffFF4700),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
