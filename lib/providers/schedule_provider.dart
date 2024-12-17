import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ScheduleProvider with ChangeNotifier{
  Map<DateTime, List<String>> _schedules = {};
  Map<DateTime, List<String>> get schedules => _schedules;

  void addSchedule(DateTime date, String schedule){
    if(_schedules[date] == null){
      _schedules[date] = [];
    }
    _schedules[date]?.add(schedule);
    saveData();
    notifyListeners();
  }

  List<String> getScheduleForDate(DateTime date){
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _schedules[dateOnly] ?? [];
  }

  Future<void> loadDate() async{
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('schedules');
    if(data != null){
      final Map<String, dynamic> decoded = json.decode(data);
      _schedules = decoded.map((key, value) =>
      MapEntry(DateTime.parse(key), List<String>.from(value)));
      notifyListeners();
    }
  }

  Future<void> saveData() async{
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_schedules.map((key, value) =>
        MapEntry(key.toIso8601String(), value)));
    prefs.setString('schedules', encoded);
  }
}