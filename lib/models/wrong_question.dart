class WrongQuestionVO {
  final int id;
  final int questionId;
  final int wrongCount;
  final bool isCleared;
  final DateTime? lastWrongAt;
  final String stem;
  final String? studentAnswer;
  final String? correctAnswer;
  final String? analysis;
  final List<String> knowledgeTags;

  WrongQuestionVO({
    required this.id,
    required this.questionId,
    this.wrongCount = 0,
    this.isCleared = false,
    this.lastWrongAt,
    required this.stem,
    this.studentAnswer,
    this.correctAnswer,
    this.analysis,
    this.knowledgeTags = const [],
  });

  factory WrongQuestionVO.fromJson(Map<String, dynamic> json) {
    return WrongQuestionVO(
      id: (json['id'] as num).toInt(),
      questionId: (json['questionId'] as num).toInt(),
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      isCleared: json['isCleared'] as bool? ?? false,
      lastWrongAt: json['lastWrongAt'] != null
          ? DateTime.parse(json['lastWrongAt'] as String)
          : null,
      stem: json['stem'] as String,
      studentAnswer: json['studentAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String?,
      analysis: json['analysis'] as String?,
      knowledgeTags: (json['knowledgeTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'wrongCount': wrongCount,
      'isCleared': isCleared,
      'lastWrongAt': lastWrongAt?.toIso8601String(),
      'stem': stem,
      'studentAnswer': studentAnswer,
      'correctAnswer': correctAnswer,
      'analysis': analysis,
      'knowledgeTags': knowledgeTags,
    };
  }
}
