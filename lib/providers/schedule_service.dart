import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleService {
  final String baseUrl = 'http://10.0.2.2:8000';

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

  Future<Map<String, dynamic>> register(
      String userName, String userEmail, String userPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': userName,
        'user_email': userEmail,
        'user_password': userPassword,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Unknown error',
      };
    } else {
      throw {
        'success': false,
        'message': 'Server error: ${response.statusCode}, ${response.body}',
      };
    }
  }

  Future<Map<String, dynamic>> login(
      String userEmail, String userPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_email': userEmail,
        'user_password': userPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final userId = data['user_id'];
      final token = data['token'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId.toString());
      await prefs.setString('token', token);
      return {
        'success': true,
        'message': data['message'] ?? 'Login successful',
      };
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data is List) {
            return data.map((item) => Map<String, dynamic>.from(item)).toList();
          } else {
            throw Exception('Invalid data format: Expected a list');
          }
        } else {
          throw Exception('API error: ${responseData['message']}');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  Future<Map<String, dynamic>> addTask(
      String taskTitle,
      String taskDescription,
      String taskStartTime,
      String taskEndTime,
      String taskDateTime,
      int categorieId,
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    if (token == null || userId == null) {
      return {
        'success': false,
        'message': 'No token found. Please log in again.',
      };
    }

    final url = Uri.parse('$baseUrl/post');

    final Map<String, dynamic> requestData = {
      'task_title': taskTitle,
      'task_description': taskDescription,
      'task_startTime': taskStartTime,
      'task_endTime': taskEndTime,
      'task_dateTime': taskDateTime,
      'categorie_id': categorieId,
      'user_id': userId,
      'token': token,
    };

    try {
      List<Map<String, dynamic>> categories = await fetchCategories();

      if (categories.isEmpty) {
        return {
          'success': false,
          'message': 'No categories found.',
        };
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData),
      );
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Task added successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to add task: ${response.body}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }


  Future<List<Map<String, dynamic>>> fetchTask( String selectDay
      )async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/task',),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'task_dateTime': selectDay,
        'token': token,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData is List) {
        final data = responseData;
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Invalid data format: Expected a list');
      }

    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
