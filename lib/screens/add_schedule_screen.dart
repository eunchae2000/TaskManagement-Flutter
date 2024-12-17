import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management/providers/schedule_provider.dart';

class AddScheduleScreen extends StatelessWidget{
  final DateTime date;
  final TextEditingController _controller = TextEditingController();
  AddScheduleScreen({required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: '일정 내용 입력'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final schedule = _controller.text;
                if (schedule.isNotEmpty) {
                  Provider.of<ScheduleProvider>(context, listen: false)
                      .addSchedule(date, schedule);
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