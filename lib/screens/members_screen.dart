import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/invited_screen.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> sentInvites = [];
  List<Map<String, dynamic>> receiveInvites = [];

  List<Map<String, dynamic>> sentTask = [];
  List<Map<String, dynamic>> receiveTask = [];

  bool isSentTab = true;

  final ScheduleService scheduleService = ScheduleService();

  String formatTimeAgo(String invitedCreateAt) {
    DateTime invitedDateTime = DateTime.parse(invitedCreateAt);
    DateTime now = DateTime.now();
    Duration difference = now.difference(invitedDateTime);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else {
        return '${difference.inHours}h';
      }
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${invitedDateTime.year}-${invitedDateTime.month}-${invitedDateTime.day}';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSentInvites();
    _loadReceivedInvites();
    _loadSentTask();
    _loadReceivedTask();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSentInvites() async {
    try {
      List<Map<String, dynamic>> invites =
          await scheduleService.fetchSentInvite();
      setState(() {
        sentInvites = invites;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _loadReceivedInvites() async {
    try {
      List<Map<String, dynamic>> invites =
          await scheduleService.fetchReceivedInvites();
      setState(() {
        receiveInvites = invites;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _responseToInvite(int friendId, String response) async {
    try {
      await scheduleService.respondToInvite(friendId, response);
      _loadReceivedInvites();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _loadSentTask() async {
    try {
      List<Map<String, dynamic>> invites =
          await scheduleService.fetchSentTask();
      setState(() {
        sentTask = invites;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _loadReceivedTask() async {
    try {
      List<Map<String, dynamic>> invites =
          await scheduleService.fetchReceivedTask();
      setState(() {
        receiveTask = invites;
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> _responseToTask(
      int friendId, int taskId, String response) async {
    try {
      await scheduleService.respondToTask(friendId, taskId, response);
      _loadReceivedTask();
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InvitedScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(80, 35),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                backgroundColor: Color(0xff637899),
                foregroundColor: Color(0xffddf2ff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xffddf2ff),
                  ),
                  SizedBox(width: 8),
                  Text("Invite Member"),
                ],
              ),
            )
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Members'),
            Tab(text: 'Project'),
          ],
          indicatorColor: Color(0xffff4700),
          labelColor: Color(0xffff4700),
          unselectedLabelColor: Color(0xff637899),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              SizedBox(height: 10,),
              IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Color(0xffddf2ff),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSentTab = true;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              isSentTab ? Color(0xff637899) : Color(0xffddf2ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Request sent',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 13,
                            color: isSentTab
                                ? Color(0xffddf2ff)
                                : Color(0xff637899),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSentTab = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              isSentTab ? Color(0xffddf2ff) : Color(0xff637899),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Request receive',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 13,
                            color: !isSentTab
                                ? Color(0xffddf2ff)
                                : Color(0xff637899),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child:
                    isSentTab ? _buildSentInvites() : _buildReceivedInvites(),
              ),
            ],
          ),

          // Project tab
          Column(
            children: [
              SizedBox(height: 10,),
              IntrinsicWidth(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Color(0xffddf2ff),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSentTab = true;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                          isSentTab ? Color(0xff637899) : Color(0xffddf2ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Request sent',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 13,
                            color: isSentTab
                                ? Color(0xffddf2ff)
                                : Color(0xff637899),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSentTab = false;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                          isSentTab ? Color(0xffddf2ff) : Color(0xff637899),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Request receive',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 13,
                            color: !isSentTab
                                ? Color(0xffddf2ff)
                                : Color(0xff637899),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: isSentTab ? _buildSentTask() : _buildReceivedTask(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentInvites() {
    return sentInvites.isEmpty
        ? Center(child: Text('No sent invitations.'))
        : ListView.builder(
            itemCount: sentInvites.length,
            itemBuilder: (context, index) {
              final invite = sentInvites[index];
              return ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Color(0xffff4700),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(invite['user_name'] ?? 'Unknown'),
                      Text(
                        formatTimeAgo(invite['createdAt']),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w100,
                            color: Color(0xff686868)),
                      )
                    ],
                  ),
                  subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(invite['user_email']),
                        Container(
                          padding: EdgeInsets.only(
                              left: 7, right: 7, top: 3, bottom: 3),
                          decoration: BoxDecoration(
                            color: Color(0xffddf2ff),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            invite['status'] ?? 'No status',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      ]));
            },
          );
  }

  Widget _buildReceivedInvites() {
    return receiveInvites.isEmpty
        ? Center(child: Text('No received invitations.'))
        : ListView.builder(
            itemCount: receiveInvites.length,
            itemBuilder: (context, index) {
              var invite = receiveInvites[index];
              return ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Color(0xffff4700),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Friend ID: ${invite['user_name']}'),
                      Text(
                        formatTimeAgo(invite['createdAt']),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w100,
                            color: Color(0xff686868)),
                      )
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${invite['user_email']}'),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        ElevatedButton(
                          onPressed: () =>
                              _responseToInvite(invite['user_id'], 'accept'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(80, 35),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            backgroundColor: Color(0xffddf2ff),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Accept",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () =>
                              _responseToInvite(invite['user_id'], 'reject'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(80, 35),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                  color: Color(0xffddf2ff), width: 1.5),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Reject",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ));
            },
          );
  }

  Widget _buildSentTask() {
    return sentTask.isEmpty
        ? Center(child: Text('No sent Task invitations.'))
        : ListView.builder(
            itemCount: sentTask.length,
            itemBuilder: (context, index) {
              final invite = sentTask[index];
              return ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Color(0xffff4700),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(invite['user_name'] ?? 'Unknown'),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '[${invite['task_title'] ?? ''}]',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xff8aade1)),
                          )
                        ],
                      ),
                      Text(
                        formatTimeAgo(invite['created_at']),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w100,
                            color: Color(0xff686868)),
                      )
                    ],
                  ),
                  subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(invite['user_email']),
                        Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 3, bottom: 3),
                          decoration: BoxDecoration(
                            color: Color(0xffddf2ff),
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            invite['status'] ?? 'No status',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      ]));
            },
          );
  }

  Widget _buildReceivedTask() {
    return receiveTask.isEmpty
        ? Center(child: Text('No received Task invitations.'))
        : ListView.builder(
            itemCount: receiveTask.length,
            itemBuilder: (context, index) {
              var invite = receiveTask[index];
              return ListTile(
                  leading: Icon(
                    Icons.account_circle,
                    size: 50,
                    color: Color(0xffff4700),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${invite['user_name']}'),
                      Text(
                        formatTimeAgo(invite['created_at']),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w100,
                            color: Color(0xff686868)),
                      )
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Task title: ${invite['task_title']}'),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        ElevatedButton(
                          onPressed: () => _responseToTask(
                              invite['user_user_id'],
                              invite['task_task_id'],
                              'accept'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(80, 35),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            backgroundColor: Color(0xffddf2ff),
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                color: Colors.green,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Accept",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _responseToTask(
                              invite['user_user_id'],
                              invite['task_task_id'],
                              'reject'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(80, 35),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                  color: Color(0xffddf2ff), width: 1.5),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Reject",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ));
            },
          );
  }
}

InputDecoration customInputDecoration({
  required String labelText,
  required String hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Color(0xffffe7d6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
