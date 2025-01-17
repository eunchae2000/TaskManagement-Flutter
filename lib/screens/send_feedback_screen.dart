import 'package:flutter/material.dart';

class SendFeedbackScreen extends StatefulWidget {
  @override
  _SendFeedbackScreenState createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Feedback'),
      ),
      backgroundColor: Color(0xfffff4ec),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 16),
        child: Column(
          children: [
            Text(
              'Time is your most valuable resource. We are here to get this right for you.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              height: 30,
            ),
            TextField(
              decoration: customInputDecoration(
                hintText:
                    'How can Task improve for you. Ali? (If you\'re reporting a bug, how did it happen?)',
              ),
              style: TextStyle(fontSize: 15),
              maxLines: 7,
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffa76962),
                  foregroundColor: Color(0xfffff4ec),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                child: Text('Send feedback', style: TextStyle(fontSize: 15),),
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
    fillColor: Color(0xfff6e1de),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 15.0),
  );
}
