import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';


class AddScheduleScreen extends StatefulWidget {
  final DateTime date;
  final TextEditingController _controller = TextEditingController();

  AddScheduleScreen({required this.date});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();

}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate = DateTime(2100);

    DateTime ? selectDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (selectDate != null && selectDate != initialDate) {
      setState(() {
        _controller.text =
        '${selectDate.year}-${selectDate.month}-${selectDate.day}';
      });
    }
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title:
        Text('Add Schedule'),
          backgroundColor: Colors.deepOrangeAccent,),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  labelText: 'Task Title',
                  hintText: 'Enter title for the Task',
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 12.0),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  labelText: 'Description',
                  hintText: 'Enter Task description',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  hintText: 'Tap to select date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final schedule = _controller.text;
                  if (schedule.isNotEmpty) {
                    Provider.of<ScheduleProvider>(context, listen: false)
                        .addSchedule(widget.date, schedule);
                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        ),
      );
    }
  }