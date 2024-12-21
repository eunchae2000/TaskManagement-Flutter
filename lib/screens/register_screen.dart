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
  bool _obscureText = true;

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void register() async {
    try {
      if (usernameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        throw 'All fields are required';
      }
      final response = await scheduleService.register(usernameController.text,
          emailController.text, passwordController.text);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User registered successfully')),
        );
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to register: $e')),
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
            TextField(
                controller: usernameController,
                decoration: customInputDecoration(
                    labelText: 'Username', hintText: 'Gildong Hong',
                suffixIcon: Icon(Icons.person))),
            SizedBox(height: 15),
            TextField(
                controller: emailController,
                decoration: customInputDecoration(
                    labelText: 'Email', hintText: 'gildong@example.com',
                suffixIcon: Icon(Icons.email_outlined))),
            SizedBox(height: 15),
            TextField(
                controller: passwordController,
                decoration: customInputDecoration(
                  labelText: 'Password',
                  hintText: 'xxxxxxxx',
                  suffixIcon: Icon(Icons.visibility_off_outlined),
                ),
            obscureText: true,),
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
