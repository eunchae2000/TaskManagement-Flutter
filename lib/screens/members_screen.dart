import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class MembersScreen extends StatefulWidget {
  @override
  _MemberScreenState createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MembersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final ScheduleService scheduleService = ScheduleService();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filterFriends = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFriends();
  }

  Future<List<Map<String, dynamic>>> _loadFriends() async {
    try {
      List<Map<String, dynamic>> friendList =
          await scheduleService.friendsList();
      setState(() {
        friends = friendList;
        filterFriends = friendList;
      });
      return friendList;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Friend List Failed: $e')));
      }
      return [];
    }
  }

  void _filterFriends(String query) {
    if (query.isEmpty) {
      setState(() {
        filterFriends = friends;
      });
    } else {
      scheduleService.searchFriends(query).then((friends) {
        setState(() {
          filterFriends = friends;
        });
      }).catchError((e) {
        setState(() {
          filterFriends = [];
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchMembers() async {
    await Future.delayed(Duration(seconds: 2));
    return ['Member 1', 'Member 2', 'Member 3'];
  }

  Future<List<String>> fetchInvites() async {
    await Future.delayed(Duration(seconds: 2));
    return ['Invite 1', 'Invite 2', 'Invite 3'];
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
              Tab(text: 'Invites'),
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
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterFriends,
                  decoration: customInputDecoration(
                    hintText: 'Search Members',
                    labelText: 'Search Members',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color(0xffff4700),
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: filterFriends.isEmpty
                      ? Center(child: Text('No Member Found.'))
                      : ListView.builder(
                          itemCount: filterFriends.length,
                          itemBuilder: (context, index) {
                            var friend = filterFriends[index];
                            return ListTile(
                              leading: Icon(
                                Icons.account_circle_rounded,
                                size: 30,
                                color: Color(0xffff4700),
                              ),
                              title: Text(friend['user_name'] ?? 'Unknown'),
                              subtitle:
                                  Text(friend['user_email'] ?? 'No email'),
                            );
                          },
                        ))
            ],
          ),
          // Invites Tab
          FutureBuilder<List<String>>(
            future: fetchInvites(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index]),
                    );
                  },
                );
              }
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
