import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exam_result.dart';

class ExamResultScreen extends StatefulWidget {
  final ExamResult examResult;

  const ExamResultScreen({super.key, required this.examResult});

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.examResult;
    final score = result.score;
    final totalScore = result.totalScore;
    final scorePercent = totalScore > 0 ? score / totalScore : 0.0;
    final correctCount = result.correctCount;
    final wrongCount = result.wrongCount;
    final totalQuestions = correctCount + wrongCount + result.unansweredCount;
    final accuracy = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
    final passed = scorePercent >= 0.6;
    final timeUsed = result.timeUsedSeconds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('考试结果'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF4285F4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '成绩概览'),
            Tab(text: '答案对照'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScoreOverview(result),
          _buildAnswerComparison(result),
        ],
      ),
    );
  }

  Widget _buildScoreOverview(ExamResult result) {
    final score = result.score;
    final totalScore = result.totalScore;
    final scorePercent = totalScore > 0 ? score / totalScore : 0.0;
    final correctCount = result.correctCount;
    final wrongCount = result.wrongCount;
    final unansweredCount = result.unansweredCount;
    final totalQuestions = correctCount + wrongCount + unansweredCount;
    final accuracy = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;
    final passed = scorePercent >= 0.6;
    final timeUsed = result.timeUsedSeconds;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score summary card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: passed
                      ? [const Color(0xFF1A73E8), const Color(0xFF4285F4)]
                      : [Colors.red.shade400, Colors.red.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '考试成绩',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${score.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '/ $totalScore 分',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      passed ? '恭喜通过 🎉' : '未通过，继续加油 💪',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Detail stats
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.check_circle,
                          iconColor: Colors.green,
                          label: '正确',
                          value: '$correctCount',
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.cancel,
                          iconColor: Colors.red,
                          label: '错误',
                          value: '$wrongCount',
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.help_outline,
                          iconColor: Colors.orange,
                          label: '未答',
                          value: '$unansweredCount',
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.pie_chart,
                          iconColor: const Color(0xFF1A73E8),
                          label: '正确率',
                          value: '${(accuracy * 100).toStringAsFixed(1)}%',
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.timer,
                          iconColor: Colors.teal,
                          label: '用时',
                          value: _formatTimeUsed(timeUsed),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildStatItem(
                          icon: Icons.score,
                          iconColor: passed ? Colors.green : Colors.red,
                          label: '得分率',
                          value: '${(scorePercent * 100).toStringAsFixed(0)}%',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/wrong-book');
                  },
                  icon: const Icon(Icons.book),
                  label: const Text('查看错题本'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A73E8),
                    side: const BorderSide(color: Color(0xFF1A73E8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatTimeUsed(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0) {
      return '${min}分${sec}秒';
    }
    return '${sec}秒';
  }

  Widget _buildAnswerComparison(ExamResult result) {
    final questions = result.questions;

    if (questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无答题记录', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final q = questions[index];
        final isCorrect = q.isCorrect;
        const optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isCorrect ? Colors.green : Colors.red,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '第${index + 1}题',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        q.questionTypeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${q.score.toStringAsFixed(0)}分',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question stem
                Text(
                  q.stem,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 12),

                // Options
                ...q.options.asMap().entries.map((entry) {
                  final i = entry.key;
                  final opt = entry.value;
                  final isStudentAnswer = q.studentAnswer == opt.key;
                  final isCorrectAnswer = q.correctAnswer == opt.key;

                  Color? bgColor;
                  Color? borderColor;
                  Color textColor = Colors.black87;
                  String? suffix;

                  if (isCorrect) {
                    if (isStudentAnswer) {
                      bgColor = Colors.green.withOpacity(0.08);
                      borderColor = Colors.green;
                      suffix = ' ✓';
                    }
                  } else {
                    if (isStudentAnswer) {
                      bgColor = Colors.red.withOpacity(0.08);
                      borderColor = Colors.red;
                      suffix = ' ✗（你的答案）';
                      textColor = Colors.red;
                    } else if (isCorrectAnswer) {
                      bgColor = Colors.green.withOpacity(0.08);
                      borderColor = Colors.green;
                      suffix = ' ✓（正确答案）';
                      textColor = Colors.green;
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: borderColor ?? Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${optionLabels[i]}. ${opt.value}',
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                            fontWeight: suffix != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (suffix != null)
                          Text(
                            suffix,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  );
                }),

                // Analysis / Explanation
                if (q.analysis != null && q.analysis!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A73E8).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1A73E8).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: Color(0xFF1A73E8),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '答案解析',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A73E8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q.analysis!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
