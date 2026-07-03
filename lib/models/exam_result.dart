class GradedResult {
  final String examRecordId;
  final double totalScore;
  final double scoreObtained;
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final double accuracyRate;
  final int durationSeconds;
  final List<AnswerComparison> comparisons;

  GradedResult({
    required this.examRecordId,
    this.totalScore = 0.0,
    this.scoreObtained = 0.0,
    this.totalQuestions = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.accuracyRate = 0.0,
    this.durationSeconds = 0,
    this.comparisons = const [],
  });

  factory GradedResult.fromJson(Map<String, dynamic> json) {
    return GradedResult(
      examRecordId: json['examRecordId'] as String,
      totalScore: (json['totalScore'] as num?)?.toDouble() ?? 0.0,
      scoreObtained: (json['scoreObtained'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      comparisons: (json['comparisons'] as List<dynamic>?)
              ?.map((e) =>
                  AnswerComparison.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examRecordId': examRecordId,
      'totalScore': totalScore,
      'scoreObtained': scoreObtained,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracyRate': accuracyRate,
      'durationSeconds': durationSeconds,
      'comparisons': comparisons.map((e) => e.toJson()).toList(),
    };
  }
}

class AnswerComparison {
  final String questionId;
  final String questionType;
  final String stem;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final String? optionE;
  final String? studentAnswer;
  final String? correctAnswer;
  final String? analysis;
  final bool isCorrect;
  final double scoreObtained;
  final double score;

  AnswerComparison({
    required this.questionId,
    required this.questionType,
    required this.stem,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.optionE,
    this.studentAnswer,
    this.correctAnswer,
    this.analysis,
    this.isCorrect = false,
    this.scoreObtained = 0.0,
    this.score = 0.0,
  });

  factory AnswerComparison.fromJson(Map<String, dynamic> json) {
    return AnswerComparison(
      questionId: json['questionId'] as String,
      questionType: json['questionType'] as String,
      stem: json['stem'] as String,
      optionA: json['optionA'] as String?,
      optionB: json['optionB'] as String?,
      optionC: json['optionC'] as String?,
      optionD: json['optionD'] as String?,
      optionE: json['optionE'] as String?,
      studentAnswer: json['studentAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
      analysis: json['analysis'] as String?,
      isCorrect: json['isCorrect'] as bool? ?? false,
      scoreObtained: (json['scoreObtained'] as num?)?.toDouble() ?? 0.0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionType': questionType,
      'stem': stem,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'optionE': optionE,
      'studentAnswer': studentAnswer,
      'correctAnswer': correctAnswer,
      'analysis': analysis,
      'isCorrect': isCorrect,
      'scoreObtained': scoreObtained,
      'score': score,
    };
  }
}
