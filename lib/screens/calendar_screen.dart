import 'package:flutter/material.dart';
import 'package:task_management/screens/add_schedule_screen.dart';

class CalendarScreen extends StatefulWidget{
  @override
  _WeekCalendarState createState() => _WeekCalendarState();

}

class _WeekCalendarState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  final Color backgroundColor = Color(0xFFE87645);
  final List<DateTime> weekDays = List.generate(7, (index){
    return DateTime.now().subtract(Duration(days: DateTime.now().weekday-1-index));
  });

  final Map<DateTime, List<Map<String, String>>> scheduleData = {
    DateTime.utc(2024, 12, 17): [
      {'title': 'Team Meeting', 'description': 'Discussion with the team', 'time': '10:00 AM'},
      {'title': 'PM Meeting', 'description': 'Tasks for the month', 'time': '1:00 PM'},
    ],
    DateTime.utc(2024, 12, 18): [
      {'title': 'One-to-one', 'description': 'Repeats every two weeks', 'time': '12:00 PM'}
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 월과 요일 캘린더
            _buildCalendarHeader(),
            SizedBox(height: 12),
            // 일정 리스트
            Expanded(child: _buildScheduleList()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader(){
    return Container(
      color: Colors.deepOrangeAccent,
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((_selectedDay.month).toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: weekDays.map((day){
              bool isSelected = day.day == _selectedDay.day && day.month == _selectedDay.month && day.year == _selectedDay.year;
              return GestureDetector(
                onTap: (){
                  setState(() {
                    _selectedDay = day;
                  });
                  Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => AddScheduleScreen(date: _selectedDay),
                  ),
                  );
                },
                child: Column(
                  children: [
                    Text(_getWeekDayName(day.weekday),
                    style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.deepOrangeAccent: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(){
    final selectedSchedules = scheduleData[_selectedDay] ?? [];
    if(selectedSchedules.isEmpty){
      return Center(
        child: Text(
          'No schedules',
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: selectedSchedules.length,
        itemBuilder: (context, index){
          final schedule = selectedSchedules[index];
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
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              title: Text(
                schedule['title']!,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${schedule['time']} - ${schedule['description']}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
            ),
          );
        },);
  }
  String _getWeekDayName(int weekday){
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}