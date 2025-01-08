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

  Future<List<Map<String, dynamic>>> friendsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    try {
      final response = await http.get(Uri.parse('$baseUrl/friends/$userId'));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          var friendsData = responseData['data'][0];

          List<Map<String, dynamic>> friendsList = [];
          friendsData.forEach((key, value) {
            if (key != 'user_profile') {
              friendsList.add(Map<String, dynamic>.from(value));
            }
          });

          return friendsList;
        } else {
          throw Exception('API error: ${responseData['message']}');
        }
      } else {
        throw Exception('fetch friend list failed.');
      }
    } catch (e) {
      throw Exception('에러 발생: $e');
    }
  }

  Future<Map<String, dynamic>> addTask(
    List<String> friendNames,
    String taskTitle,
    String taskDescription,
    String taskStartTime,
    String taskEndTime,
    String taskDateTime,
    int categoryId,
      List<Map<String, String>> plans
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
      'categorie_id': categoryId,
      'friend_name': friendNames,
      'user_id': userId,
      'plans': plans,
      'token': token,
    };

    try {
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

  Future<Map<String, dynamic>> updateTask(
      int taskId,
      String taskTitle,
      String taskDescription,
      String taskStartTime,
      String taskEndTime,
      String taskDateTime,
      int categorieId,
      List<String> friendNames,
      List<Map<String, dynamic>> plans,
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$taskId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'task_title': taskTitle,
          'task_description': taskDescription,
          'task_startTime': taskStartTime,
          'task_endTime': taskEndTime,
          'task_dateTime': taskDateTime,
          'categorie_id': categorieId,
          'user_id': userId,
          'friend_name': friendNames,
          'plans': plans,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to update task');
      }
    } catch (e) {
      throw Exception('Error updating task: $e');
    }
  }

  Future<Map<String, dynamic>> getParticipant(int taskId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/task/$taskId/participants'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to fetch participants and plans');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTask(String selectDay) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse(
        '$baseUrl/task',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'task_dateTime': selectDay,
        'token': token,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw Exception(
              'Invalid data format: Expected a list inside the "data" key');
        }
      } else {
        throw Exception('Invalid response format: "data" key not found');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> searchFriends(String query) async {
    final response =
        await http.get(Uri.parse('$baseUrl/searchFriends?query=$query'));
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> friends =
          List<Map<String, dynamic>>.from(json.decode(response.body));
      return friends;
    } else {
      throw Exception('Failed to load friends');
    }
  }

  Future<List<dynamic>> fetchNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
          return data['data'];
        }
        if (data is List<dynamic>) {
          return data;
        }
        throw Exception("Json structure");
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Error fetching notifications');
    }
  }

  Future<Map<String, dynamic>> fetchSearchEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/search-member'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'user_id': userId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch email search results');
    }
  }

  Future<Map<String, dynamic>> sendFriendRequest(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/friend-request'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
        'user_email': email,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      return {
        'success': false,
        'error': json.decode(response.body)['error'] ?? 'Unknown error',
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchSentInvite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sentRequest/$userId'),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is List &&
            responseBody.isNotEmpty &&
            responseBody[0] is List) {
          return (responseBody[0] as List).map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              throw Exception('Unexpected item structure in API response');
            }
          }).toList();
        } else {
          throw Exception('Unexpected API response structure');
        }
      } else {
        throw Exception('Failed to fetch sent invites');
      }
    } catch (e) {
      throw Exception('Error fetching sent invites: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReceivedInvites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receiveRequest/$userId'),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is List &&
            responseBody.isNotEmpty &&
            responseBody[0] is List) {
          return (responseBody[0] as List).map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              throw Exception('Unexpected item structure in API response');
            }
          }).toList();
        } else {
          throw Exception('Unexpected API response structure');
        }
      } else {
        throw Exception('Failed to fetch sent invites');
      }
    } catch (e) {
      throw Exception('Error fetching received invites: $e');
    }
  }

  Future<void> respondToInvite(int friendId, String response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    try {
      final result = await http.put(
        Uri.parse('$baseUrl/response'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'friend_id': friendId,
          'response': response,
        }),
      );

      if (result.statusCode != 200) {
        throw Exception('Failed to respond to invite');
      }
    } catch (e) {
      throw Exception('Error responding to invite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSentTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sentTask/$userId'),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is List &&
            responseBody.isNotEmpty &&
            responseBody[0] is List) {
          return (responseBody[0] as List).map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              throw Exception('Unexpected item structure in API response');
            }
          }).toList();
        } else {
          throw Exception('Unexpected API response structure');
        }
      } else {
        throw Exception('Failed to fetch sent invites');
      }
    } catch (e) {
      throw Exception('Error fetching sent invites: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchReceivedTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/receiveTask/$userId'),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody is List &&
            responseBody.isNotEmpty &&
            responseBody[0] is List) {
          return (responseBody[0] as List).map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              throw Exception('Unexpected item structure in API response');
            }
          }).toList();
        } else {
          throw Exception('Unexpected API response structure');
        }
      } else {
        throw Exception('Failed to fetch sent invites');
      }
    } catch (e) {
      throw Exception('Error fetching received invites: $e');
    }
  }

  Future<void> respondToTask(int friendId, int taskId, String response) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    try {
      final result = await http.put(
        Uri.parse('$baseUrl/responseTask'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'task_id': taskId,
          'friend_id': friendId,
          'response': response,
        }),
      );

      if (result.statusCode != 200) {
        throw Exception('Failed to respond to invite');
      }
    } catch (e) {
      throw Exception('Error responding to invite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTaskToday(String today) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    final response = await http.post(
      Uri.parse(
        '$baseUrl/taskToday',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': userId,
        'task_dateTime': today,
      }),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        } else {
          throw Exception(
              'Invalid data format: Expected a list inside the "data" key');
        }
      } else {
        throw Exception('Invalid response format: "data" key not found');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
  Future<Map<String, dynamic>> fetchAvailableFriends(int taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    final url = Uri.parse(
        "$baseUrl/available-friend/$taskId/$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> friends = List<Map<String, dynamic>>.from(data['friendResult']);
        List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(data['taskResult']);

        return {
          'friendResult': friends,
          'taskResult': tasks,
        };
      } else {
        throw Exception(
            'Failed to load available friends. Status code: ${response.statusCode}');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<Map<String, dynamic>> addTaskInvitation(
      List<String> friendNames,
      int taskId,
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

    final url = Uri.parse('$baseUrl/task-invitation');

    final Map<String, dynamic> requestData = {
      'friend_name': friendNames,
      'user_id': userId,
      'task_id': taskId,
    };

    try {
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

}
