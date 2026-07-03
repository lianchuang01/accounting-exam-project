class User {
  final String id;
  final String name;
  final String? studentNo;
  final String? phone;
  final String? email;
  final int totalExams;
  final int totalQuestions;
  final int totalCorrect;
  final int totalWrong;
  final double accuracyRate;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    this.studentNo,
    this.phone,
    this.email,
    this.totalExams = 0,
    this.totalQuestions = 0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
    this.accuracyRate = 0.0,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      studentNo: json['studentNo'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      totalExams: (json['totalExams'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      totalWrong: (json['totalWrong'] as num?)?.toInt() ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studentNo': studentNo,
      'phone': phone,
      'email': email,
      'totalExams': totalExams,
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
      'accuracyRate': accuracyRate,
      'isActive': isActive,
    };
  }
}
