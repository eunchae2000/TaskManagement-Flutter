import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> sentInvites = [];
  List<Map<String, dynamic>> receiveInvites = [];
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
    scheduleService.fetchSentInvite();
    _loadSentInvites();
    _loadReceivedInvites();
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading invites: $e')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading invites: $e')));
    }
  }

  Future<void> _responseToInvite(int friendId, String response) async {
    try {
      await scheduleService.respondToInvite(friendId, response);
      _loadReceivedInvites();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading invites: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: null,
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
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSentTab = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            isSentTab ? Color(0xffff4700) : Color(0xffffe7d6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'To',
                        style: TextStyle(
                          fontSize: 17,
                          color: isSentTab ? Colors.white : Color(0xffff4700),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSentTab = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            !isSentTab ? Color(0xffff4700) : Color(0xffffe7d6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'From',
                        style: TextStyle(
                          fontSize: 17,
                          color: !isSentTab ? Colors.white : Color(0xffff4700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    isSentTab ? _buildSentInvites() : _buildReceivedInvites(),
              ),
            ],
          ),
          receiveInvites.isEmpty
              ? Center(child: Text('No received invitations.'))
              : ListView.builder(
                  itemCount: receiveInvites.length,
                  itemBuilder: (context, index) {
                    var invite = receiveInvites[index];
                    return ListTile(
                      title: Text('Friend ID: ${invite['user_name']}'),
                      subtitle: Text('Status: ${invite['status']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () =>
                                _responseToInvite(invite['user_id'], 'accept'),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () =>
                                _responseToInvite(invite['user_id'], 'reject'),
                          ),
                        ],
                      ),
                    );
                  },
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
                leading: Icon(Icons.account_circle, size: 30),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(invite['user_name'] ?? 'Unknown'),
                    Text(
                      formatTimeAgo(invite['createdAt']),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w100,
                          color: Color(0xff686868)),
                    )
                  ],
                ),
                subtitle: Text(invite['status'] ?? 'No status'),
              );
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
                    size: 40,
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
                      Text('Status: ${invite['status']}'),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        ElevatedButton(
                          onPressed: () => _responseToInvite(invite['user_id'], 'accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.black12, width: 1.5),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, color: Colors.green),
                              SizedBox(width: 8),
                              Text("Accept"),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _responseToInvite(
                              invite['user_id'], 'reject'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.black12, width: 1.5),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close_rounded, color: Colors.red),
                              SizedBox(width: 8),
                              Text("Reject"),
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
