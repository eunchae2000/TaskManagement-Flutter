import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/providers/schedule_service.dart';

class InvitedTaskMemberScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  InvitedTaskMemberScreen({required this.task});

  @override
  _InvitedTaskMemberScreenState createState() =>
      _InvitedTaskMemberScreenState();
}

class _InvitedTaskMemberScreenState extends State<InvitedTaskMemberScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  List<Map<String, dynamic>> plans = [];
  Map<String, dynamic> friends = {};
  List<Map<String, dynamic>> selectFriends = [];
  Map<String, dynamic>? selectedFriend;

  @override
  void initState() {
    super.initState();
    _fetchPlan();
    _loadFriends();
  }

  String formatDate(String date) {
    List<String> parts = date.split('-');
    String year = parts[0];
    String month = parts[1].padLeft(2, '0');
    String day = parts[2].padLeft(2, '0');

    DateTime dateTime = DateTime.parse('$year-$month-$day');

    String formattedDate = DateFormat('d MMM yyyy').format(dateTime);

    return formattedDate;
  }

  Future<void> _loadFriends() async {
    try {
      Map<String, dynamic> friendList =
          await _scheduleService.fetchAvailableFriends(widget.task['task_id']);
      setState(() {
        friends = friendList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Friend List Failed')));
      }
    }
  }

  Future<void> _fetchPlan() async {
    try {
      final responseData =
          await _scheduleService.getParticipant(widget.task['task_id']);
      setState(() {
        plans = List<Map<String, dynamic>>.from(responseData['planResult']);
      });
    } catch (error) {
      throw Error();
    }
  }

  Future<void> _addTaskInvitation() async {
    final selectedFriendsNames =
        selectFriends.map((friend) => friend['user_name'] as String).toList();

    final result = await _scheduleService.addTaskInvitation(
        selectedFriendsNames, widget.task['task_id']);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Task added successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Task invited failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> members = (widget.task['members'] is List)
        ? List<String>.from(widget.task['members'])
        : [];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: null,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatDate(widget.task['task_dateTime']),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff637899)),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Container(
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Color(0xff637899),
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Text(
                    '${widget.task['task_startTime']} - ${widget.task['task_endTime']}',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
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
              height: 30,
            ),
            Container(
              child: Center(
                child: Column(
                  children: [
                    Text('pending'),
                    Wrap(
                      spacing: 7.0,
                      runSpacing: 1.0,
                      children: friends['taskResult'] != null
                          ? List<Widget>.from(friends['taskResult']
                              .where((member) => member['status'] == 'pending')
                              .map((member) {
                              return Chip(
                                label: Text(member['user_name'] ?? 'Unknown'),
                                backgroundColor: Color(0xffe9e9e9),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Color(0xffe9e9e9), width: 1.5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                              );
                            }).toList())
                          : [],
                    ),
                    Text('accepted'),
                    Wrap(
                      spacing: 7.0,
                      runSpacing: 1.0,
                      children: friends['taskResult'] != null
                          ? List<Widget>.from(friends['taskResult']
                              .where((member) => member['status'] == 'accepted')
                              .map((member) {
                              return Chip(
                                label: Text(member['user_name'] ?? 'Unknown'),
                                backgroundColor: Color(0xffddf2ff),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Color(0xff8aade1), width: 1.5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                              );
                            }).toList())
                          : [],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xffddf2ff),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton2<Map<String, dynamic>>(
                hint: Text(
                  'Select Friend',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[700],
                  ),
                ),
                value: selectedFriend,
                onChanged: (Map<String, dynamic>? newFriend) {
                  setState(() {
                    if (newFriend != null) {
                      selectedFriend = newFriend;
                      if (selectFriends.contains(newFriend)) {
                        selectFriends.remove(newFriend);
                      } else {
                        selectFriends.add(newFriend);
                      }
                    }
                  });
                },
                isExpanded: true,
                underline: SizedBox.shrink(),
                dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5.0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 50,
                ),
                items: friends['friendResult'] != null
                    ? List<DropdownMenuItem<Map<String, dynamic>>>.from(
                        friends['friendResult']!.map((friend) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: friend,
                            child: Text(
                              friend['user_name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }),
                      )
                    : [],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Center(
              child: Wrap(
                spacing: 7.0,
                runSpacing: 1.0,
                children: selectFriends.map((member) {
                  return Chip(
                    label: Text(member['user_name']),
                    backgroundColor: Color(0xffffe7d6),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        selectFriends.remove(member);
                      });
                    },
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Color(0xffffe7d6), width: 1.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 20,
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
                        SizedBox(
                          height: 20,
                        ),
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
                                            InvitedTaskMemberScreen(task: plan),
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
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 16.0),
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xffff4700),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Color(0xffff4700), width: 2.0),
                      ),
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 17)),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addTaskInvitation();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 17.0, horizontal: 16.0),
                      backgroundColor: Color(0xffff4700),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text('Task Invite', style: TextStyle(fontSize: 17)),
                  ),
                )
              ],
            ),
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
