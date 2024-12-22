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

  Future<Map<String, dynamic>> register(
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
      String user_email, String user_password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_email': user_email,
        'user_password': user_password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'success': true,
        'message': responseData['message'],
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
      print('Error in fetchCategories: $error');
      throw Exception('Failed to fetch categories: $error');
    }
  }

  Future<Map<String, dynamic>> addTask(
      String task_title,
      String task_description,
      String task_startTime,
      String task_endTime,
      String task_dateTime,
      int categorie_id,
      int user_id) async {
    final url = Uri.parse('$baseUrl/post');

    final Map<String, dynamic> requestData = {
      'task_title': task_title,
      'task_description': task_description,
      'task_startTime': task_startTime,
      'task_endTime': task_endTime,
      'task_dateTime': task_dateTime,
      'categorie_id': categorie_id,
      'user_id': user_id,
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
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? 'Task added successfully',
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Server error: ${response.statusCode}',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }
}
