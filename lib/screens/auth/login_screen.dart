import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Student tab controllers
  final _studentNoController = TextEditingController();
  final _studentPasswordController = TextEditingController();

  // Admin tab controllers
  final _adminUsernameController = TextEditingController();
  final _adminPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _studentNoController.dispose();
    _studentPasswordController.dispose();
    _adminUsernameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleStudentLogin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final studentNo = _studentNoController.text.trim();
    final password = _studentPasswordController.text;

    if (studentNo.isEmpty || password.isEmpty) {
      _showSnackBar('请填写学号和密码');
      return;
    }

    final success = await authProvider.studentLogin(studentNo, password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final error = authProvider.error ?? '登录失败，请重试';
      _showSnackBar(error);
    }
  }

  Future<void> _handleAdminLogin() async {
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    final username = _adminUsernameController.text.trim();
    final password = _adminPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('请填写用户名和密码');
      return;
    }

    final success = await authProvider.adminLogin(username, password);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      final error = authProvider.error ?? '登录失败，请重试';
      _showSnackBar(error);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('会计等级考试刷题'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '学员登录'),
            Tab(text: '管理员登录'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentTab(),
          _buildAdminTab(),
        ],
      ),
    );
  }

  Widget _buildStudentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.school,
                size: 72,
                color: Color(0xFF1A73E8),
              ),
              const SizedBox(height: 12),
              const Text(
                '学员登录',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请输入学号和密码',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _studentNoController,
                        decoration: const InputDecoration(
                          labelText: '学号',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _studentPasswordController,
                        decoration: const InputDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleStudentLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  '没有账号？去注册',
                  style: TextStyle(
                    color: Color(0xFF1A73E8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.admin_panel_settings,
                size: 72,
                color: Color(0xFF1A73E8),
              ),
              const SizedBox(height: 12),
              const Text(
                '管理员登录',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '请输入管理员账号和密码',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _adminUsernameController,
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _adminPasswordController,
                        decoration: const InputDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _handleAdminLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A73E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
