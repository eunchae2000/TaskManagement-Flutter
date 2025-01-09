import 'package:flutter/material.dart';
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

  TimeOfDay? _planStartTime;
  TimeOfDay? _planEndTime;

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
    _fetchPlan();
    _loadCategories();
    _addNewPlan();
  }

  void _selectPlanTime(
      BuildContext context, bool isStartTime, int index) async {
    TimeOfDay initialTime = TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
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
      print(fetchedCategories);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('load Category Failed')));
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch plans: $error')));
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task updated successfully!')));
      } else {
        print('error ${response['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response['message']}')));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: null),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(Icons.title_rounded, size: 15,),
                          SizedBox(width: 7,),
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
                          Icon(Icons.wb_incandescent_rounded, size: 15,),
                          SizedBox(width: 7,),
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
                          Icon(Icons.access_alarm_rounded, size: 15,),
                          SizedBox(width: 7,),
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
                TextField(
                  controller: _taskDateTimeController,
                  decoration:
                      InputDecoration(labelText: 'Date (e.g., 2025-01-10)'),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          Icon(Icons.category_outlined, size: 15,),
                          SizedBox(width: 7,),
                          Text(
                            'Category',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Color(0xffffe7d6),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButton<int>(
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
                              (category) =>
                                  category['categorie_id'] == newValue,
                            )['categorie_name'];
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
                          Icon(Icons.add_task_rounded, size: 15,),
                          SizedBox(width: 7,),
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
                                if (_plans.length > 0)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, size: 30,),
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
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _updateTask();
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
                  child:
                      _isLoading ? CircularProgressIndicator() : Text('cancle'),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _updateTask();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(task: widget.task),
                      ),
                    );
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
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Update Task'),
                ),
              )
            ],
          ),
        ));
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
    fillColor: Color(0xffffe7d6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
  );
}
