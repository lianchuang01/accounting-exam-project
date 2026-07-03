import 'package:flutter/material.dart';
import '../../models/exam_paper.dart';
import '../../services/api_client.dart';
import '../../services/exam_service.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExamService _examService = ExamService(ApiClient());
  bool _isLoading = true;
  List<ExamPaper> _simulationPapers = [];
  List<ExamPaper> _officialPapers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchPapers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchPapers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final papers = await _examService.getPapers(1);
      setState(() {
        _simulationPapers = papers.where((p) => p.paperType == "SIMULATION").toList().cast<ExamPaper>();
        _officialPapers = papers.where((p) => p.paperType == "OFFICIAL").toList().cast<ExamPaper>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败，请下拉刷新重试';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择试卷'),
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
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          tabs: const [
            Tab(text: '仿真试卷'),
            Tab(text: '正式试卷'),
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
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPapers,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPapers,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPaperList(_simulationPapers, isSimulation: true),
                      _buildPaperList(_officialPapers, isSimulation: false),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPaperList(List<ExamPaper> papers, {required bool isSimulation}) {
    if (papers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSimulation ? Icons.science_outlined : Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isSimulation ? '暂无仿真试卷' : '暂无正式试卷',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: papers.length,
      itemBuilder: (context, index) {
        final paper = papers[index];
        return _buildPaperCard(context, paper, isSimulation: isSimulation);
      },
    );
  }

  Widget _buildPaperCard(BuildContext context, ExamPaper paper,
      {required bool isSimulation}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSimulation ? const Color(0xFF1A73E8).withOpacity(0.2) : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showStartDialog(context, paper),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSimulation
                          ? const Color(0xFF1A73E8).withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isSimulation ? '仿真' : '正式',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSimulation ? const Color(0xFF1A73E8) : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      paper.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSimulation && paper.predictedHitRate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '预测命中 ${paper.predictedHitRate!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.calendar_today, '${paper.year}年'),
                  const SizedBox(width: 16),
                  _buildInfoChip(Icons.quiz_outlined, '${paper.totalQuestions}题'),
                  const SizedBox(width: 16),
                  _buildInfoChip(Icons.timer_outlined, '${paper.durationMinutes}分钟'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }

  void _showStartDialog(BuildContext context, ExamPaper paper) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('开始答题'),
        content: Text('考试限时${paper.durationMinutes}分钟，共${paper.totalQuestions}题。\n开始答题后将自动计时，请做好准备。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
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
              Navigator.pushNamed(
                context,
                '/exam-taking',
                arguments: paper.id,
              );
            },
            child: const Text('开始答题'),
          ),
        ],
      ),
    );
  }
}
