class StudentReport {
  final double overallAccuracyRate;
  final Map<String, int> knowledgeLevelStats;
  final List<RadarItem> radarChartData;
  final List<BarItem> barChartData;
  final List<LineItem> lineChartData;
  final List<StrengthItem> strengths;
  final List<WeaknessItem> weaknesses;
  final String? suggestionText;

  StudentReport({
    this.overallAccuracyRate = 0.0,
    this.knowledgeLevelStats = const {},
    this.radarChartData = const [],
    this.barChartData = const [],
    this.lineChartData = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.suggestionText,
  });

  factory StudentReport.fromJson(Map<String, dynamic> json) {
    return StudentReport(
      overallAccuracyRate:
          (json['overallAccuracyRate'] as num?)?.toDouble() ?? 0.0,
      knowledgeLevelStats:
          (json['knowledgeLevelStats'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
              {},
      radarChartData: (json['radarChartData'] as List<dynamic>?)
              ?.map((e) => RadarItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      barChartData: (json['barChartData'] as List<dynamic>?)
              ?.map((e) => BarItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lineChartData: (json['lineChartData'] as List<dynamic>?)
              ?.map((e) => LineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => StrengthItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => WeaknessItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suggestionText: json['suggestionText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallAccuracyRate': overallAccuracyRate,
      'knowledgeLevelStats': knowledgeLevelStats,
      'radarChartData': radarChartData.map((e) => e.toJson()).toList(),
      'barChartData': barChartData.map((e) => e.toJson()).toList(),
      'lineChartData': lineChartData.map((e) => e.toJson()).toList(),
      'strengths': strengths.map((e) => e.toJson()).toList(),
      'weaknesses': weaknesses.map((e) => e.toJson()).toList(),
      'suggestionText': suggestionText,
    };
  }
}

class RadarItem {
  final String questionType;
  final double accuracyRate;

  RadarItem({
    required this.questionType,
    this.accuracyRate = 0.0,
  });

  factory RadarItem.fromJson(Map<String, dynamic> json) {
    return RadarItem(
      questionType: json['questionType'] as String,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionType': questionType,
      'accuracyRate': accuracyRate,
    };
  }
}

class BarItem {
  final String knowledgeName;
  final int wrongCount;

  BarItem({
    required this.knowledgeName,
    this.wrongCount = 0,
  });

  factory BarItem.fromJson(Map<String, dynamic> json) {
    return BarItem(
      knowledgeName: json['knowledgeName'] as String,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knowledgeName': knowledgeName,
      'wrongCount': wrongCount,
    };
  }
}

class LineItem {
  final int examRecordId;
  final DateTime examTime;
  final double accuracyRate;

  LineItem({
    required this.examRecordId,
    required this.examTime,
    this.accuracyRate = 0.0,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      examRecordId: (json['examRecordId'] as num).toInt(),
      examTime: DateTime.parse(json['examTime'] as String),
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'examRecordId': examRecordId,
      'examTime': examTime.toIso8601String(),
      'accuracyRate': accuracyRate,
    };
  }
}

class StrengthItem {
  final String knowledgeName;
  final double accuracyRate;

  StrengthItem({
    required this.knowledgeName,
    this.accuracyRate = 0.0,
  });

  factory StrengthItem.fromJson(Map<String, dynamic> json) {
    return StrengthItem(
      knowledgeName: json['knowledgeName'] as String,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knowledgeName': knowledgeName,
      'accuracyRate': accuracyRate,
    };
  }
}

class WeaknessItem {
  final String knowledgeName;
  final int wrongCount;
  final double accuracyRate;

  WeaknessItem({
    required this.knowledgeName,
    this.wrongCount = 0,
    this.accuracyRate = 0.0,
  });

  factory WeaknessItem.fromJson(Map<String, dynamic> json) {
    return WeaknessItem(
      knowledgeName: json['knowledgeName'] as String,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knowledgeName': knowledgeName,
      'wrongCount': wrongCount,
      'accuracyRate': accuracyRate,
    };
  }
}

class KnowledgeMasteryVO {
  final int knowledgeId;
  final String knowledgeName;
  final String? chapter;
  final int totalAttempts;
  final int correctCount;
  final int wrongCount;
  final double accuracyRate;
  final String masteryLevel;

  KnowledgeMasteryVO({
    required this.knowledgeId,
    required this.knowledgeName,
    this.chapter,
    this.totalAttempts = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.accuracyRate = 0.0,
    this.masteryLevel = 'unknown',
  });

  factory KnowledgeMasteryVO.fromJson(Map<String, dynamic> json) {
    return KnowledgeMasteryVO(
      knowledgeId: (json['knowledgeId'] as num).toInt(),
      knowledgeName: json['knowledgeName'] as String,
      chapter: json['chapter'] as String?,
      totalAttempts: (json['totalAttempts'] as num?)?.toInt() ?? 0,
      correctCount: (json['correctCount'] as num?)?.toInt() ?? 0,
      wrongCount: (json['wrongCount'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      masteryLevel: json['masteryLevel'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'knowledgeId': knowledgeId,
      'knowledgeName': knowledgeName,
      'chapter': chapter,
      'totalAttempts': totalAttempts,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracyRate': accuracyRate,
      'masteryLevel': masteryLevel,
    };
  }
}
