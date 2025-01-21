import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/detail_screen.dart';

class UpdateTaskScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  UpdateTaskScreen({required this.task});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  late TextEditingController _taskTitleController;
  late TextEditingController _taskDescriptionController;
  late TextEditingController _taskStartTimeController;
  late TextEditingController _taskEndTimeController;
  late TextEditingController _taskDateTimeController;

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  String? selectedCategoryName;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late DateTime _selectedDate;

  List<String> _friendNames = [];
  List<Map<String, TextEditingController>> _plans = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _taskTitleController =
        TextEditingController(text: widget.task['task_title']);
    _taskDescriptionController =
        TextEditingController(text: widget.task['task_description']);
    _taskStartTimeController =
        TextEditingController(text: widget.task['task_startTime']);
    _taskEndTimeController =
        TextEditingController(text: widget.task['task_endTime']);
    _taskDateTimeController =
        TextEditingController(text: widget.task['task_dateTime']);
    selectedCategoryId = widget.task['categorie_categorie_id'];
    _friendNames = widget.task['members'] != null
        ? List<String>.from(widget.task['members'])
        : [];
    _selectedDate = widget.task['task_dateTime'] is String
        ? _parseDateString(widget.task['task_dateTime'])
        : widget.task['task_dateTime'] is DateTime
            ? widget.task['task_dateTime']
            : DateTime.now();

    _fetchPlan();
    _loadCategories();
    _addNewPlan();
  }

  String getFormattedDate(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  DateTime _parseDateString(String dateString) {
    final parts = dateString.split('-');
    if (parts.length == 3) {
      final year = parts[0];
      final month = parts[1].padLeft(2, '0');
      final day = parts[2].padLeft(2, '0');
      final formattedDate = '$year-$month-$day';
      return DateTime.parse(formattedDate);
    }
    return DateTime.now();
  }

  DateTime get _startOfWeek =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday % 7));

  final List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

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

  void _selectPlanTime(
      BuildContext context, bool isStartTime, int index) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      if (!mounted) return;
      final formattedTime = pickedTime.format(context);
      setState(() {
        if (isStartTime) {
          _plans[index]['plan_startTime']!.text = formattedTime;
        } else {
          _plans[index]['plan_endTime']!.text = formattedTime;
        }
      });
    }
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context);
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
          _taskStartTimeController.text = formattedTime;
        } else {
          _endTime = pickedTime;
          _taskEndTimeController.text = formattedTime;
        }
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final fetchedCategories = await _scheduleService.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> _fetchPlan() async {
    try {
      final responseData =
          await _scheduleService.getParticipant(widget.task['task_id']);
      setState(() {
        _plans = List<Map<String, TextEditingController>>.from(
            responseData['planResult'].map((plan) => {
                  'plan_detail':
                      TextEditingController(text: plan['plan_detail'] ?? ''),
                  'plan_startTime':
                      TextEditingController(text: plan['plan_startTime'] ?? ''),
                  'plan_endTime':
                      TextEditingController(text: plan['plan_endTime'] ?? ''),
                }));
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch plans: $error'),
          duration: Duration.zero,
        ),
      );
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

  _updateTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _scheduleService.updateTask(
        widget.task['task_id'],
        _taskTitleController.text,
        _taskDescriptionController.text,
        _taskStartTimeController.text,
        _taskEndTimeController.text,
        _taskDateTimeController.text,
        selectedCategoryId ?? 1,
        _friendNames,
        _plans.map((plan) {
          return {
            'plan_detail': plan['plan_detail']?.text,
            'plan_startTime': plan['plan_startTime']?.text,
            'plan_endTime': plan['plan_endTime']?.text,
          };
        }).toList(),
      );

      setState(() {
        _isLoading = false;
      });

      if (response['success']) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task updated successfully!'),
            duration: Duration.zero,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['message']}'),
            duration: Duration.zero,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: $e'),
          duration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> weekDay = getWeekDates();
    final selectedDate = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () {
                _updateTask();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(task: widget.task),
                  ),
                );
              },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Row(
                      children: [
                        Text(
                          'Complete',
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Icon(
                          Icons.check_rounded,
                          size: 15,
                          color: Color(0xffff4700),
                        ),
                      ],
                    ))
        ],
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                                _taskDateTimeController.text = getFormattedDate(currentDay);
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
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.title_rounded,
                          size: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Title',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _taskTitleController,
                    decoration: customInputDecoration(hintText: 'Task Title'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.wb_incandescent_rounded,
                          size: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _taskDescriptionController,
                    decoration:
                        customInputDecoration(hintText: 'Task Description'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Color(0xfff6e1de),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton2<int>(
                      hint: Text(
                        selectedCategoryId == null
                            ? 'Select Category'
                            : categories.firstWhere(
                                (category) =>
                                    category['categorie_id'] ==
                                    selectedCategoryId,
                                orElse: () => {'categorie_name': 'Unknown'},
                              )['categorie_name'],
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                      value: selectedCategoryId,
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedCategoryId = newValue;
                          selectedCategoryName = categories.firstWhere(
                            (category) => category['categorie_id'] == newValue,
                          )['categorie_name'];
                        });
                      },
                      isExpanded: true,
                      underline: SizedBox.shrink(),
                      dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_alarm_rounded,
                          size: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Task Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: _taskStartTimeController,
                          decoration: customInputDecoration(
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
                      SizedBox(width: 20),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: _taskEndTimeController,
                          decoration: customInputDecoration(
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
                ],
              ),
              SizedBox(height: 20),
              if (_friendNames.isNotEmpty)
                Column(
                  children: [
                    Text('Friend Names:'),
                    Wrap(
                      spacing: 8.0,
                      children: _friendNames.map((friendName) {
                        return Chip(
                          label: Text(friendName),
                          onDeleted: () {
                            setState(() {
                              _friendNames.remove(friendName);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_task_rounded,
                          size: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          'Plan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _plans.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _plans[index]['plan_detail']
                                      as TextEditingController,
                                  decoration: customInputDecoration(
                                      hintText: "Plan Detail"),
                                ),
                              ),
                              if (_plans.isNotEmpty)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 30,
                                    ),
                                    onPressed: () => _removePlan(index),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              _buildTimeField(
                                context: context,
                                controller: _plans[index]['plan_startTime']
                                    as TextEditingController,
                                hintText: _plans[index]['plan_startTime']
                                            ?.text
                                            .isEmpty ??
                                        true
                                    ? 'Plan Start'
                                    : _plans[index]['plan_startTime']!.text,
                                onTap: () =>
                                    _selectPlanTime(context, true, index),
                              ),
                              SizedBox(width: 20),
                              Icon(Icons.arrow_forward_sharp),
                              SizedBox(width: 20),
                              _buildTimeField(
                                context: context,
                                controller: _plans[index]['plan_endTime']
                                    as TextEditingController,
                                hintText: _plans[index]['plan_endTime']
                                            ?.text
                                            .isEmpty ??
                                        true
                                    ? 'Plan End'
                                    : _plans[index]['plan_endTime']!.text,
                                onTap: () =>
                                    _selectPlanTime(context, false, index),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addNewPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffa76962),
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
            ],
          ),
        ),
      ),
    );
  }
}

Expanded _buildTimeField({
  required BuildContext context,
  required TextEditingController controller,
  required String hintText,
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
    fillColor: Color(0xfff6e1de),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
  );
}
