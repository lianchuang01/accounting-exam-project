import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Future<Map<String, dynamic>> studentRegister({
    required String name,
    required String studentNo,
    required String password,
    String? phone,
    String? email,
  }) async {
    try {
      final res = await _client.post('/auth/student/register', data: {
        'name': name,
        'studentNo': studentNo,
        'password': password,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      });
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> studentLogin({
    required String studentNo,
    required String password,
  }) async {
    try {
      final res = await _client.post('/auth/student/login', data: {
        'studentNo': studentNo,
        'password': password,
      });
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> adminLogin({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _client.post('/auth/admin/login', data: {
        'username': username,
        'password': password,
      });
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final res = await _client.get('/student/profile');
      return _unwrap(res);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _unwrap(Response res) {
    final data = res.data as Map<String, dynamic>;
    if (data['code'] != 200) {
      throw Exception(data['message'] ?? '请求失败');
    }
    return data['data'] as Map<String, dynamic>;
  }

  Exception _handleError(DioException e) {
    if (e.response?.data != null) {
      final msg = (e.response!.data as Map)['message'] ?? '网络错误';
      return Exception(msg.toString());
    }
    return Exception('网络连接失败，请检查网络');
  }
}
