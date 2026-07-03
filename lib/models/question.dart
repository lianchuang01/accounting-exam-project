class QuestionVO {
  final String id;
  final String questionType;
  final String stem;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final String? optionE;
  final String difficulty;
  final double score;
  final int sortOrder;
  final String? sectionGroup;

  QuestionVO({
    required this.id,
    required this.questionType,
    required this.stem,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.optionE,
    this.difficulty = 'medium',
    this.score = 0.0,
    this.sortOrder = 0,
    this.sectionGroup,
  });

  factory QuestionVO.fromJson(Map<String, dynamic> json) {
    return QuestionVO(
      id: json['id'] as String,
      questionType: json['questionType'] as String,
      stem: json['stem'] as String,
      optionA: json['optionA'] as String?,
      optionB: json['optionB'] as String?,
      optionC: json['optionC'] as String?,
      optionD: json['optionD'] as String?,
      optionE: json['optionE'] as String?,
      difficulty: json['difficulty'] as String? ?? 'medium',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      sectionGroup: json['sectionGroup'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionType': questionType,
      'stem': stem,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'optionE': optionE,
      'difficulty': difficulty,
      'score': score,
      'sortOrder': sortOrder,
      'sectionGroup': sectionGroup,
    };
  }
}

class QuestionGroup {
  final String groupName;
  final List<QuestionVO> questions;

  QuestionGroup({
    required this.groupName,
    this.questions = const [],
  });

  factory QuestionGroup.fromJson(Map<String, dynamic> json) {
    return QuestionGroup(
      groupName: json['groupName'] as String,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionVO.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }
}

class SubmitAnswer {
  final String questionId;
  final String? studentAnswer;
  final int timeSpentSec;

  SubmitAnswer({
    required this.questionId,
    this.studentAnswer,
    this.timeSpentSec = 0,
  });

  factory SubmitAnswer.fromJson(Map<String, dynamic> json) {
    return SubmitAnswer(
      questionId: json['questionId'] as String,
      studentAnswer: json['studentAnswer'] as String?,
      timeSpentSec: (json['timeSpentSec'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'studentAnswer': studentAnswer,
      'timeSpentSec': timeSpentSec,
    };
  }
}
