// QuestionType enum for screen compatibility
enum QuestionType {
  singleChoice,
  multiChoice,
  judgement,
  calculation,
  comprehensive;

  static QuestionType fromString(String s) {
    switch (s) {
      case 'SINGLE_CHOICE': return QuestionType.singleChoice;
      case 'MULTI_CHOICE': return QuestionType.multiChoice;
      case 'JUDGEMENT': return QuestionType.judgement;
      case 'CALCULATION': return QuestionType.calculation;
      case 'COMPREHENSIVE': return QuestionType.comprehensive;
      default: return QuestionType.singleChoice;
    }
  }
}

// Screen-compatible Question wrapper
class Question {
  final int id;
  final QuestionType type;
  final String stem;
  final List<QuestionOption> options;
  final double score;
  final int sortOrder;

  Question({
    required this.id,
    required this.type,
    required this.stem,
    required this.options,
    this.score = 2.0,
    this.sortOrder = 0,
  });

  factory Question.fromQuestionVO(QuestionVO vo) {
    final opts = <QuestionOption>[];
    if (vo.optionA != null) opts.add(QuestionOption(label: 'A', text: vo.optionA!));
    if (vo.optionB != null) opts.add(QuestionOption(label: 'B', text: vo.optionB!));
    if (vo.optionC != null) opts.add(QuestionOption(label: 'C', text: vo.optionC!));
    if (vo.optionD != null) opts.add(QuestionOption(label: 'D', text: vo.optionD!));
    if (vo.optionE != null) opts.add(QuestionOption(label: 'E', text: vo.optionE!));
    return Question(
      id: vo.id,
      type: QuestionType.fromString(vo.questionType),
      stem: vo.stem,
      options: opts,
      score: vo.score,
      sortOrder: vo.sortOrder,
    );
  }

  static List<Question> fromQuestionVOList(List<QuestionVO> list) =>
      list.map((vo) => Question.fromQuestionVO(vo)).toList();
}

class QuestionOption {
  final String label;
  final String text;
  QuestionOption({required this.label, required this.text});
}

class QuestionVO {
  final int id;
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
      id: (json['id'] as num).toInt(),
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
      'id': id.toString(),
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
  final int questionId;
  final String? studentAnswer;
  final int timeSpentSec;

  SubmitAnswer({
    required this.questionId,
    this.studentAnswer,
    this.timeSpentSec = 0,
  });

  factory SubmitAnswer.fromJson(Map<String, dynamic> json) {
    return SubmitAnswer(
      questionId: (json['questionId'] as num).toInt(),
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
