import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ScheduleService scheduleService = ScheduleService();
  bool isLoading = false;

  void register() async {
    try {
      if (usernameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        throw 'All fields are required';
      }
      final response = await scheduleService.register(usernameController.text,
          emailController.text, passwordController.text);

      if (mounted) {
        if (response['success'] == true) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        }
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
                'Create an\nAccount',
                style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff2f4858)),
              ),
            ),
            SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5),
                  child: Text('user name', style: TextStyle(fontSize: 16),),
                ),
                TextField(
                    controller: usernameController,
                    decoration: customInputDecoration(
                        hintText: 'Gildong Hong',
                        suffixIcon: Icon(Icons.person))),
              ],
            ),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5),
                  child: Text('email', style: TextStyle(fontSize: 16),),
                ),
                TextField(
                    controller: emailController,
                    decoration: customInputDecoration(
                        hintText: 'gildong@example.com',
                        suffixIcon: Icon(Icons.email_outlined))),
              ],
            ),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5),
                  child: Text('password', style: TextStyle(fontSize: 16),),
                ),
                TextField(
                  controller: passwordController,
                  decoration: customInputDecoration(
                    hintText: 'xxxxxxxx',
                    suffixIcon: Icon(Icons.visibility_off_outlined),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: isLoading ? null : register,
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
                      'Register',
                      style: TextStyle(color: Color(0xFFfff6f0), fontSize: 20),
                    ),
            ),
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
