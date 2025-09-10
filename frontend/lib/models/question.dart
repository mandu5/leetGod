class Question {
  final int id;
  final String content;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String unit;
  final int difficulty;
  final int points;
  final List<String> tags;

  Question({
    required this.id,
    required this.content,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.unit,
    required this.difficulty,
    required this.points,
    required this.tags,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      content: json['content'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correct_answer'] ?? '',
      explanation: json['explanation'] ?? '',
      unit: json['unit'] ?? '',
      difficulty: json['difficulty'] ?? 1,
      points: json['points'] ?? 3,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'unit': unit,
      'difficulty': difficulty,
      'points': points,
      'tags': tags,
    };
  }
}

class DailyTest {
  final String userId;
  final List<Question> questions;
  final int totalQuestions;
  final int estimatedTime;
  final DateTime createdAt;

  DailyTest({
    required this.userId,
    required this.questions,
    required this.totalQuestions,
    required this.estimatedTime,
    required this.createdAt,
  });

  factory DailyTest.fromJson(Map<String, dynamic> json) {
    return DailyTest(
      userId: json['user_id'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      totalQuestions: json['total_questions'],
      estimatedTime: json['estimated_time'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'total_questions': totalQuestions,
      'estimated_time': estimatedTime,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 