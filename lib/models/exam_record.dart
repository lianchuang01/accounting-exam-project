class ExamRecord {
  final String id;
  final String studentId;
  final String paperId;
  final DateTime startTime;
  final DateTime? submitTime;
  final int durationSeconds;
  final double totalScore;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final double accuracyRate;
  final bool isAutoSubmit;
  final String status;

  ExamRecord({
    required this.id,
    required this.studentId,
    required this.paperId,
    required this.startTime,
    this.submitTime,
    this.durationSeconds = 0,
    this.totalScore = 0.0,
    this.totalQuestions = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.accuracyRate = 0.0,
    this.isAutoSubmit = false,
    this.status = 'in_progress',
  });

  factory ExamRecord.fromJson(Map<String, dynamic> json) {
    return ExamRecord(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      paperId: json['paperId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      submitTime: json['submitTime'] != null
          ? DateTime.parse(json['submitTime'] as String)
          : null,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      isAutoSubmit: json['isAutoSubmit'] as bool? ?? false,
      status: json['status'] as String? ?? 'in_progress',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'paperId': paperId,
      'startTime': startTime.toIso8601String(),
      'submitTime': submitTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'totalScore': totalScore,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracyRate': accuracyRate,
      'isAutoSubmit': isAutoSubmit,
      'status': status,
    };
  }
}
