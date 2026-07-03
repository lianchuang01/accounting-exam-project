import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // Stats counters (mock data for now)
  int _totalQuestions = 0;
  int _totalStudents = 0;
  int _totalExams = 0;
  int _activeExams = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    // Placeholder stats — in production these would come from an API
    setState(() {
      _totalQuestions = 0;
      _totalStudents = 0;
      _totalExams = 0;
      _activeExams = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminName = authProvider.userName ?? '管理员';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          '管理后台',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202124),
      ),
      drawer: _buildDrawer(context, authProvider),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin greeting
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                '你好，$adminName',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                ),
              ),
            ),

            // Stats overview
            _buildStatsRow(),
            const SizedBox(height: 16),

            // Function grid
            _buildFunctionGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final adminName = authProvider.userName ?? '管理员';

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A73E8)),
            accountName: Text(
              adminName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            accountEmail: const Text('管理后台'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                size: 36,
                color: Color(0xFF1A73E8),
              ),
            ),
          ),
          _drawerItem(
            icon: Icons.library_books,
            title: '题库管理',
            onTap: () {
              Navigator.pop(context);
              // TODO: navigate to question management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('题库管理 - 开发中')),
              );
            },
          ),
          _drawerItem(
            icon: Icons.label,
            title: '知识点管理',
            onTap: () {
              Navigator.pop(context);
              // TODO: navigate to knowledge management
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('知识点管理 - 开发中')),
              );
            },
          ),
          _drawerItem(
            icon: Icons.tune,
            title: '试卷配置',
            onTap: () {
              Navigator.pop(context);
              // TODO: navigate to paper config
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('试卷配置 - 开发中')),
              );
            },
          ),
          _drawerItem(
            icon: Icons.people,
            title: '学员数据',
            onTap: () {
              Navigator.pop(context);
              // TODO: navigate to student data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('学员数据 - 开发中')),
              );
            },
          ),
          const Spacer(),
          const Divider(height: 1),
          _drawerItem(
            icon: Icons.logout,
            title: '退出登录',
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text('确认退出'),
                  content: const Text('确定要退出管理后台吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA4335),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('退出'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5F6368)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: Color(0xFF202124)),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
      onTap: onTap,
    );
  }

  Widget _buildStatsRow() {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          _statCard('题目总数', _totalQuestions, const Color(0xFF1A73E8), Icons.quiz),
          const SizedBox(width: 10),
          _statCard('学员总数', _totalStudents, const Color(0xFF34A853), Icons.people),
          const SizedBox(width: 10),
          _statCard('试卷总数', _totalExams, const Color(0xFFFBBC04), Icons.assignment),
          const SizedBox(width: 10),
          _statCard('进行中', _activeExams, const Color(0xFFEA4335), Icons.timer),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              count == 0 ? '-' : '$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF5F6368),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _functionCard(
          '题库管理',
          Icons.library_books,
          const Color(0xFF1A73E8),
          () {
            // TODO: navigate to question management
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('题库管理 - 开发中')),
            );
          },
        ),
        _functionCard(
          '知识点标签',
          Icons.label,
          const Color(0xFF34A853),
          () {
            // TODO: navigate to knowledge management
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('知识点管理 - 开发中')),
            );
          },
        ),
        _functionCard(
          '命题配置',
          Icons.tune,
          const Color(0xFFFBBC04),
          () {
            // TODO: navigate to paper config
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('命题配置 - 开发中')),
            );
          },
        ),
        _functionCard(
          '学员数据',
          Icons.people,
          const Color(0xFFEA4335),
          () {
            // TODO: navigate to student data
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('学员数据 - 开发中')),
            );
          },
        ),
        _functionCard(
          '数据统计',
          Icons.bar_chart,
          const Color(0xFF9C27B0),
          () {
            // Show stats overview directly
            _showStatsOverview();
          },
        ),
        _functionCard(
          '批量导入',
          Icons.file_upload,
          const Color(0xFF00BCD4),
          () {
            // TODO: navigate to import page
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('批量导入 - 开发中')),
            );
          },
        ),
      ],
    );
  }

  Widget _functionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF202124),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsOverview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Color(0xFF1A73E8)),
            SizedBox(width: 8),
            Text('数据统计概览'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statRow('题目总数', '$_totalQuestions'),
            _statRow('学员总数', '$_totalStudents'),
            _statRow('试卷总数', '$_totalExams'),
            _statRow('进行中考试', '$_activeExams'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5F6368),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),
        ],
      ),
    );
  }
}
