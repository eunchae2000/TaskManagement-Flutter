import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/register_screen.dart';
import 'package:task_management/main.dart';
import 'package:task_management/screens/request_password_reset.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Map<String, dynamic>? userData;

  final scheduleService = ScheduleService();

  void _googleLogin() async {
    try {
      final response = await scheduleService.loginWithGoogle();
      if (response != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Login Successful"),
            content: Text("Welcome, ${response['name']}!"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        print('failed login');
      }
    } catch (e) {
      throw Exception(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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

      if (mounted) {
        if (response['success'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
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

  void navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void navigateToRequestPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RequestPasswordResetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hello,\nthere!',
                  style: TextStyle(
                      fontSize: 50,
                      fontFamily: 'NunitoExtraBold',
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2f4858)),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: customInputDecoration(
                    hintText: 'gildong@example.com',
                    suffixIcon: Icon(Icons.email_outlined)),
              ),
              SizedBox(height: 15),
              TextField(
                controller: passwordController,
                decoration: customInputDecoration(
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
                      fontFamily: 'NunitoSemiBold',
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = navigateToRequestPassword,
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
              IconButton(
                  onPressed: _googleLogin,
                  icon: Icon(Icons.g_mobiledata_rounded)),
              SizedBox(height: 50),
              RichText(
                text: TextSpan(
                  text: 'Not a member? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'NunitoBold',
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Register now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = navigateToSignUp,
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
