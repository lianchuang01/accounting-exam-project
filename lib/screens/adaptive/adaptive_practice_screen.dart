import 'package:flutter/material.dart';
import '../../services/exam_service.dart';
import '../../providers/auth_provider.dart';

class AdaptivePracticeScreen extends StatefulWidget {
  const AdaptivePracticeScreen({super.key});

  @override
  State<AdaptivePracticeScreen> createState() => _AdaptivePracticeScreenState();
}

class _AdaptivePracticeScreenState extends State<AdaptivePracticeScreen> {
  final ExamService _examService = ExamService();
  String _selectedSubject = '';
  int _questionCount = 20;
  bool _isGenerating = false;

  final List<String> _subjects = [
    '会计实务',
    '财务管理',
    '经济法基础',
    '成本会计',
    '审计学',
    '税法',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSubject = _subjects.first;
  }

  Future<void> _generatePractice() async {
    setState(() => _isGenerating = true);
    try {
      final result = await _examService.generateAdaptivePractice(
        subject: _selectedSubject,
        count: _questionCount,
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/exam-taking',
        arguments: result['paperId'],
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('生成练习失败: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '重试',
            textColor: Colors.white,
            onPressed: _generatePractice,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自适应专项练习'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A73E8).withOpacity(0.05),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A73E8).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 48,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '智能生成练习',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '系统将根据你的历史错题数据，\n按70%薄弱考点+30%已掌握考点生成个性化练习',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subject selection
            const Text(
              '选择科目',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSubject,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: const Icon(Icons.book_outlined, color: Color(0xFF1A73E8)),
              ),
              items: _subjects.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSubject = value);
                }
              },
            ),
            const SizedBox(height: 20),

            // Question count selector
            const Text(
              '题目数量',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [10, 20, 30].map((count) {
                final isSelected = _questionCount == count;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: count == 10 ? 0 : 6,
                      right: count == 30 ? 0 : 6,
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _questionCount = count),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A73E8)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1A73E8)
                                : Colors.grey[300]!,
                            width: isSelected ? 0 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '题',
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Info about question count
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF1A73E8),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '预计练习时长约${_questionCount ~/ 2}~$_questionCount分钟',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Generate button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generatePractice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF1A73E8).withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('生成中...', style: TextStyle(fontSize: 16)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: 8),
                          Text('生成练习', style: TextStyle(fontSize: 16)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional info
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '小贴士',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• 练习完成后可以查看详细解析\n'
                      '• 错题将自动归入错题本\n'
                      '• 多次练习可逐步提高薄弱考点正确率',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
