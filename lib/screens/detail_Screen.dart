import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  DetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(10.0),
        child: AppBar(
          title: null,
          automaticallyImplyLeading: false,
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffe9e9e9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close_rounded),
                    color: Colors.black,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xffe9e9e9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.edit_calendar),
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  child: Text('${task['task_startTime']} - ${task['task_endTime']}',
                    style: TextStyle(color: Colors.white),
                  )),
            ),
            Center(
              child: Text(
                task['task_title'],
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                '${task['task_description']}',
                style: TextStyle(fontSize: 16.0),
              ),
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
          ],
        ),
      ),
    );
  }
}
