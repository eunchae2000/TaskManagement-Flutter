import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  ResetPasswordScreen({required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  ScheduleService _scheduleService = ScheduleService();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> handleResetPassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _scheduleService.resetPassword(widget.token, passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("오류: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("비밀번호 재설정")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "새 비밀번호"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: handleResetPassword,
              child: Text("비밀번호 재설정"),
            ),
          ],
        ),
      ),
    );
  }
}
