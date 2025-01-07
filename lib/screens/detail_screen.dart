import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  DetailScreen({required this.task});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<Map<String, dynamic>> plans = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPlan();
  }

  Future<void> _fetchPlan() async {
    try {
      final responseData =
          await _scheduleService.getParticipant(widget.task['task_id']);
      setState(() {
        plans = List<Map<String, dynamic>>.from(responseData['planResult']);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> members = widget.task['members'] != null
        ? List<String>.from(widget.task['members'])
        : [];
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
            SizedBox(
              height: 20,
            ),
            Center(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Text(
                    '${widget.task['task_startTime']} - ${widget.task['task_endTime']}',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  )),
            ),
            Center(
              child: Text(
                widget.task['task_title'],
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                '${widget.task['task_description']}',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: _memberAvatars(members),
            ),
            SizedBox(
              height: 40,
            ),
            Expanded(
              child: plans.isEmpty
                  ? Center(
                      child: Text(
                        'No plans available',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : Column(
                      children: [
                        Center(
                          child: Text("Plan",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 20,),
                        Expanded(
                          child: ListView.builder(
                            itemCount: plans.length,
                            itemBuilder: (context, index) {
                              final plan = plans[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Color(0xff8aade1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              plan['plan_detail']!,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                            ),
                                          ),
                                          SizedBox(width: 50),
                                          Text(
                                            '${plan['plan_startTime']} - ${plan['plan_endTime']}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailScreen(task: plan),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _memberAvatars(List<String> members) {
  if (members.isEmpty) {
    return SizedBox();
  }

  int maxDisplay = 3;
  List<String> displayMembers = members.take(maxDisplay).toList();
  int remainingCount =
      members.length > maxDisplay ? members.length - maxDisplay : 0;

  return Center(
    child: SizedBox(
      height: 70.0,
      width: 70.0 +
          (55.0 * (displayMembers.length - 1)) +
          (remainingCount > 0 ? 55.0 : 0.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...displayMembers.asMap().entries.map((entry) {
            int index = entry.key;
            String member = entry.value;
            String firstLetter =
                member.isNotEmpty ? member[0].toUpperCase() : '';
            return Positioned(
              left: index * 55.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffffe7d6),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35.0,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                        color: Color(0xffff4700),
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
              ),
            );
          }),
          if (remainingCount > 0)
            Positioned(
              left: displayMembers.length * 55.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffffe7d6),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  radius: 35.0,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                        color: Color(0xffff4700),
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
