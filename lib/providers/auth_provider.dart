import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthRole { student, admin, none }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final ApiClient _apiClient;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  AuthRole _role = AuthRole.none;
  String? _token;
  String? _userName;
  int? _userId;
  String? _studentNo;
  String? _error;

  AuthProvider(this._authService, this._apiClient) {
    _loadSavedSession();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  AuthRole get role => _role;
  String? get token => _token;
  String? get userName => _userName;
  int? get userId => _userId;
  String? get studentNo => _studentNo;
  String? get error => _error;
  bool get isStudent => _role == AuthRole.student;
  bool get isAdmin => _role == AuthRole.admin;

  Future<void> _loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _role = AuthRole.values.firstWhere(
      (r) => r.name == (prefs.getString('user_role') ?? 'none'),
      orElse: () => AuthRole.none,
    );
    _userName = prefs.getString('user_name');
    _userId = prefs.getInt('user_id');
    _studentNo = prefs.getString('student_no');

    if (_token != null && _role != AuthRole.none) {
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    _token = data['token'] as String;
    _userId = data['userId'] as int;
    _userName = data['name'] as String;
    final roleStr = data['role'] as String;
    _role = roleStr == 'STUDENT' ? AuthRole.student : AuthRole.admin;

    await _apiClient.saveToken(_token!);
    await prefs.setString('user_role', _role.name);
    await prefs.setString('user_name', _userName!);
    await prefs.setInt('user_id', _userId!);
    if (data.containsKey('studentNo')) {
      _studentNo = data['studentNo'] as String;
      await prefs.setString('student_no', _studentNo!);
    }

    _isLoggedIn = true;
    _error = null;
    notifyListeners();
  }

  Future<bool> studentLogin(String studentNo, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.studentLogin(
        studentNo: studentNo,
        password: password,
      );
      await _saveSession(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> studentRegister({
    required String name,
    required String studentNo,
    required String password,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.studentRegister(
        name: name,
        studentNo: studentNo,
        password: password,
        phone: phone,
      );
      await _saveSession(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> adminLogin(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authService.adminLogin(
        username: username,
        password: password,
      );
      await _saveSession(data);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
    await prefs.remove('student_no');

    _isLoggedIn = false;
    _token = null;
    _role = AuthRole.none;
    _userName = null;
    _userId = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
