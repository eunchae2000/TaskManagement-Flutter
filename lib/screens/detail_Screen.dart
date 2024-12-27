import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;

  DetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    final List<String> members =
        task['members'] != null ? List<String>.from(task['members']) : [];
    return Scaffold(
      backgroundColor: Colors.white,
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
                  child: Text(
                    '${task['task_startTime']} - ${task['task_endTime']}',
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
            Center(
              child: _memberAvatars(members),
            )
          ],
        ),
      ),
    );
  }
}

Widget _memberAvatars(List<String> members) {
  if (members.isEmpty) {
    return Text('');
  }

  int maxDisplay = 3;
  List<String> displayMembers = members.take(maxDisplay).toList();
  int remainingCount = members.length > maxDisplay ? members.length - maxDisplay : 0;

  double containerWidth = 33.0 * displayMembers.length.toDouble();
  if (remainingCount > 0) {
    containerWidth += 30.0;
  }

  return Center(
    child: Container(
      height: 40.0,
      width: containerWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...displayMembers.asMap().map((index, member) {
            String firstLetter = member.isNotEmpty ? member[0].toUpperCase() : '';
            return MapEntry(
              index,
              Positioned(
                left: index * 30.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xffe9e9e9),
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18.0,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      firstLetter,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          }).values.toList(),

          if (remainingCount > 0)
            Positioned(
              left: displayMembers.length * 30.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffff4700),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 18.0,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
