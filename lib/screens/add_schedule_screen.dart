import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/providers/schedule_service.dart';
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
  DateTime _selectedDate = DateTime.now();
  int? selectedUserId;

  final ScheduleService scheduleService = ScheduleService();

  // 카테고리
  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  String? selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await scheduleService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      print('Error loading categories: $error');
    }
  }

  List<Map<String, dynamic>> schedules = [];
  TextEditingController _eventController = TextEditingController();

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // week 이동
  DateTime get _startOfWeek =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7));
    });
  }

  final List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  List<DateTime> getWeekDates() {
    return List.generate(7, (index) => _startOfWeek.add(Duration(days: index)));
  }

  String _getMonthName(int month) {
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return monthNames[month - 1];
  }

  String getFormattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // 선택한 시간
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
  // void initState() {
  //   super.initState();
  //   SearchMembers = Members;
  // }

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

  Future<void> _addTask() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _selectedDate == null ||
        _startTime == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    final result = await scheduleService.addTask(
      titleController.text,
      descriptionController.text,
      _startTime!.format(context),
      _endTime!.format(context),
      getFormattedDate(_selectedDate),
      selectedCategoryId ?? 1,
    );
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $_selectedDate.month')),
      );
      Navigator.pop(context);
      _eventController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${result['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDay = getWeekDates();
    final selectedDate = Provider.of<ScheduleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _selectedDate,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () => _previousWeek(),
                              icon: Icon(Icons.keyboard_arrow_left)),
                          Text(
                            '${_selectedDate.year}, ${_getMonthName(_selectedDate.month)}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                              onPressed: () => _nextWeek(),
                              icon: Icon(Icons.keyboard_arrow_right)),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (index) {
                        final DateTime currentDay = weekDay[index];
                        final isSelected = currentDay.day ==
                                selectedDate.selectedDate.day &&
                            currentDay.month ==
                                selectedDate.selectedDate.month &&
                            currentDay.year == selectedDate.selectedDate.year;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate.setSelectedDate(currentDay);
                              _selectedDate = currentDay;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xffff4700)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  weekDays[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black38,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  currentDay.day.toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
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
              maxLines: 5,
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Color(0xffffe7d6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<int>(
                hint: Text(
                  'Select Category',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                value: selectedCategoryId,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedCategoryId = newValue;
                    selectedCategoryName = categories.firstWhere((category) =>
                        category['categorie_id'] == newValue)['categorie_name'];
                  });
                },
                isExpanded: true,
                underline: SizedBox.shrink(),
                items: categories.map((category) {
                  return DropdownMenuItem<int>(
                      value: category['categorie_id'],
                      child: Container(
                        child: Text(
                          category['categorie_name'],
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ));
                }).toList(),
              ),
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
                SizedBox(width: 20),
                Icon(Icons.arrow_forward_sharp),
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
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
              ).toList(),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xffff4700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Color(0xffff4700), width: 2.0),
                      ),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 17)),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addTask();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CalendarScreen(),
                        ),
                      );

                      if (_startTime == null || _endTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Please select both start and end times!')),
                        );
                        return;
                      }

                      final startTimeInMinutes =
                          _startTime!.hour * 60 + _startTime!.minute;
                      final endTimeInMinutes =
                          _endTime!.hour * 60 + _endTime!.minute;

                      if (startTimeInMinutes >= endTimeInMinutes) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('End time must be after start time!')),
                        );
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Schedule added successfully!')),
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 16.0),
                      backgroundColor: Color(0xffff4700),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Save Task', style: TextStyle(fontSize: 17)),
                  ),
                )
              ],
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
    fillColor: Color(0xffffe7d6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
  );
}
