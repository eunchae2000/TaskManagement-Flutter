import 'package:flutter/material.dart';
import 'package:task_management/providers/schedule_service.dart';

class SettingScreen extends StatefulWidget{
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting'),
      ),
    );
  }
}