import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:task_management/providers/schedule_service.dart';
import 'package:task_management/screens/setting_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  EditProfileScreen({required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ScheduleService _scheduleService = ScheduleService();

  late TextEditingController _usernameController;
  late TextEditingController _userEmailController;
  late TextEditingController _userPhoneController;
  File? _selectedImage;
  String? _selectedGender;
  DateTime? _selectedBirthday;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user['user_name']);
    _userEmailController =
        TextEditingController(text: widget.user['user_email']);
    _userPhoneController =
        TextEditingController(text: widget.user['user_phone']);
    _selectedImage = widget.user['user_profile'] != null
        ? File(widget.user['user_profile'])
        : null;
    _selectedGender = widget.user['user_gender'];
    print(widget.user['user_birthday']);
    _selectedBirthday = widget.user['user_birthday'] != null
        ? DateTime.tryParse(widget.user['user_birthday'])
        : null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  String formatDateTimeForMySQL(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Future<void> _updateProfile() async {
    final updatedImage = _selectedImage ?? widget.user['user_profile'];

    String formattedBirthday = _selectedBirthday != null
        ? formatDateTimeForMySQL(_selectedBirthday!)
        : '';

    final response = await _scheduleService.editUser(
      _usernameController.text,
      _userEmailController.text,
      _userPhoneController.text,
      updatedImage,
      _selectedGender ?? '',
      formattedBirthday,
    );

    if (response['success']) {
      if (!mounted) return;
    } else {
      if (!mounted) return;
    }
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthday) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () {
                _updateProfile();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'Complete',
                    style: TextStyle(color: Colors.black, fontSize: 17),
                  ),
                  SizedBox(width: 10,),
                  Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: Color(0xffff4700),
                  ),
                ],
              ))
        ],
      )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Color(0x20ff4700),
                            child: _selectedImage != null
                                ? ClipOval(child: Image.file(_selectedImage!))
                                : widget.user['user_profile'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                            widget.user['user_profile']))
                                    : Icon(Icons.person_rounded,
                                        size: 50, color: Colors.white),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(50)),
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 15,
                                    color: Color(0xffff4700),
                                  ),
                                ),
                              )),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.email_rounded),
                      SizedBox(width: 10,),
                      Text(
                        '${widget.user['user_email']}',
                        style: TextStyle(fontSize: 17),
                      )
                    ],
                  )

                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Color(0xff637899),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Name',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _usernameController,
                    decoration: customInputDecoration(hintText: 'User Name'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Email',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _userEmailController,
                    decoration: customInputDecoration(hintText: 'User Email'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Phone Number',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _userPhoneController,
                    decoration: customInputDecoration(hintText: 'User Phone'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Gender',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: customInputDecoration(hintText: "Gender"),
                    items: ['Male', 'Female', 'Other']
                        .map((gender) => DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? "Gender is required" : null,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Birth of day',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => _selectBirthday(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: customInputDecoration(
                          hintText: _selectedBirthday != null
                              ? "${_selectedBirthday!.year}-${_selectedBirthday!.month}-${_selectedBirthday!.day}"
                              : "Select your birthday",
                        ),
                        validator: (value) => _selectedBirthday == null
                            ? "Birthday is required"
                            : null,
                      ),
                    ),
                  ),
                ],
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
    fillColor: Color(0xfffff7f2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 17.0, horizontal: 16.0),
  );
}
