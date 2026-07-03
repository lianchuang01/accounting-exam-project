import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../models/exam_paper.dart';
import '../../services/exam_service.dart';
import '../../providers/auth_provider.dart';

class ExamTakingScreen extends StatefulWidget {
  final String paperId;

  const ExamTakingScreen({super.key, required this.paperId});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final ExamService _examService = ExamService();
  late PageController _pageController;
  ExamPaper? _paper;
  List<Question> _questions = [];
  Map<String, dynamic> _answers = {}; // questionId -> answer value
  Map<String, bool> _bookmarkedQuestions = {};

  bool _isLoading = true;
  String? _error;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadExam();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExam() async {
    try {
      final result = await _examService.fetchExamWithQuestions(widget.paperId);
      setState(() {
        _paper = result['paper'] as ExamPaper;
        _questions = result['questions'] as List<Question>;
        _remainingSeconds = _paper!.durationMinutes * 60;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = '加载试卷失败: $e';
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _autoSubmit();
        return;
      }
      setState(() {
        _remainingSeconds--;
      });
    });
  }

  void _autoSubmit() {
    if (_isSubmitted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('时间到'),
        content: const Text('考试时间已结束，系统将自动提交答卷。'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submitExam();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  void _onAnswerChanged(String questionId, dynamic value) {
    setState(() {
      _answers[questionId] = value;
    });
  }

  bool _isQuestionAnswered(int index) {
    if (index >= _questions.length) return false;
    return _answers.containsKey(_questions[index].id);
  }

  int get _answeredCount => _answers.length;
  int get _totalCount => _questions.length;

  Future<void> _submitExam() async {
    if (_isSubmitted) return;
    setState(() => _isSubmitted = true);
    _timer?.cancel();

    try {
      final result = await _examService.submitExam(
        paperId: widget.paperId,
        answers: _answers,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/exam-result',
        arguments: result,
      );
    } catch (e) {
      setState(() => _isSubmitted = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showSubmitConfirmDialog() {
    final unanswered = _totalCount - _answeredCount;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('提交试卷'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('已作答: $_answeredCount/$_totalCount 题'),
            if (unanswered > 0)
              Text(
                '未作答: $unanswered 题',
                style: const TextStyle(color: Colors.orange),
              ),
            const SizedBox(height: 12),
            const Text('确认提交后将无法修改答案。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('继续作答'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _submitExam();
            },
            child: const Text('确认提交'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('加载中...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('考试')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadExam, child: const Text('重试')),
            ],
          ),
        ),
      );
    }

    final timeColor = _remainingSeconds < 300 ? Colors.red : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(_paper?.title ?? '考试中'),
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
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _remainingSeconds < 300
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, size: 18, color: timeColor),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: timeColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[50],
            child: Row(
              children: [
                Text(
                  '进度: $_answeredCount/$_totalCount',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _totalCount > 0 ? _answeredCount / _totalCount : 0,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF1A73E8),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: _questions.isEmpty
                ? const Center(child: Text('暂无题目'))
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _questions.length,
                    onPageChanged: (index) => setState(() {}),
                    itemBuilder: (context, index) {
                      return _buildQuestionPage(index);
                    },
                  ),
          ),

          // Bottom navigation bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = _questions[index];
    final currentAnswer = _answers[question.id];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '第${index + 1}题',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A73E8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getQuestionTypeColor(question.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getQuestionTypeLabel(question.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getQuestionTypeColor(question.type),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              // Bookmark
              IconButton(
                icon: Icon(
                  _bookmarkedQuestions[question.id] == true
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: _bookmarkedQuestions[question.id] == true
                      ? Colors.orange
                      : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _bookmarkedQuestions[question.id] =
                        !(_bookmarkedQuestions[question.id] ?? false);
                  });
                },
                tooltip: '标记题目',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question stem
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              question.stem,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ..._buildOptions(question, currentAnswer),
        ],
      ),
    );
  }

  Color _getQuestionTypeColor(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return const Color(0xFF1A73E8);
      case QuestionType.multiChoice:
        return Colors.orange;
      case QuestionType.judgement:
        return Colors.teal;
    }
  }

  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return '单选题';
      case QuestionType.multiChoice:
        return '多选题';
      case QuestionType.judgement:
        return '判断题';
    }
  }

  List<Widget> _buildOptions(Question question, dynamic currentAnswer) {
    final List<Widget> widgets = [];
    const optionLabels = ['A', 'B', 'C', 'D', 'E', 'F'];

    switch (question.type) {
      case QuestionType.singleChoice:
        for (int i = 0; i < question.options.length; i++) {
          final opt = question.options[i];
          final isSelected = currentAnswer == opt.key;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _onAnswerChanged(question.id, opt.key),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A73E8).withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1A73E8)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: opt.key,
                        groupValue: currentAnswer as String?,
                        activeColor: const Color(0xFF1A73E8),
                        onChanged: (v) => _onAnswerChanged(question.id, v),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${optionLabels[i]}. ${opt.value}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? const Color(0xFF1A73E8) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        break;

      case QuestionType.multiChoice:
        final selectedList =
            (currentAnswer as List<String>?) ?? <String>[];
        for (int i = 0; i < question.options.length; i++) {
          final opt = question.options[i];
          final isSelected = selectedList.contains(opt.key);
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final newList = List<String>.from(selectedList);
                  if (isSelected) {
                    newList.remove(opt.key);
                  } else {
                    newList.add(opt.key);
                  }
                  _onAnswerChanged(question.id, newList);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isSelected,
                        activeColor: Colors.orange,
                        onChanged: (v) {
                          final newList = List<String>.from(selectedList);
                          if (v == true) {
                            newList.add(opt.key);
                          } else {
                            newList.remove(opt.key);
                          }
                          _onAnswerChanged(question.id, newList);
                        },
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${optionLabels[i]}. ${opt.value}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isSelected ? Colors.orange.shade700 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        break;

      case QuestionType.judgement:
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _onAnswerChanged(question.id, 'true'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: currentAnswer == 'true'
                            ? Colors.green.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentAnswer == 'true'
                              ? Colors.green
                              : Colors.grey[300]!,
                          width: currentAnswer == 'true' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 36,
                            color: currentAnswer == 'true'
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '正确',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: currentAnswer == 'true'
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _onAnswerChanged(question.id, 'false'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: currentAnswer == 'false'
                            ? Colors.red.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentAnswer == 'false'
                              ? Colors.red
                              : Colors.grey[300]!,
                          width: currentAnswer == 'false' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            size: 36,
                            color: currentAnswer == 'false'
                                ? Colors.red
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '错误',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: currentAnswer == 'false'
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
    }

    return widgets;
  }

  Widget _buildBottomBar() {
    final currentIndex = _pageController.hasClients
        ? _pageController.page?.toInt() ?? 0
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigation dots
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final answered = _isQuestionAnswered(index);
                final isCurrent = index == currentIndex;
                final isBookmarked =
                    _bookmarkedQuestions[_questions[index].id] == true;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFF1A73E8)
                          : answered
                              ? Colors.green
                              : Colors.grey[200],
                      shape: BoxShape.circle,
                      border: isBookmarked && !isCurrent
                          ? Border.all(color: Colors.orange, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (isCurrent || answered) ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation buttons + submit
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                // Previous
                if (currentIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_left, size: 18),
                      label: const Text('上一题'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),

                const SizedBox(width: 12),

                // Submit button
                ElevatedButton.icon(
                  onPressed: _isSubmitted ? null : _showSubmitConfirmDialog,
                  icon: const Icon(Icons.task_alt, size: 18),
                  label: const Text('提交试卷'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),

                const SizedBox(width: 12),

                // Next
                if (currentIndex < _questions.length - 1)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.chevron_right, size: 18),
                      label: const Text('下一题'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A73E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
