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

  final ScheduleService scheduleService = ScheduleService();

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

  Future<void> _loadSentInvites() async{
    try{
      List<Map<String, dynamic>> invites = await scheduleService.fetchSentInvite();
      setState(() {
        sentInvites = invites;
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invites: $e')));
    }
  }

  Future<void> _loadReceivedInvites() async{
    try{
      List<Map<String, dynamic>> invites =
      await scheduleService.fetchReceivedInvites();
      setState(() {
        receiveInvites = invites;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invites: $e')));
    }
  }

  Future<void> _responseToInvite(int friendId, String response) async{
    try{
      await scheduleService.respondToInvite(friendId, response);
      _loadReceivedInvites();
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invites: $e')));
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
          FutureBuilder<List<Map<String, dynamic>>>(
            future: scheduleService.fetchSentInvite(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data != null) {
                final sentInvites = snapshot.data!;

                return ListView.builder(
                  itemCount: sentInvites.length,
                  itemBuilder: (context, index) {
                    final invite = sentInvites[index];
                    return ListTile(
                      leading: Icon(Icons.person, size: 30),
                      title: Text(invite['user_name'] ?? 'Unknown'),
                      subtitle: Text(invite['status'] ?? 'No status'),
                    );
                  },
                );
              } else {
                return Center(child: Text('No invites found.'));
              }
            },
          ),

          // Invites Tab
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
