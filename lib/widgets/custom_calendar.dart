import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/screens/calendar_screen.dart';

class CalendarWithScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScheduleProvider(),
      child: CalendarScreen(schedules: [],),
    );
  }
}