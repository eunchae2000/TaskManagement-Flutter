import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/screens/add_schedule_screen.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _WeekCalendarState createState() => _WeekCalendarState();

  final List<Map<String, dynamic>>? schedules;

  CalendarScreen({this.schedules});
}

class _WeekCalendarState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();

  final Color backgroundColor = Color(0xffFFD6E4);
  final List<DateTime> weekDays = List.generate(7, (index) {
    return DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1 - index));
  });

  final List<String> StringDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  List<DateTime> getWeekDates() {
    final DateTime now = DateTime.now();
    final DateTime sunday = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => sunday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe6f4f1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarHeader(),
            SizedBox(height: 12),
            Expanded(child: _buildScheduleList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final List<DateTime> weekDay = getWeekDates();
    final selectedDate = Provider.of<ScheduleProvider>(context);
    return Container(
      color: Color(0xff78b1e0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              (_selectedDay.month).toString(),
              style: TextStyle(
                color: Color(0xffFcfcd4),
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddScheduleScreen(date: _selectedDay),
                  ),
                );
              },
              child: Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffe6f4f1),
                shape: CircleBorder(),
                padding: EdgeInsets.all(17.0),
              ),
            ),
          ]),
          SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final DateTime currentDay = weekDay[index];
                final isSelected =
                    currentDay.day == selectedDate.selectedDate.day &&
                        currentDay.month == selectedDate.selectedDate.month &&
                        currentDay.year == selectedDate.selectedDate.year;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate.setSelectedDate(currentDay);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddScheduleScreen(date: _selectedDay),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        StringDays[index],
                        style: TextStyle(
                            color: Color(0xffFcfcd4),
                            fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xffFcfcd4)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            currentDay.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Color(0xff78b1e0)
                                  : Color(0xffFcfcd4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              })),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final schedule = Provider.of<ScheduleProvider>(context).schedule;
    if (schedule.isEmpty) {
      return Center(
        child: Text(
          'No schedules',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: schedule.length,
      itemBuilder: (context, index) {
        final task = schedule[index];
        return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.all(12),
                  title: Text(
                    task['title']!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${task['startTime']} - ${task['endTime']}',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Colors.grey.shade400),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarScreen(),
                        ));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${task['members'].join(',')}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${task['description']}',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    )
                  ],
                )
              ],
            ));
      },
    );
  }
}
