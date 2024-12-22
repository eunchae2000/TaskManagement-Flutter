import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final Function(TimeOfDay) onStartTimeSelected;
  final Function(TimeOfDay) onEndTimeSelected;

  TimePicker({
    required this.onStartTimeSelected,
    required this.onEndTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context, true),
            child: TextField(
              readOnly: true,
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: 'Start Time',
                hintText: 'Select Start Time',
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
          ),
        ),
        Icon(Icons.arrow_forward_sharp),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(context, false),
            child: TextField(
              readOnly: true,
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: 'End Time',
                hintText: 'Select End Time',
                suffixIcon: Icon(Icons.access_time),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    TimeOfDay initialTime = isStartTime ? TimeOfDay.now() : TimeOfDay.now();
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      if (isStartTime) {
        onStartTimeSelected(pickedTime);
      } else {
        onEndTimeSelected(pickedTime);
      }
    }
  }
}
