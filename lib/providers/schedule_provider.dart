import 'package:flutter/cupertino.dart';
import 'package:task_management/providers/schedule_service.dart';

class ScheduleProvider with ChangeNotifier {
  List<Map<String, dynamic>> schedule = [];

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

  List<Map<String, dynamic>> getScheduleForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return schedule.where((item) => item['date'] == dateOnly).toList();
  }
}
