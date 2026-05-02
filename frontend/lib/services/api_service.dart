import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';

class ApiService {
  static const String baseUrl = '/api';
  
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  Future<void> saveUserInfo(int userId, String role, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
  }
  
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
  
  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
  
  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
  
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('name');
  }
  
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
    };
  }
  
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  Future<AuthResponse> signup(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    
    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await saveToken(authResponse.token);
      await saveUserInfo(authResponse.userId, authResponse.role, authResponse.name);
      return authResponse;
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Signup failed');
      } catch (e) {
        throw Exception('Signup failed: ${response.statusCode}');
      }
    }
  }
  
  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
      await saveToken(authResponse.token);
      await saveUserInfo(authResponse.userId, authResponse.role, authResponse.name);
      return authResponse;
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Login failed');
      } catch (e) {
        throw Exception('Login failed: ${response.statusCode}');
      }
    }
  }
  
  Future<Map<String, dynamic>> createProject(String name, String description) async {
    final headers = await _getAuthHeaders();
    final body = {'name': name};
    if (description.isNotEmpty) {
      body['description'] = description;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/projects'),
      headers: headers,
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create project');
    }
  }
  
  Future<List<dynamic>> getProjects() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch projects');
    }
  }
  
  Future<void> addMember(int projectId, int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/projects/$projectId/members'),
      headers: headers,
      body: jsonEncode({'userId': userId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to add member');
    }
  }
  
  Future<Map<String, dynamic>> createTask(String title, String description, String priority, int projectId, int assignedTo, String? dueDate) async {
    final headers = await _getAuthHeaders();
    final body = {
      'title': title,
      'projectId': projectId,
      'assignedTo': assignedTo,
    };
    if (description.isNotEmpty) {
      body['description'] = description;
    }
    if (priority.isNotEmpty) {
      body['priority'] = priority;
    } else {
      body['priority'] = 'MEDIUM';
    }
    if (dueDate != null) {
      body['dueDate'] = dueDate;
    }
    
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: headers,
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to create task');
    }
  }
  
  Future<List<dynamic>> getMyTasks() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/my'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<List<dynamic>> getAllTasks() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/all'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch all tasks');
    }
  }
  
  Future<void> updateTaskStatus(int taskId, String status) async {
    final headers = await _getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/status'),
      headers: headers,
      body: jsonEncode({'status': status}),
    );
    
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to update task');
    }
  }
  
  Future<Map<String, dynamic>> getDashboard() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch dashboard data');
    }
  }
  
  Future<List<dynamic>> getUsers() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch users');
    }
  }
  
  Future<void> deleteProject(int projectId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$projectId'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      String errorMessage;
      try {
        final body = jsonDecode(response.body);
        errorMessage = body['message'] ?? 'Failed to delete project';
      } catch (e) {
        errorMessage = 'Failed to delete project (Status: ${response.statusCode})';
      }
      throw Exception(errorMessage);
    }
  }
  
  Future<void> deleteTask(int taskId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to delete task');
    }
  }
  
  Future<List<dynamic>> getProjectMembers(int projectId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/projects/$projectId/members'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch project members');
    }
  }
  
  Future<void> removeMember(int projectId, int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$projectId/members/$userId'),
      headers: headers,
    );
    
    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to remove member');
    }
  }
}
