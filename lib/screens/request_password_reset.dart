import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class RequestPasswordResetScreen extends StatefulWidget {
  @override
  _RequestPasswordResetScreenState createState() =>
      _RequestPasswordResetScreenState();
}

class _RequestPasswordResetScreenState
    extends State<RequestPasswordResetScreen> {
  ScheduleService _scheduleService = ScheduleService();
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> handleRequestPasswordReset() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _scheduleService.requestPasswordReset(emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호 재설정 이메일이 전송되었습니다.")),
      );
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
      appBar: AppBar(title: null),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: customInputDecoration(hintText: "이메일", suffixIcon: Icon(Icons.email_rounded)),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: handleRequestPasswordReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffa76962),
                        foregroundColor: Color(0xfffff4ec),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 0,
                      ),
                      child: Text("Request password reset"),
                    ),
                  )
          ],
        ),
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
