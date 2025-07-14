import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = 'http://192.168.1.17:5001/api';
  static String? _token;

  String? getToken() {
    return _token;
  }

  // Load token from local storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  // Save token locally
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Clear token
  static Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Check login status using /api/users/me
  static Future<bool> isLoggedIn() async {
    if (_token == null) return false;
    final url = '$_baseUrl/users/me';

    _logRequest('GET', url, headers: {'Authorization': 'Bearer $_token'});

    final res = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});

    _logResponse(res);
    return res.statusCode == 200;
  }

  static void _logRequest(String method, String url, {Map<String, String>? headers, Object? body}) {
    if (kDebugMode) {
      print('➡️ $method $url');
      if (headers != null) print('🧾 Headers: $headers');
      if (body != null) print('📦 Body: $body');
    }
  }

  static void _logResponse(http.Response res) {
    if (kDebugMode) {
      print('✅ Status: ${res.statusCode}');
      print('⬅️ Response: ${res.body}');
    }
  }

  static Future<http.Response> register(String name, String email, String password) async {
    final url = '$_baseUrl/auth/signup';
    final body = {'name': name, 'email': email, 'password': password};
    _logRequest('POST', url, body: body);

    final res = await http.post(Uri.parse(url), body: body);
    _logResponse(res);
    return res;
  }

  static Future<http.Response> login(String email, String password) async {
    final url = '$_baseUrl/auth/login';
    final body = {'email': email, 'password': password};
    _logRequest('POST', url, body: body);

    final res = await http.post(Uri.parse(url), body: body);
    _logResponse(res);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await saveToken(data['token']);
    }

    return res;
  }

  static Future<List> getGroups() async {
    final url = '$_baseUrl/chat/groups';
    _logRequest('GET', url, headers: {'Authorization': 'Bearer $_token'});

    final res = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});

    _logResponse(res);
    return jsonDecode(res.body);
  }

  static Future<http.Response> createGroup(String name, List<String> participants) async {
    final url = '$_baseUrl/chat/group';
    final body = jsonEncode({'name': name, 'participants': participants});

    _logRequest('POST', url, headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'}, body: body);

    final res = await http.post(Uri.parse(url), headers: {'Authorization': 'Bearer $_token', 'Content-Type': 'application/json'}, body: body);

    _logResponse(res);
    return res;
  }

  static Future<List> getMessages(String groupId) async {
    final url = '$_baseUrl/chat/group/$groupId';
    _logRequest('GET', url, headers: {'Authorization': 'Bearer $_token'});

    final res = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});

    _logResponse(res);
    return jsonDecode(res.body);
  }

  static Future<List> getOneToOneMessages(String userId) async {
    final url = '$_baseUrl/chat/one-to-one/$userId';
    _logRequest('GET', url, headers: {'Authorization': 'Bearer $_token'});

    final res = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});

    _logResponse(res);
    return jsonDecode(res.body)['messages'];
  }

  static Future<List> getAllGroups() async {
    final url = '$_baseUrl/chat/groups';
    _logRequest('GET', url, headers: {'Authorization': 'Bearer $_token'});

    final res = await http.get(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'});

    _logResponse(res);
    return jsonDecode(res.body);
  }

  static Future<http.Response> sendMessage(String groupId, String content, {String? parentMessage}) async {
    final url = '$_baseUrl/chat/message';
    final body = {'groupId': groupId, 'content': content, if (parentMessage != null) 'parentMessage': parentMessage};

    _logRequest('POST', url, headers: {'Authorization': 'Bearer $_token'}, body: body);

    final res = await http.post(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'}, body: body);
    _logResponse(res);
    return res;
  }

  static Future<http.Response> reactToMessage(String messageId, String emoji) async {
    final url = '$_baseUrl/chat/message/$messageId/reaction';
    final body = {'emoji': emoji};

    _logRequest('POST', url, headers: {'Authorization': 'Bearer $_token'}, body: body);

    final res = await http.post(Uri.parse(url), headers: {'Authorization': 'Bearer $_token'}, body: body);
    _logResponse(res);
    return res;
  }
}
