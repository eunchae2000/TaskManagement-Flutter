import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/add_schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:task_management/screens/detail_Screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _WeekCalendarState createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();

  final List<DateTime> weekDays = List.generate(7, (index) {
    return DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1 - index));
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
    final difference = scheduleDate.difference(today).inDays;

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

      for (var task in tasks) {
        final participants =
            await _scheduleService.getParticipant(task['task_id']);
        task['members'] = participants;
        print(task['members']);
      }

      if (!mounted) return;

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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarHeader(),
              SizedBox(
                height: 7,
              ),
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
      decoration: BoxDecoration(
        color: Color(0xffff4700),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            DropdownButton2<int>(
              value: _selectedDay.month,
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  color: Color(0xffffe7d6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              underline: SizedBox.shrink(),
              iconStyleData: IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xffffe7d6),
                ),
              ),
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
                    style: TextStyle(
                        fontFamily: 'FredokaSemiBold',
                        color: monthNumber == _selectedDay.month
                            ? Color(0xffffe7d6)
                            : Color(0xffff4700),
                        fontSize: monthNumber == _selectedDay.month ? 30 : 20),
                  ),
                );
              }),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddScheduleScreen(date: _selectedDay),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: Color(0xffffe7d6),
                    size: 25,
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddScheduleScreen(date: _selectedDay),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xffffe7d6),
                      size: 25,
                    )),
              ],
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        stringDays[index],
                        style: TextStyle(
                            color: Color(0xffffe7d6),
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
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
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final List<String> members =
              task['members'] != null ? List<String>.from(task['members']) : [];
          return Container(
              margin: EdgeInsets.only(bottom: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${task['task_startTime']} - ${task['task_endTime']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        _memberAvatars(members),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      task['task_title']!,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      child: Text(
                        '${task['task_description']}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: Color(0xffe9e9e9),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
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
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Text(
                                calculateDuration(task['task_startTime'],
                                    task['task_endTime']),
                                style: TextStyle(
                                  color: calculateDuration(
                                              task['task_startTime'],
                                              task['task_endTime']) ==
                                          ''
                                      ? Colors.black
                                      : Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 43,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailScreen(task: task),
                                ),
                              );
                            },
                            icon: Icon(
                              MaterialCommunityIcons.arrow_top_right,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(task: task),
                      ));
                },
              ));
        },
      ),
    );
  }
}

Widget _memberAvatars(List<String> members) {
  if (members.isEmpty) {
    return Text('');
  }

  int maxDisplay = 2;
  List<String> displayMembers = members.take(maxDisplay).toList();
  int remainingCount =
      members.length > maxDisplay ? members.length - maxDisplay : 0;

  double containerWidth = 40.0 * displayMembers.length.toDouble();
  if (remainingCount > 0) {
    containerWidth += 10.0;
  }

  return Center(
    child: Container(
      height: 40.0,
      width: containerWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...displayMembers
              .asMap()
              .map((index, member) {
                String firstLetter =
                    member.isNotEmpty ? member[0].toUpperCase() : '';
                return MapEntry(
                  index,
                  Positioned(
                    left: index * 25.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffe9e9e9),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18.0,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          firstLetter,
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              })
              .values
              .toList(),

          // 나머지 인원 표시
          if (remainingCount > 0)
            Positioned(
              left: displayMembers.length * 25.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffff4700),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18.0,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
