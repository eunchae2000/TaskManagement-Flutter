import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSentTab = true;

  final ScheduleService scheduleService = ScheduleService();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filterFriends = [];
  final TextEditingController _searchMember = TextEditingController();

  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> filterTasks = [];
  final TextEditingController _searchTask = TextEditingController();
  String searchQuery = '';

  List<dynamic> _tasks = [];
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      await _fetchTasks(); // 날짜 선택 후 태스크를 다시 가져오기
    }
  }

  // 선택된 날짜에 해당하는 태스크를 가져오는 메서드
  Future<void> _fetchTasks() async {
    if (_selectedDate == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    try {
      final tasks = await ScheduleService().fetchTasksByDate(formattedDate);
      setState(() {
        _tasks = tasks; // _tasks를 새 데이터로 업데이트
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFriends();
  }

  void searchTasks(String query) async {
    if (query.isEmpty) {
      setState(() {
        filterTasks = tasks;
      });
    } else {
      scheduleService.searchTasks(query).then((task) {
        setState(() {
          filterTasks = task;
        });
      }).catchError((e) {
        setState(() {
          filterTasks = [];
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      });
    }
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
    _searchMember.dispose();
    _searchTask.dispose();
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
              Tab(text: 'Task'),
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
                  controller: _searchMember,
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
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: TextField(
                  controller: _searchTask,
                  onChanged: searchTasks,
                  decoration: customInputDecoration(
                    hintText: 'Search Tasks',
                    labelText: 'Search Task',
                    suffixIcon: Icon(
                      Icons.search,
                      color: Color(0xffff4700),
                    ),
                  ),
                ),
              ),
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
                        'All',
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
                        'Date',
                        style: TextStyle(
                          fontSize: 17,
                          color: !isSentTab ? Colors.white : Color(0xffff4700),
                        ),
                      ),
                    ),
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: Text('select date')))
                  ],
                ),
              ),
              Expanded(
                child: isSentTab ? _buildTask() : _buildDate(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTask() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (filterTasks.isEmpty)
                  Center(child: Text('No task found'))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filterTasks.length,
                    itemBuilder: (context, index) {
                      final task = filterTasks[index];
                      final List<String> participantNames =
                          (task['participant_name'] ?? '').split(',');

                      return Container(
                        margin:
                            EdgeInsets.only(left: 10, right: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: Color(0xffddf2ff),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          title: Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xfffff4ec),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(task['task_dateTime']),
                                ),
                                Container(
                                  child: Text(task['task_title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text('${task['task_description']}'),
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 5,
                                children: [
                                  if (participantNames.length > 1)
                                    Text(
                                        '${participantNames[0]}   +${participantNames.length - 1}'),
                                  if (participantNames.length == 1)
                                    Text(participantNames[0]),
                                  if (participantNames.isEmpty)
                                    Text('No participants'),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(
                                  task: task,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDate() {
    return Expanded(
      child: _tasks.isEmpty
          ? Center(
              child: Text(
                'No tasks for selected date',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final participantNames =
                    (task['participant_name'] ?? '').split(',');

                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(task['task_title']),
                    subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: Text('${task['task_description']}'),
                      ),
                      Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: [
                          if (participantNames.length > 1)
                            Text(
                                '${participantNames[0]}   +${participantNames.length - 1}'),
                          if (participantNames.length == 1)
                            Text(participantNames[0]),
                          if (participantNames.isEmpty)
                            Text('No participants'),
                        ],
                      ),
                    ],
                  ),
                  ),
                );
              },
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
