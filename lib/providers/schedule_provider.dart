import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:task_management/providers/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  List<Map<String, dynamic>> schedule = [];
  List<Map<String, dynamic>> get _schedule => List.unmodifiable(_schedule);

  final ScheduleService _scheduleService = ScheduleService();
  bool isAuthenticated = false;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> register(String username, String email, String password) async {
    try {
      await _scheduleService.register(username, email, password);
      isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      isAuthenticated = false;
      notifyListeners();
      throw e;
    }
  }

  Future<void> login(String email, String password) async{
    try{
      await _scheduleService.login(email, password);
      isAuthenticated = true;
      notifyListeners();
    }catch(e){
      isAuthenticated = false;
      notifyListeners();
      throw e;
    }
  }

  void addSchedule(DateTime date, String title, String description, String startTime, String endTime, List<String> members) {
    schedule.add({
      'date': date,
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'members': members,
    });
    notifyListeners(); // 상태 변경 알림
  }

  List<Map<String, dynamic>> getScheduleForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return schedule.where((item) => item['date'] == dateOnly).toList();
  }

  Future<void> loadDate() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('schedules');
    if (data != null) {
      final Map<String, dynamic> decoded = json.decode(data);
      schedule = decoded.entries.map((entry) {
        final date = DateTime.parse(entry.key);
        return {
          'date': date.toIso8601String(),
          'events': entry.value,
        };
      }).toList();
      notifyListeners();
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(
      schedule.map((item) {
        return {
          'date': item['date'],
          'events': item['events'],
        };
      }).toList(),
    );
    prefs.setString('schedules', encoded);
  }
}
