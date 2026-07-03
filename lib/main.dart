import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/exam_service.dart';
import 'services/report_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/exam/exam_list_screen.dart';
import 'screens/exam/exam_taking_screen.dart';
import 'screens/exam/exam_result_screen.dart';
import 'screens/wrong_book/wrong_book_screen.dart';
import 'screens/report/report_screen.dart';
import 'screens/adaptive/adaptive_practice_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authService = AuthService(apiClient);
  final examService = ExamService(apiClient);
  final reportService = ReportService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, apiClient),
        ),
        Provider.value(value: examService),
        Provider.value(value: reportService),
      ],
      child: const AccountingExamApp(),
    ),
  );
}

class AccountingExamApp extends StatelessWidget {
  const AccountingExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '会计等级考试刷题',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.examList: (_) => const ExamListScreen(),
        AppRoutes.wrongBook: (_) => const WrongBookScreen(),
        AppRoutes.report: (_) => const ReportScreen(),
        AppRoutes.adaptivePractice: (_) => const AdaptivePracticeScreen(),
        AppRoutes.admin: (_) => const AdminDashboardScreen(),
      },
      onGenerateRoute: (settings) {
        // Routes with parameters
        if (settings.name == AppRoutes.examTaking) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => ExamTakingScreen(
              paperId: (args['paperId'] ?? '').toString(),
            ),
          );
        }
        if (settings.name == AppRoutes.examResult) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => GradedResultScreen(
              examRecordId: args['examRecordId'] as int,
              resultData: args['resultData'] as Map<String, dynamic>,
            ),
          );
        }
        return null;
      },
    );
  }
}
