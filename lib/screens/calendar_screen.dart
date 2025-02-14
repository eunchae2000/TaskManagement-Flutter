import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/add_schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:task_management/screens/detail_screen.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? date;

  CalendarScreen({this.date});

  @override
  _WeekCalendarState createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();

  int? selectedCategoryId;
  List<Map<String, dynamic>> tasks = [];
  Map<String, int> _taskCounts = {};

  Future<void> _fetchTaskCounts() async {
    try {
      final count = await _scheduleService.fetchTaskCounts();
      setState(() {
        _taskCounts = count;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  bool isTaskExpired(String taskDate, String taskEndTime) {
    DateTime now = DateTime.now();

    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime endDate = dateFormat.parse(taskDate);

    DateFormat timeFormat = DateFormat("h:mm a");
    DateTime endTime = timeFormat.parse(taskEndTime);

    DateTime endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    return now.isAfter(endDateTime);
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _fetchTaskCounts();
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
    final DateTime startOfWeek =
        selectDate.subtract(Duration(days: _selectedDay.weekday % 7));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String getFormattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> _fetchTasks() async {
    try {
      final fetchedTasks = await _scheduleService.fetchTask(
        getFormattedDate(_selectedDay),
      );

      final List<Map<String, dynamic>> updatedTasks = [];

      for (var task in fetchedTasks) {
        final participants =
            await _scheduleService.getParticipant(task['task_id']);
        final members = (participants['result'] as List<dynamic>)
            .map((item) => item['user_name'].toString())
            .toList();
        task['members'] = members;
        updatedTasks.add(task);
      }

      setState(() {
        tasks = updatedTasks;
      });
    } catch (error) {
      if (!mounted) return;
      throw Exception(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarHeader(),
          SizedBox(
            height: 7,
          ),
          _buildScheduleList(),
        ],
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
              underline: SizedBox.shrink(),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                        fontFamily: 'NunitoBold',
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
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xffffe7d6),
                    size: 25,
                  ),
                  onSelected: (String value) {
                    if (value == 'register') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddScheduleScreen()),
                      );
                    } else if (value == 'manage') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddScheduleScreen()),
                      );
                    }
                  },
                  offset: Offset(0, 50),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                        value: 'register',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Category Register',
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(Icons.add_rounded)
                          ],
                        )),
                    PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'manage',
                      child: Text(
                        'Category manage',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final DateTime currentDay = weekDay[index];
                final taskCount = _taskCounts[getFormattedDate(currentDay)];
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
                      if (taskCount != 0 && taskCount != null)
                        Icon(Icons.circle_rounded, size: 3,),
                      Container(
                        width: 35,
                        height: 35,
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
          bool expired =
              isTaskExpired(task['task_dateTime'], task['task_endTime']);
          return expired
              ? Container(
                  margin: EdgeInsets.only(bottom: 7),
                  decoration: BoxDecoration(
                    color: Color(0xffffbf77),
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
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${task['task_startTime']} - ${task['task_endTime']}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              task['task_title']!,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              task['task_description']!,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.all(10),
                          width: 43,
                          decoration: BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ))
              : Container(
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
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            _memberAvatars(members),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          task['task_title']!,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
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
                                    color: calculateDuration(
                                                task['task_startTime'],
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
    child: SizedBox(
      height: 40.0,
      width: containerWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...displayMembers.asMap().map((index, member) {
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
          }).values,
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
