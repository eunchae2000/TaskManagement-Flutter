import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/screens/add_schedule_screen.dart';
import 'package:task_management/screens/calendar_screen.dart';
import 'package:task_management/screens/register_screen.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> schedules = [
      {
        'date': '2024-12-18', // 날짜
        'startTime': '10:00 AM', // 시작 시간
        'endTime': '11:00 AM', // 종료 시간
        'title': 'Project Meeting', // 일정 제목
        'description': 'Discuss project progress and deadlines', // 일정 설명
        'time': '10:00 AM - 11:00 AM', // 시간 (병합된 형태로 사용 가능)
        'members': ['Alice', 'Bob', 'Charlie'] // 참여 멤버 목록
      },
      {
        'date': '2024-12-18',
        'startTime': '1:00 PM',
        'endTime': '2:00 PM',
        'title': 'Team Lunch',
        'description': 'Lunch with the team at the cafeteria',
        'time': '1:00 PM - 2:00 PM',
        'members': ['David', 'Ella', 'Frank']
      },
      {
        'date': '2024-12-18',
        'startTime': '6:00 PM',
        'endTime': '7:00 PM',
        'title': 'Workout Session',
        'description': 'Evening workout at the gym',
        'time': '6:00 PM - 7:00 PM',
        'members': ['George', 'Hannah']
      }
    ];
    return ChangeNotifierProvider(
      create: (context) => ScheduleProvider(),
      child: MaterialApp(
        title: 'Task Management',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: RegisterScreen(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
