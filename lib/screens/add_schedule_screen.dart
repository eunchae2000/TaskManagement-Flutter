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
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  TimeOfDay? _planStartTime;
  TimeOfDay? _planEndTime;

  final List<Map<String, TextEditingController>> _plans = [];

  final ScheduleService scheduleService = ScheduleService();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> selectFriends = [];
  Map<String, dynamic>? selectedFriend;

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  String? selectedCategoryName;

  DateTime get _startOfWeek =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFriends();
    _addNewPlan();
  }

  Future<void> _loadFriends() async {
    try {
      List<Map<String, dynamic>> friendList =
          await scheduleService.friendsList();
      setState(() {
        friends = friendList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Friend List Failed')));
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await scheduleService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('load Category Failed')));
      }
    }
  }

  void _addNewPlan() {
    setState(() {
      _plans.add({
        'plan_detail': TextEditingController(),
        'plan_startTime': TextEditingController(),
        'plan_endTime': TextEditingController(),
      });
    });
  }

  void _removePlan(int index) {
    setState(() {
      _plans.removeAt(index);
    });
  }

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

  void _selectTime(BuildContext context, bool isStartTime, int index) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? currentStartTime;
    TimeOfDay? currentEndTime;

    if (index == 0) {
      currentStartTime = isStartTime ? _startTime : _endTime;
    } else if (index == 1 && _plans.length > 1) {
      currentStartTime = isStartTime ? _planStartTime : _planEndTime;
    }

    TimeOfDay initialSelectedTime = isStartTime
        ? (currentStartTime ?? initialTime)
        : (currentEndTime ?? initialTime);

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialSelectedTime,
    );
    print(pickedTime);

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          if (index == 0) {
            _startTime = pickedTime;
          } else if (index == 1) {
            _planStartTime = pickedTime;
          }
        } else {
          if (index == 0) {
            _endTime = pickedTime;
          } else if (index == 1) {
            _planEndTime = pickedTime;
          }
        }
      });
    }
  }

  Future<void> _addTask() async {
    if (!_validateInputs()) return;
    final selectedFriendsNames =
        selectFriends.map((friend) => friend['user_name'] as String).toList();

    final plans = _plans
        .map((plan) => {
              'plan_detail': plan['plan_detail']!.text,
              'plan_startTime':_planStartTime!.format(context),
              'plan_endTime': _planEndTime!.format(context),
            })
        .toList();

    print('${plans}');

    final result = await scheduleService.addTask(
      selectedFriendsNames,
      titleController.text,
      descriptionController.text,
      _startTime!.format(context),
      _endTime!.format(context),
      getFormattedDate(_selectedDate),
      selectedCategoryId ?? 1,
      plans,
    );

    if (mounted) {
      if (result['success']) {
        _showSnackBar('Task added successfully');
        Navigator.pop(context);
      } else {
        _showSnackBar('Error: ${result['message']}');
      }
    }
  }

  bool _validateInputs() {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      _showSnackBar('Please complete all fields');
      return false;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    if (startMinutes >= endMinutes) {
      _showSnackBar('End time must be after start time');
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDay = getWeekDates();
    final selectedDate = Provider.of<ScheduleProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(20.0),
        child: AppBar(
          title: null,
          automaticallyImplyLeading: false,
        ),
      ),
      body: SingleChildScrollView(
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
                hintText: 'Enter title for the Task',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: customInputDecoration(
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
                    child: Text(
                      category['categorie_name'],
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  );
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
                      hintText: _startTime == null
                          ? 'Select Start Time'
                          : _startTime!.format(context),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, true, 0),
                  ),
                ),
                SizedBox(width: 20),
                Icon(Icons.arrow_forward_sharp),
                SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: endTimeController,
                    decoration: customInputDecoration(
                      hintText: _endTime == null
                          ? 'Select End Time'
                          : _endTime!.format(context),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () => _selectTime(context, false, 0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _plans[index]['plan_detail'],
                      decoration:
                          customInputDecoration(hintText: "Plan Detail"),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        _buildTimeField(
                          context: context,
                          controller: _plans[index]['plan_startTime'],
                          hintText: _planStartTime == null
                              ? 'Plan Start'
                              : _planStartTime!.format(context),
                          isStartTime: true,
                          onTap: () => _selectTime(context, true, 1),
                        ),
                        SizedBox(width: 20),
                        Icon(Icons.arrow_forward_sharp),
                        SizedBox(width: 20),
                        _buildTimeField(
                          context: context,
                          controller: _plans[index]['plan_endTime'],
                          hintText: _planEndTime == null
                              ? 'Plan End'
                              : _planEndTime!.format(context),
                          isStartTime: false,
                          onTap: () => _selectTime(context, false, 1),
                        ),
                      ],
                    ),
                    if (_plans.length > 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _removePlan(index),
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 5),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addNewPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffd9d9d9),
                  foregroundColor: Color(0xffa3a3a3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 40,
                  color: Color(0xfff5f5f5),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Color(0xffffe7d6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<Map<String, dynamic>>(
                hint: Text(
                  'Select Friend',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                value: selectedFriend,
                onChanged: (Map<String, dynamic>? newFriend) {
                  setState(() {
                    if (newFriend != null) {
                      selectedFriend = newFriend;
                      if (selectFriends.contains(newFriend)) {
                        selectFriends.remove(newFriend);
                      } else {
                        selectFriends.add(newFriend);
                      }
                    }
                  });
                },
                isExpanded: true,
                underline: SizedBox.shrink(),
                items: friends.map((friend) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: friend,
                    child: Text(
                      friend['user_name'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 7.0,
              runSpacing: 1.0,
              children: selectFriends.map((member) {
                return Chip(
                  label: Text(member['user_name']),
                  deleteIcon: Icon(Icons.close),
                  onDeleted: () {
                    setState(() {
                      selectFriends.remove(member);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black26, width: 1.0),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
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
                      builder: (context) => CalendarScreen(),
                    ),
                  );

                  final startTimeInMinutes =
                      _startTime!.hour * 60 + _startTime!.minute;
                  final endTimeInMinutes =
                      _endTime!.hour * 60 + _endTime!.minute;

                  if (startTimeInMinutes >= endTimeInMinutes) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('End time must be after start time!')),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Schedule added successfully!')),
                  );

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
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
      ),
    );
  }
}

Expanded _buildTimeField({
  required BuildContext context,
  required TextEditingController? controller,
  required String hintText,
  required bool isStartTime,
  required Function onTap,
}) {
  return Expanded(
    child: TextField(
      readOnly: true,
      controller: controller,
      decoration: customInputDecoration(
        hintText: hintText,
        suffixIcon: Icon(Icons.access_time),
      ),
      onTap: () => onTap(),
    ),
  );
}

InputDecoration customInputDecoration({
  required String hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
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
