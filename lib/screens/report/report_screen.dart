import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../config/theme.dart';

class ReportScreen extends StatefulWidget {
  final ReportService? reportService;
  late final ReportService _service = reportService ?? ReportService(ApiClient());
  final String studentName;

  const ReportScreen({
    super.key,
    this.reportService,
    this.studentName = '',
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  StudentReport? _report;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getReport();
      setState(() {
        _report = StudentReport.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _masteryColor(String level) {
    switch (level) {
      case '精通':
        return AppTheme.excellent;
      case '熟练':
        return AppTheme.proficient;
      case '薄弱':
        return AppTheme.weak;
      case '短板':
        return AppTheme.gap;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _masteryLabel(String level) {
    switch (level) {
      case 'mastered':
        return '精通';
      case 'proficient':
        return '熟练';
      case 'weak':
        return '薄弱';
      case 'gap':
        return '短板';
      default:
        return level;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text(
          '能力分析报告',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    final report = _report!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewCard(report),
          const SizedBox(height: 12),
          _buildRadarChartCard(report),
          const SizedBox(height: 12),
          _buildBarChartCard(report),
          const SizedBox(height: 12),
          _buildLineChartCard(report),
          const SizedBox(height: 12),
          _buildStrengthsWeaknessesCard(report),
          const SizedBox(height: 12),
          _buildSuggestionCard(report),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── 1. Overview Card ──
  Widget _buildOverviewCard(StudentReport report) {
    final accuracyPercent = (report.overallAccuracyRate * 100).toStringAsFixed(1);
    final levelStats = report.knowledgeLevelStats;

    // Determine mastery labels from keys
    final masteryLabels = <String, int>{};
    levelStats.forEach((key, value) {
      masteryLabels[_masteryLabel(key)] = value;
    });

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Student name
            if (widget.studentName.isNotEmpty)
              Text(
                widget.studentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            if (widget.studentName.isNotEmpty)
              const SizedBox(height: 12),

            // Overall accuracy - large center
            const Text(
              '总正确率',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$accuracyPercent%',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _accuracyColor(report.overallAccuracyRate),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),

            // Level stats row
            if (masteryLabels.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: masteryLabels.entries.map((entry) {
                  final levelKey = levelStats.entries.firstWhere(
                    (e) => _masteryLabel(e.key) == entry.key,
                    orElse: () => MapEntry(entry.key, 0),
                  ).key;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _masteryColor(levelKey).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${entry.key}${entry.value}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _masteryColor(levelKey),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Color _accuracyColor(double rate) {
    if (rate >= 0.8) return AppTheme.excellent;
    if (rate >= 0.6) return AppTheme.proficient;
    if (rate >= 0.4) return AppTheme.weak;
    return AppTheme.gap;
  }

  // ── 2. Radar Chart Card ──
  Widget _buildRadarChartCard(StudentReport report) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.radar, size: 20, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  '各题型正确率',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Placeholder info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.radar, size: 48, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  const Text(
                    '雷达图 - 各题型正确率',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (report.radarChartData.isEmpty)
                    const Text(
                      '暂无数据',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  else
                    ...report.radarChartData.map((item) {
                      final pct = (item.accuracyRate * 100).toStringAsFixed(1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                item.questionType,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: item.accuracyRate,
                                  backgroundColor: AppTheme.divider,
                                  color: _accuracyColor(item.accuracyRate),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 50,
                              child: Text(
                                '$pct%',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _accuracyColor(item.accuracyRate),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 3. Bar Chart Card ──
  Widget _buildBarChartCard(StudentReport report) {
    final bars = report.barChartData;
    final maxWrongCount = bars.isEmpty
        ? 1
        : bars.map((e) => e.wrongCount).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, size: 20, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  '知识点错误次数排行',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (bars.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '暂无数据',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ...bars.map((item) {
                final ratio = maxWrongCount > 0 ? item.wrongCount / maxWrongCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          item.knowledgeName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color(0xFF1A73E8).withOpacity(0.15),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: ratio.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color(0xFF1A73E8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${item.wrongCount}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ── 4. Line Chart Card ──
  Widget _buildLineChartCard(StudentReport report) {
    final lines = report.lineChartData;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  '正确率趋势',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lines.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '暂无考试记录',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.bgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // A simple visual representation of dots and dashed lines
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildSimpleLineChart(lines),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Legend
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, size: 10, color: AppTheme.primary),
                        SizedBox(width: 4),
                        Text(
                          '正确率',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleLineChart(List<LineItem> items) {
    // Show date + accuracy as a simple dot-and-label representation
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final pct = (item.accuracyRate * 100).toStringAsFixed(0);
        final dateStr = DateFormat('MM/dd').format(item.examTime);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$pct%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (index < items.length - 1)
                Container(
                  width: 2,
                  height: 20,
                  color: AppTheme.primary.withOpacity(0.3),
                ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── 5. Strengths / Weaknesses Card ──
  Widget _buildStrengthsWeaknessesCard(StudentReport report) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.insights, size: 20, color: AppTheme.primary),
                SizedBox(width: 8),
                Text(
                  '强弱项分析',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Strengths
            if (report.strengths.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.excellent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '强项',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.excellent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...report.strengths.take(3).map((item) {
                final pct = (item.accuracyRate * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 18, color: AppTheme.excellent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.knowledgeName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.excellent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // Weaknesses
            if (report.weaknesses.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.danger,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '弱项',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...report.weaknesses.take(3).map((item) {
                final pct = (item.accuracyRate * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: AppTheme.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.knowledgeName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '错${item.wrongCount}次',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$pct%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.danger,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],

            if (report.strengths.isEmpty && report.weaknesses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '暂无分析数据',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── 6. Suggestion Card ──
  Widget _buildSuggestionCard(StudentReport report) {
    if (report.suggestionText == null || report.suggestionText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lightbulb_outline,
                size: 24,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '学习建议',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    report.suggestionText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
