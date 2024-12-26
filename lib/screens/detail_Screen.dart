import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  DetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task['task_title'],
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Date: ${task['task_dateTime']}',
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                'Time: ${task['task_startTime']} - ${task['task_endTime']}',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Text(
                'Description:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                task['task_description'],
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              SizedBox(height: 20),
              if (task['members'] != null && task['members'].isNotEmpty) ...[
                Text(
                  'Participants:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  task['members'].join(', '),
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
                SizedBox(height: 20),
              ],
              if (task['task_location'] != null) ...[
                Text(
                  'Location:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  task['task_location'],
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
                SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditEventScreen(task: task),
                        ),
                      );
                    },
                    child: Text('Edit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 일정 삭제
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text(
                              'Are you sure you want to delete this event?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Delete'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditEventScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  EditEventScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Event')),
      body: Center(
        child: Text('Edit event details for ${task['task_title']}'),
      ),
    );
  }
}
