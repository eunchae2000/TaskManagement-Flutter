import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  'Frequently Asked Questions(FAQ)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  'An FAQ or Frequently Asked Questions is a section to help users find information quickly without needing to contact customer support',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  'What is the ScoreSync?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(
                  'The ScoreSync provides real-time updates on scores, statistics, and news for your favorite sports and teams. \n Stay informed with instant notifications and in-depth analysis.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // ListView
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '1. Account and Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I create an account?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: To create an account, click the "Sign Up" button, enter your email and password, or sign up using a social media account.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: I forgot my password. How can I reset it?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: On the login screen, click "Forgot Password," enter your email, and follow the link sent to your email to reset your password.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I log in from multiple devices?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can log in with the same account across multiple devices. All your data is synchronized across devices via the cloud.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '2. Task Creation and Management',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I add a new task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: To add a task, click the "Add Task" button at the bottom of the screen, fill in the title, description, due date, and other details, and click "Save."'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: How can I edit a task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Tap on the task you want to edit, then click the "Edit" button to modify the title, description, dates, and other details.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I set task priority?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: When creating or editing a task, you can choose the priority as "High," "Medium," or "Low."'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: How can I mark a task as complete?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Once a task is finished, you can mark it as complete by selecting the "Mark as Complete" option, and it will be moved to the completed tasks section.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '3. Notifications and Deadlines',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I receive notifications for task deadlines?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can set a due date for tasks and enable notifications so that you will be reminded before the deadline.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I change a task\'s due date?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can modify the due date of a task anytime by selecting "Edit" and changing the due date.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I turn off task notifications?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: You can turn off notifications for a specific task during task editing, or disable all task notifications in the app settings.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '4. Team Collaboration and Sharing',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I share tasks with team members?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, after creating a task, you can click the "Share" button to share the task with team members who can view, edit, or mark it as complete.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I add members to a task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: While creating or editing a task, you can use the "Assign Members" option to add specific team members to the task.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: How can I assign tasks to different team members?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: During task creation or editing, you can assign tasks to different team members by selecting their names under the "Assign Team" section.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '5. File Attachments and Links',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I attach files to a task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can attach files such as PDFs, images, and documents by clicking the "Attach File" button during task creation or editing.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I add links to a task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can add links in the task description, and they will be clickable once saved.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '6. Search and Filters',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I search for a task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: You can use the search bar at the top of the app to search for tasks by title or description. Tasks can also be filtered by date, priority, and status.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I filter my tasks?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can filter tasks based on criteria like priority, status (in-progress, completed, pending), and due date using the "Filter" button.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '7. Sync and Backup',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: Are tasks synced automatically across devices?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, tasks are automatically synced with the cloud. Any changes made on one device will be reflected on all other devices logged into your account.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I back up my tasks?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, you can back up your tasks using the app’s backup feature to ensure your data is securely stored in the cloud.'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      '8. Other',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Colors.grey),
                  ExpansionTile(
                    title: Text(
                      'Q: How do I delete a task?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: To delete a task, select the task, click the "Delete" button, and confirm the deletion. Please note, deleted tasks cannot be recovered.'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Q: Can I use the app in other languages?',
                      style: TextStyle(
                          color: Color(0xffff4700),
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                            'A: Yes, the app supports multiple languages. You can change the language in the settings under "Language Preferences."'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
