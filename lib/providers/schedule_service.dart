import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? user_id = prefs.getString('user_id');

    if (token == null || user_id == null) {
      return {
        'success': false,
        'message': 'No token found. Please log in again.',
      };
    }

    final url = Uri.parse('$baseUrl/post');

    final Map<String, dynamic> requestData = {
      'task_title': task_title,
      'task_description': task_description,
      'task_startTime': task_startTime,
      'task_endTime': task_endTime,
      'task_dateTime': task_dateTime,
      'categorie_id': categorie_id,
      'user_id': user_id,
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
        print('Task added successfully');
        return {
          'success': true,
          'message': 'Task added successfully',
        };
      } else {
        print('Failed to add task: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to add task: ${response.body}',
        };
      }
    } catch (error) {
      print('Error during task addition: $error');
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
    String? user_id = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/task',),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': user_id,
        'task_dateTime': selectDay,
        'token': token,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("responseData $responseData");

      if (responseData is List) {
        final data = responseData;
        print("data $data");
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Invalid data format: Expected a list');
      }

    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
