import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class InvitedScreen extends StatefulWidget {
  @override
  _InvitedScreenState createState() => _InvitedScreenState();
}

class _InvitedScreenState extends State<InvitedScreen> {
  final ScheduleService _friendService = ScheduleService();
  final TextEditingController _emailController = TextEditingController();
  List<dynamic> _searchResults = [];

  bool isSentTab = true;

  String _message = '';
  final Map<String, String> _requestStatusMap = {};
  List<dynamic> status = [];

  void _searchEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _message = 'Please provide a valid email';
      });
      return;
    }
    final response = await _friendService.fetchSearchEmail(email);

    if (response['success'] == true && response['data'] is List) {
      setState(() {
        _searchResults = response['data'];
        _message = '';
        status =
            (response['existing'] is List && response['existing']!.isNotEmpty)
                ? response['existing']
                : [];
      });
    } else {
      setState(() {
        _searchResults = [];
        _message = response['error'] ?? 'An error occurred.';
      });
    }
  }

  void _sendRequest(String email) async {
    if (email.isEmpty) {
      setState(() {
        _message = 'Please provide an email address.';
      });
      return;
    }

    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _message = 'The email format is invalid. Please check and try again.';
      });
      return;
    }

    final response = await _friendService.sendFriendRequest(email);

    if (response['success'] == true) {
      setState(() {
        _message = 'Friend request sent successfully!';
        if (_requestStatusMap[email] == '') {
          _requestStatusMap[email] = 'sent';
        }
      });
    } else {
      setState(() {
        if (response['error'] == 'Email not found') {
          _message = 'The email address was not found.';
        } else if (response['error'] == 'Friend request already sent') {
          _message = 'You have already sent a friend request to this email.';
          _requestStatusMap[email] = 'alreadySent';
        } else if (response['error'] == 'Unauthorized') {
          _message = 'You do not have permission to send a friend request.';
        } else {
          _message = 'Error: ${response['error']}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Column(
              children: [
                IntrinsicWidth(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            backgroundColor: isSentTab
                                ? Color(0xff637899)
                                : Color(0xffddf2ff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Invite Members',
                            style: TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 17,
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
                            backgroundColor: isSentTab
                                ? Color(0xffddf2ff)
                                : Color(0xff637899),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Task Invite',
                            style: TextStyle(
                              letterSpacing: 1.0,
                              fontSize: 17,
                              color: !isSentTab
                                  ? Color(0xffddf2ff)
                                  : Color(0xff637899),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: isSentTab ? _buildRequestMember() : _buildRequestTask(),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestMember() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: customInputDecoration(
                 hintText: 'Enter User Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _searchEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffddf2ff),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Search User",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff637899),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.person_search,
                  color: Color(0xff637899),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (_searchResults.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.list_rounded,
                  size: 35,
                  color: Color(0xff637899),
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'List',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xff637899),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final email = _searchResults[index]['user_email'] ?? '';
                  final requestStatus =
                      (status.isNotEmpty && index < status.length)
                          ? status[index]['status'] ?? ''
                          : '';

                  return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    leading: Icon(
                      Icons.account_circle_rounded,
                      size: 40,
                      color: Color(0xff637899),
                    ),
                    title: Text(
                      email,
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: Text(
                      _searchResults[index]['user_name']
                    ),
                    trailing: SizedBox(
                      width: 90,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: requestStatus == 'sent' ||
                                requestStatus == 'pending'
                            ? null
                            : () {
                                _sendRequest(email);
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          backgroundColor: requestStatus == 'sent' ||
                                  requestStatus == 'pending'
                              ? Colors.grey
                              : Color(0xffff4700),
                          foregroundColor: requestStatus == 'sent' ||
                                  requestStatus == 'pending'
                              ? Color(0xffff4700)
                              : Color(0xffffe7d6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              requestStatus == 'sent' ||
                                      requestStatus == 'pending'
                                  ? 'sent'
                                  : 'send',
                              style: TextStyle(
                                fontSize: 13,
                                color: requestStatus == 'sent' ||
                                        requestStatus == 'pending'
                                    ? Colors.grey
                                    : Color(0xffffe7d6),
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              requestStatus == 'sent' ||
                                      requestStatus == 'pending'
                                  ? Icons.pending_rounded
                                  : Icons.send_rounded,
                              color: requestStatus == 'sent' ||
                                      requestStatus == 'pending'
                                  ? Colors.grey
                                  : Color(0xffffe7d6),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else if (_message.isNotEmpty) ...[
            Text(
              _message,
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestTask() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: customInputDecoration( hintText: 'Enter Friend ID'),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Send Task Request'),
          ),
          SizedBox(height: 20),
          Text(
            _message,
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

InputDecoration customInputDecoration({
  required String hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
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
