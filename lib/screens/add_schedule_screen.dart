import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/screens/calendar_screen.dart';

class AddScheduleScreen extends StatefulWidget {
  final DateTime? date;
  AddScheduleScreen({this.date});
  
  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> schedules = [];
  TextEditingController _eventController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime(2100);

    DateTime? selectDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectDate != null && selectDate != initialDate) {
      setState(() {
        _controller.text =
            '${selectDate.year}-${selectDate.month}-${selectDate.day}';
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime = isStartTime
        ? (_startTime ?? TimeOfDay.now())
        : (_endTime ?? TimeOfDay.now());

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  final List<String> Members = [
    'Alice',
    'Bob',
    'Charlie',
    'Eve',
    'Daisy',
  ];

  List<String> SearchMembers = [];
  List<String> SelectMembers = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SearchMembers = Members;
  }

  void _searchMemebers(String query) {
    setState(() {
      if (query.isEmpty) {
        SearchMembers = Members;
      } else {
        SearchMembers = Members.where(
                (member) => member.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addMember(String member) {
    if (!SelectMembers.contains(member)) {
      setState(() {
        SelectMembers.add(member);
      });
    }
  }

  void _showTeamMemberPicker() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  decoration: customInputDecoration(
                    labelText: 'Search Team Members',
                    hintText: 'Type to search',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: _searchMemebers,
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: SearchMembers.length,
                    itemBuilder: (context, index) {
                      final member = SearchMembers[index];
                      return ListTile(
                        title: Text(member),
                        trailing: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _addMember(member);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _addTask() {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    Provider.of<ScheduleProvider>(context, listen: false).addSchedule(
      _selectedDate!,
      titleController.text,
      descriptionController.text,
      _startTime!.format(context),
      _endTime!.format(context),
      SelectMembers,
    );

    Navigator.pop(context);
    _eventController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Schedule'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: customInputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter title for the Task',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: customInputDecoration(
                labelText: 'Description',
                hintText: 'Enter Task description',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: customInputDecoration(
                labelText: 'Select Date',
                hintText: 'Tap to select date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: startTimeController,
                    decoration: customInputDecoration(
                      labelText: 'Start Time',
                      hintText: _startTime == null
                          ? 'Select Start Time'
                          : _startTime!.format(context),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, true),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: endTimeController,
                    decoration: customInputDecoration(
                      labelText: 'End Time',
                      hintText: _endTime == null
                          ? 'Select End Time'
                          : _endTime!.format(context),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _showTeamMemberPicker,
              child: AbsorbPointer(
                child: TextField(
                  controller: searchController,
                  decoration: customInputDecoration(
                    labelText: 'Search Team Members',
                    hintText: 'Type to search',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: _searchMemebers,
                ),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: SelectMembers.map(
                (member) => Chip(
                  label: Text(member),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      SelectMembers.remove(member);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black26, width: 1.0),
                    // 테두리 색과 두께 설정
                    borderRadius: BorderRadius.circular(20.0), // 모서리 둥글게 설정
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
              ).toList(),
            ),
            SizedBox(height: 100),
            ElevatedButton(
              onPressed: () {
                _addTask();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarScreen(schedules: schedules),
                  ),
                );
                if (_eventController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an event!')),
                  );
                  return;
                }

                if (_startTime == null || _endTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select both start and end times!')),
                  );
                  return;
                }

                final startTimeInMinutes = _startTime!.hour * 60 + _startTime!.minute;
                final endTimeInMinutes = _endTime!.hour * 60 + _endTime!.minute;

                if (startTimeInMinutes >= endTimeInMinutes) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('End time must be after start time!')),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Schedule added successfully!')),
                );

                Navigator.pop(context);
              },
              child: Text('Add Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration customInputDecoration({
  required String labelText,
  required String hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

