import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final TextEditingController startTimeController;
  final TextEditingController endTimeController;
  final VoidCallback onSelectStartTime;
  final VoidCallback onSelectEndTime;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  TimeSelector({
    required this.startTimeController,
    required this.endTimeController,
    required this.onSelectStartTime,
    required this.onSelectEndTime,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Start Time
        Expanded(
          child: TextField(
            readOnly: true,
            controller: startTimeController,
            decoration: InputDecoration(
              labelText: 'Start Time',
              hintText: startTime == null ? 'Select Start Time' : startTime!.format(context),
              suffixIcon: Icon(Icons.access_time),
            ),
            onTap: onSelectStartTime,
          ),
        ),
        SizedBox(width: 20),
        Icon(Icons.arrow_forward_sharp),
        SizedBox(width: 20),
        // End Time
        Expanded(
          child: TextField(
            readOnly: true,
            controller: endTimeController,
            decoration: InputDecoration(
              labelText: 'End Time',
              hintText: endTime == null ? 'Select End Time' : endTime!.format(context),
              suffixIcon: Icon(Icons.access_time),
            ),
            onTap: onSelectEndTime,
          ),
        ),
      ],
    );
  }
}
