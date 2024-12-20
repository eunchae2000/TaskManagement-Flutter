import 'dart:convert';
import 'package:http/http.dart' as http;

class ScheduleService {
  final String baseUrl = 'http://10.0.2.2:8000';

  Future<void> test() async {
    final url = Uri.parse('http://10.0.2.2:8000/test');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Server is working: ${response.body}');
      } else {
        print('Failed to connect: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<List<dynamic>> fetchSchedules() async {
    final response = await http.get(Uri.parse('$baseUrl/schedules'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  Future<void> addSchedule(Map<String, dynamic> schedule) async {
    final response = await http.post(
      Uri.parse('$baseUrl/schedules'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(schedule),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add schedule');
    }
  }

  Future<void> register(
      String user_name, String user_email, String user_password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': user_name,
        'user_email': user_email,
        'user_password': user_password,
      }),
    );

    if (response.statusCode == 200) {
      print('Successfully');
    } else {
      throw 'Failed to register user: ${response.body}';
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_email': email,
        'user_password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }
}
