class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // Android emulator -> host
  static const String studentBaseUrl = 'http://10.0.2.2:8080/api';
  static const String adminBaseUrl = 'http://10.0.2.2:8080/api/admin';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
