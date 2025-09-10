class User {
  final int id;
  final String email;
  final String name;
  final String? grade;
  final String? targetGrade;
  final int? studyTime;
  final String? learningStyle;
  final bool diagnosticCompleted;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.grade,
    this.targetGrade,
    this.studyTime,
    this.learningStyle,
    required this.diagnosticCompleted,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      grade: json['grade']?.toString(),
      targetGrade: json['target_grade']?.toString(),
      studyTime: json['study_time'],
      learningStyle: json['learning_style'],
      diagnosticCompleted: json['diagnostic_completed'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'grade': grade,
      'target_grade': targetGrade,
      'study_time': studyTime,
      'learning_style': learningStyle,
      'diagnostic_completed': diagnosticCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? name,
    String? grade,
    String? targetGrade,
    int? studyTime,
    String? learningStyle,
    bool? diagnosticCompleted,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      targetGrade: targetGrade ?? this.targetGrade,
      studyTime: studyTime ?? this.studyTime,
      learningStyle: learningStyle ?? this.learningStyle,
      diagnosticCompleted: diagnosticCompleted ?? this.diagnosticCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserCreate {
  final String email;
  final String password;
  final String name;
  final String? grade;
  final String? targetGrade;
  final int? studyTime;
  final String? learningStyle;

  UserCreate({
    required this.email,
    required this.password,
    required this.name,
    this.grade,
    this.targetGrade,
    this.studyTime,
    this.learningStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'grade': grade,
      'target_grade': targetGrade,
      'study_time': studyTime,
      'learning_style': learningStyle,
    };
  }
} 