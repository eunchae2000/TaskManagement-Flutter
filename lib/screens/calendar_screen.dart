import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/add_schedule_screen.dart';
import 'package:provider/provider.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _WeekCalendarState createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();

  final List<DateTime> weekDays = List.generate(7, (index) {
    return DateTime.now()
        .subtract(Duration(days: DateTime
        .now()
        .weekday - 1 - index));
  });

  int? selectedCategoryId;
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  final ScheduleService _scheduleService = ScheduleService();

  final List<String> stringDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];
  final List<String> stringMonth = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  DateTime parseTime(String timeString) {
    final format = DateFormat('hh:mm a');
    return format.parse(timeString);
  }

  String formatTime(String timeString) {
    final DateTime time = parseTime(timeString);
    return DateFormat('hh:mm a').format(time);
  }

  String calculateDuration(String startTime, String endTime) {
    final start = DateFormat('hh:mm a').parse(startTime);
    final end = DateFormat('hh:mm a').parse(endTime);
    final duration = end.difference(start);

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '';
    }
  }

  String calculateDDay(String taskDate) {
    final today = DateTime.now();
    final scheduleDate = DateFormat('yyyy-MM-dd').parse(taskDate);
    final difference = scheduleDate
        .difference(today)
        .inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference > 0) {
      return "D-$difference";
    } else {
      return "D+${-difference}";
    }
  }

  List<DateTime> getWeekDates(DateTime selectDate) {
    final int currentWeekDay = selectDate.weekday;
    final DateTime startOfWeek =
    selectDate.subtract(Duration(days: currentWeekDay - 1));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  String getFormattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await _scheduleService.fetchTask(
        getFormattedDate(_selectedDay),
      );

      setState(() {
        tasks = fetchedTasks;
      });

      if(!mounted) return;

      if (tasks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('No tasks found for the selected category and date')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully fetched ${tasks.length} tasks')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffddf2ff),
      body: SafeArea(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarHeader(),
              SizedBox(height: 12),
              _buildScheduleList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final List<DateTime> weekDay = getWeekDates(_selectedDay);
    final selectedDate = Provider.of<ScheduleProvider>(context);
    return Container(
      color: Color(0xffff4700),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            DropdownButton<int>(
              value: _selectedDay.month,
              dropdownColor: Color(0xFFff4700),
              underline: SizedBox.shrink(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xffffe7d6), size: 32),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedDay = DateTime(
                    _selectedDay.year,
                    newValue!,
                    1,
                  );
                });
              },
              items: List.generate(12, (index) {
                int monthNumber = index + 1;
                return DropdownMenuItem<int>(
                  value: monthNumber,
                  child: Text(
                    stringMonth[index],
                    style: TextStyle(color: Color(0xffffe7d6)),
                  ),
                );
              }),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffffe7d6),
                shape: CircleBorder(),
                padding: EdgeInsets.all(10.0),
              ),
              child: Icon(
                Icons.add,
                color: Color(0xffff4700),
                size: 30,
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
                    if (_selectedDay != currentDay) {
                      setState(() {
                        _selectedDay = currentDay;
                        selectedDate.setSelectedDate(currentDay);
                      });
                      _fetchTasks();
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddScheduleScreen(date: _selectedDay),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Text(
                        stringDays[index],
                        style: TextStyle(
                            color: Color(0xffffe7d6),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xffffe7d6)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            currentDay.day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Color(0xffff4700)
                                  : Color(0xffffe7d6),
                              fontSize: 15,
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
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'No schedules',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child:
              ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${task['task_startTime']} - ${task['task_endTime']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      task['task_title']!,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${task['task_description']}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              color: Color(0xffe9e9e9),
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            child: Text(
                              calculateDDay(task['task_dateTime']),
                              style: TextStyle(color: Colors.black54),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: calculateDuration(task['task_startTime'],
                                task['task_endTime']) ==
                                ''
                                ? Colors.white
                                : Color(0xffe9e9e9),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          child: Text(
                            calculateDuration(
                                task['task_startTime'], task['task_endTime']),
                            style: TextStyle(
                              color: calculateDuration(task['task_startTime'],
                                  task['task_endTime']) == ''
                                  ? Colors.black
                                  : Colors.black54,
                            ),
                          ),

                        ),
                      ],
                    ),
                  ],
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
              ));

          // 멤버 목록
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 16),
          //       child: Text(
          //         '${task['members'].join(',')}',
          //         style: TextStyle(fontSize: 14, color: Colors.black54),
          //       ),
          //     ),
          //     Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 16),
          //       child: Text(
          //         '${task['task_description']}',
          //         style: TextStyle(fontSize: 14, color: Colors.black54),
          //       ),
          //     )
          //   ],
          // )
        },
      ),

    );
  }
}
