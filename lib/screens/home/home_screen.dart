import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data - would be fetched from backend in production
  final double _recentExamScore = 78.5;
  final double _totalAccuracyRate = 0.72;
  final int _pendingWrongQuestions = 23;
  final int _todayRecommendedCount = 15;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? '考生';
    final userStudentNo = authProvider.user?.studentNo ?? '';
    final userAccuracy = authProvider.user?.accuracyRate ?? _totalAccuracyRate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('会计刷题'),
        centerTitle: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Text(
                userName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, authProvider, userName, userStudentNo, userAccuracy),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthProvider authProvider,
    String userName,
    String userStudentNo,
    double userAccuracy,
  ) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            accountEmail: Text(
              userStudentNo.isNotEmpty ? '学号: $userStudentNo' : '',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('正确率', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: userAccuracy,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF1A73E8),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(userAccuracy * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.assessment, color: Color(0xFF1A73E8)),
            title: const Text('能力报告'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/report');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF1A73E8)),
            title: const Text('考试历史'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/exam-history');
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('退出登录', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('确认退出'),
                  content: const Text('确定要退出登录吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                        authProvider.logout();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('确定', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh data from backend
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLearningOverviewCard(context),
            const SizedBox(height: 16),
            _buildQuickActionsRow(context),
            const SizedBox(height: 16),
            _buildAdaptiveRecommendationCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningOverviewCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '学习概览',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Accuracy ring
                Expanded(
                  child: Column(
                    children: [
                      CircularPercentIndicator(
                        radius: 50,
                        lineWidth: 8,
                        percent: _totalAccuracyRate,
                        center: Text(
                          '${(_totalAccuracyRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        progressColor: _totalAccuracyRate >= 0.7
                            ? Colors.green
                            : _totalAccuracyRate >= 0.5
                                ? Colors.orange
                                : Colors.red,
                        backgroundColor: Colors.grey[200]!,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        animationDuration: 1000,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '总正确率',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Recent score
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '最近考试',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_recentExamScore.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                      const Text(
                        '分',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Pending wrong questions
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        '待复习错题',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Badge(
                        largeSize: 22,
                        label: Text(
                          '$_pendingWrongQuestions',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          size: 40,
                          color: Color(0xFF1A73E8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildActionCard(
          context,
          title: '开始刷题',
          icon: Icons.quiz,
          color: const Color(0xFF1A73E8),
          onTap: () => Navigator.pushNamed(context, '/exam-list'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          context,
          title: '仿真考试',
          icon: Icons.assignment,
          color: Colors.orange,
          onTap: () => Navigator.pushNamed(context, '/exam-list?type=OFFICIAL'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          context,
          title: '错题本',
          icon: Icons.book,
          color: Colors.redAccent,
          onTap: () => Navigator.pushNamed(context, '/wrong-book'),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionCard(
          context,
          title: '能力报告',
          icon: Icons.bar_chart,
          color: Colors.teal,
          onTap: () => Navigator.pushNamed(context, '/report'),
        )),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveRecommendationCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A73E8).withOpacity(0.05),
              const Color(0xFF4285F4).withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF1A73E8),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '自适应练习推荐',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '今日推荐练习$_todayRecommendedCount道薄弱考点题',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/adaptive-practice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('开始练习'),
            ),
          ],
        ),
      ),
    );
  }
}
