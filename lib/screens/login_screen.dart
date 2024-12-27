import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/calendar_screen.dart';
import 'package:task_management/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final scheduleService = ScheduleService();

  void login() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw 'Email ans password are required';
      }
      final response = await scheduleService.login(
          emailController.text, passwordController.text);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User login successfully')),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CalendarScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            response['message'] ?? 'Failed to login',
          )),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hello,\nthere!',
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2f4858)),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: customInputDecoration(
                    labelText: 'Email',
                    hintText: 'gildong@example.com',
                    suffixIcon: Icon(Icons.email_outlined)),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: customInputDecoration(
                    labelText: 'Password',
                    hintText: 'xxxxxxxx',
                    suffixIcon: Icon(Icons.visibility_off_outlined)),
                obscureText: true,
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    text: 'Recovery Password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = navigateToSignUp,
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Color(0xFFFF4700),
                ),
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Log in',
                        style:
                            TextStyle(color: Color(0xFFfff6f0), fontSize: 20),
                      ),
              ),
              SizedBox(height: 50),
              RichText(
                text: TextSpan(
                  text: 'Not a member? ',
                  style: TextStyle(color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Register now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = navigateToSignUp, // 클릭 시 URL 열기
                    ),
                  ],
                ),
              ),
            ],
          )),
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
