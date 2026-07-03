import 'package:flutter/material.dart';
import '../config/theme.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String examList = '/exam-list';
  static const String examTaking = '/exam-taking';
  static const String examResult = '/exam-result';
  static const String wrongBook = '/wrong-book';
  static const String report = '/report';
  static const String adaptivePractice = '/adaptive-practice';
  static const String admin = '/admin';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Routes will be registered in main.dart with named routes
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Route not found')),
      ),
      settings: settings,
    );
  }
}
