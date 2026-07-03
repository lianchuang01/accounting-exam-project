import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/wrong_question.dart';
import '../../models/voice_segment.dart';
import '../../services/api_client.dart';
import '../../services/report_service.dart';

class WrongBookScreen extends StatefulWidget {
  final ReportService? reportService;

  const WrongBookScreen({super.key, this.reportService});

  ReportService get _service => reportService ?? ReportService(ApiClient());

  @override
  State<WrongBookScreen> createState() => _WrongBookScreenState();
}

class _WrongBookScreenState extends State<WrongBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<WrongQuestionVO>> _notClearedFuture;
  late Future<List<WrongQuestionVO>> _clearedFuture;

  List<WrongQuestionVO> _notClearedQuestions = [];
  List<WrongQuestionVO> _clearedQuestions = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget._service.getWrongQuestions(isCleared: false),
        widget._service.getWrongQuestions(isCleared: true),
      ]);

      setState(() {
        _notClearedQuestions = (results[0] as List<dynamic>)
            .map((e) =>
                WrongQuestionVO.fromJson(e as Map<String, dynamic>))
            .toList();
        _clearedQuestions = (results[1] as List<dynamic>)
            .map((e) =>
                WrongQuestionVO.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _onReadAll() async {
    try {
      await widget._service.getVoiceQueue();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在朗读错题...'),
          backgroundColor: Color(0xFF1A73E8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('朗读失败: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Color(0xFFEA4335),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onReadQuestion(WrongQuestionVO question) async {
    try {
      final questionId = int.tryParse(question.questionId.toString());
      final ids = questionId != null ? [questionId] : null;
      await widget._service.getVoiceQueue(questionIds: ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在朗读该题目...'),
          backgroundColor: Color(0xFF1A73E8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('朗读失败: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Color(0xFFEA4335),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onClearQuestion(WrongQuestionVO question) async {
    try {
      final qId = int.tryParse(question.questionId.toString());
      if (qId == null) return;
      await widget._service.clearWrongQuestion(qId);
      setState(() {
        _notClearedQuestions.removeWhere((q) => q.id == question.id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已清除该错题'),
          backgroundColor: Color(0xFF34A853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('清除失败: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: Color(0xFFEA4335),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildLevelBadge(int wrongCount) {
    Color badgeColor;
    String label;

    if (wrongCount <= 1) {
      badgeColor = const Color(0xFF34A853);
      label = '$wrongCount次';
    } else if (wrongCount <= 3) {
      badgeColor = const Color(0xFFFBBC04);
      label = '$wrongCount次';
    } else {
      badgeColor = const Color(0xFFEA4335);
      label = '$wrongCount次';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildKnowledgeTags(List<String> tags) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1A73E8).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1A73E8),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWrongQuestionCard(WrongQuestionVO question) {
    final isExpanded = _expandedIds.contains(question.id);
    final stem = question.stem;
    final displayStem = isExpanded ? stem : (stem.length > 80 ? '${stem.substring(0, 80)}...' : stem);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleExpand(question.id.toString()),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: stem
                Text(
                  displayStem,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202124),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Tags row
                Row(
                  children: [
                    _buildLevelBadge(question.wrongCount),
                    const SizedBox(width: 8),
                    Expanded(child: _buildKnowledgeTags(question.knowledgeTags)),
                  ],
                ),

                // Last wrong date
                if (question.lastWrongAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '最近错题: ${DateFormat('yyyy-MM-dd HH:mm').format(question.lastWrongAt!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5F6368),
                    ),
                  ),
                ],

                // Expanded details
                if (isExpanded) ...[
                  const Divider(height: 20),
                  if (question.studentAnswer != null)
                    _buildDetailRow('你的答案', question.studentAnswer!, const Color(0xFFEA4335)),
                  if (question.correctAnswer != null)
                    _buildDetailRow('正确答案', question.correctAnswer!, const Color(0xFF34A853)),
                  if (question.analysis != null && question.analysis!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '解析',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5F6368),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            question.analysis!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF202124),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _onReadQuestion(question),
                        icon: const Icon(Icons.volume_up, size: 18),
                        label: const Text('朗读'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1A73E8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton.icon(
                        onPressed: () => _onClearQuestion(question),
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('清除'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34A853),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Expand hint
                if (!isExpanded)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.expand_more, size: 20, color: Color(0xFF5F6368)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F6368),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList(List<WrongQuestionVO> questions) {
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: const Color(0xFF34A853).withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            const Text(
              '暂无错题记录',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF5F6368),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: questions.length + 1, // +1 for bottom padding
      itemBuilder: (context, index) {
        if (index == questions.length) {
          return const SizedBox(height: 16);
        }
        return _buildWrongQuestionCard(questions[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          '错题本',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202124),
        actions: [
          IconButton(
            onPressed: _onReadAll,
            icon: const Icon(Icons.volume_up),
            tooltip: '全部朗读',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF1A73E8),
          labelColor: const Color(0xFF1A73E8),
          unselectedLabelColor: const Color(0xFF5F6368),
          tabs: const [
            Tab(text: '未清除'),
            Tab(text: '已清除'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Color(0xFFEA4335)),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFF5F6368)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuestionList(_notClearedQuestions),
                    _buildQuestionList(_clearedQuestions),
                  ],
                ),
    );
  }
}
