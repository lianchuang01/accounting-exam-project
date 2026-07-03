import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/exam_result.dart';

class GradedResultScreen extends StatefulWidget {
  final int examRecordId;
  final Map<String, dynamic> resultData;

  const GradedResultScreen({
    super.key,
    required this.examRecordId,
    required this.resultData,
  });

  @override
  State<GradedResultScreen> createState() => _GradedResultScreenState();
}

class _GradedResultScreenState extends State<GradedResultScreen> {
  late GradedResult _result;
  bool _showAnswers = false;

  @override
  void initState() {
    super.initState();
    _result = GradedResult.fromJson(widget.resultData);
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min}分${sec}秒';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('考试结果')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(),
            const SizedBox(height: 16),
            _buildStatsCard(),
            const SizedBox(height: 16),
            _buildToggleButton(),
            if (_showAnswers) ...[
              const SizedBox(height: 16),
              _buildAnswerComparison(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    final accuracy = _result.accuracyRate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              '${_result.scoreObtained.toStringAsFixed(0)} / ${_result.totalScore.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: accuracy >= 60
                    ? const Color(0xFF34A853)
                    : const Color(0xFFEA4335),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '正确率 ${accuracy.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                color: accuracy >= 60
                    ? const Color(0xFF34A853)
                    : const Color(0xFFEA4335),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statItem('正确', '${_result.correctCount}', const Color(0xFF34A853)),
            _statItem('错误', '${_result.wrongCount}', const Color(0xFFEA4335)),
            _statItem('用时', _formatDuration(_result.durationSeconds),
                const Color(0xFF1A73E8)),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Color(0xFF5F6368))),
      ],
    );
  }

  Widget _buildToggleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => setState(() => _showAnswers = !_showAnswers),
        icon: Icon(_showAnswers ? Icons.visibility_off : Icons.visibility),
        label: Text(_showAnswers ? '收起答案对照' : '查看答案对照'),
      ),
    );
  }

  Widget _buildAnswerComparison() {
    if (_result.comparisons.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('无答题记录')));
    }
    return Column(
      children: _result.comparisons.map((comp) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question stem
              Text(
                '第${_result.comparisons.indexOf(comp) + 1}题',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(comp.stem, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 8),
              // Student answer (left) vs Correct answer (right)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('你的答案',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text(comp.studentAnswer ?? '未作答'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('正确答案',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 4),
                          Text(comp.correctAnswer ?? ''),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Score
              const SizedBox(height: 8),
              Text(
                comp.isCorrect ? '✅ 正确 +${comp.scoreObtained}分' : '❌ 错误 0分',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: comp.isCorrect ? Colors.green : Colors.red,
                ),
              ),
              // Analysis
              if (comp.analysis != null && comp.analysis!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('解析',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(comp.analysis!),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      )).toList(),
    );
  }
}
