import 'question.dart';

class ExamPaper {
  int get year => int.tryParse(yearSource ?? '') ?? 0;
  int get totalQuestions => questionCount ?? 0;
  final int id;
  final String title;
  final String paperType;
  final String? yearSource;
  final double totalScore;
  final int durationMinutes;
  final int questionCount;
  final double? predictedHitRate;
  final String status;
  final DateTime? publishedAt;
  final List<QuestionGroup> groups;

  ExamPaper({
    required this.id,
    required this.title,
    required this.paperType,
    this.yearSource,
    this.totalScore = 0.0,
    this.durationMinutes = 0,
    this.questionCount = 0,
    this.predictedHitRate,
    this.status = 'draft',
    this.publishedAt,
    this.groups = const [],
  });

  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      paperType: json['paperType'] as String,
      yearSource: json['yearSource'] as String?,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 0,
      predictedHitRate: (json['predictedHitRate'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'draft',
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'] as String)
          : null,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) =>
                  QuestionGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'paperType': paperType,
      'yearSource': yearSource,
      'totalScore': totalScore,
      'durationMinutes': durationMinutes,
      'questionCount': questionCount,
      'predictedHitRate': predictedHitRate,
      'status': status,
      'publishedAt': publishedAt?.toIso8601String(),
      'groups': groups.map((e) => e.toJson()).toList(),
    };
  }
}
