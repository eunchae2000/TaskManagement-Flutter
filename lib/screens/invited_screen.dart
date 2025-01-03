import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class InvitedScreen extends StatefulWidget{
  @override
  _InvitedScreenState createState() => _InvitedScreenState();
}

class _InvitedScreenState extends State<InvitedScreen>{
  final ScheduleService _friendService = ScheduleService();
  final TextEditingController _emailController = TextEditingController();

  String _message = '';

  void _sendRequest() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = 'Please provide a valid email';
      });
      return;
    }

    final response = await _friendService.sendFriendRequest(email);

    if (response['success'] == true) {
      setState(() {
        _message = 'Friend request sent successfully!';
      });
    } else {
      setState(() {
        _message = 'Error: ${response['error']}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Friend Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter Friend ID'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendRequest,
              child: Text('Send Friend Request'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}