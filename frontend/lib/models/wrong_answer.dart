/**
 * 오답 노트 관련 데이터 모델
 * 
 * 사용자가 틀린 문제들을 관리하고 복습할 수 있도록 하는
 * 오답 노트 시스템의 데이터 모델을 정의합니다.
 */

class WrongAnswer {
  final int id;
  final int questionId;
  final String questionContent;
  final String userAnswer;
  final String correctAnswer;
  final String? explanation;
  final String? unit;
  final String? subject;
  final String? topic;
  final double difficulty;
  final int points;
  final String sourceType;
  final int reviewCount;
  final DateTime? lastReviewedAt;
  final bool mastered;
  final DateTime? masteredAt;
  final DateTime createdAt;

  const WrongAnswer({
    required this.id,
    required this.questionId,
    required this.questionContent,
    required this.userAnswer,
    required this.correctAnswer,
    this.explanation,
    this.unit,
    this.subject,
    this.topic,
    required this.difficulty,
    required this.points,
    required this.sourceType,
    required this.reviewCount,
    this.lastReviewedAt,
    required this.mastered,
    this.masteredAt,
    required this.createdAt,
  });

  factory WrongAnswer.fromJson(Map<String, dynamic> json) {
    return WrongAnswer(
      id: json['id'],
      questionId: json['question_id'],
      questionContent: json['question_content'],
      userAnswer: json['user_answer'],
      correctAnswer: json['correct_answer'],
      explanation: json['explanation'],
      unit: json['unit'],
      subject: json['subject'],
      topic: json['topic'],
      difficulty: (json['difficulty'] ?? 3.0).toDouble(),
      points: json['points'] ?? 3,
      sourceType: json['source_type'] ?? 'daily_test',
      reviewCount: json['review_count'] ?? 0,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.parse(json['last_reviewed_at'])
          : null,
      mastered: json['mastered'] ?? false,
      masteredAt: json['mastered_at'] != null
          ? DateTime.parse(json['mastered_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'question_content': questionContent,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'unit': unit,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
      'points': points,
      'source_type': sourceType,
      'review_count': reviewCount,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'mastered': mastered,
      'mastered_at': masteredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 복습이 필요한지 확인
  bool get needsReview {
    if (mastered) return false;
    
    if (lastReviewedAt == null) return true;
    
    final daysSinceLastReview = DateTime.now().difference(lastReviewedAt!).inDays;
    return daysSinceLastReview >= 3;
  }

  /// 난이도 레벨 텍스트 반환
  String get difficultyText {
    if (difficulty <= 2.0) return '쉬움';
    if (difficulty <= 3.0) return '보통';
    if (difficulty <= 4.0) return '어려움';
    return '매우 어려움';
  }

  /// 출처 텍스트 반환
  String get sourceText {
    switch (sourceType) {
      case 'diagnostic':
        return '진단 평가';
      case 'daily_test':
        return '일일 모의고사';
      default:
        return '기타';
    }
  }
}

class WrongAnswerReview {
  final int id;
  final String userAnswer;
  final bool isCorrect;
  final int? timeTaken;
  final int? confidenceLevel;
  final String? notes;
  final DateTime createdAt;

  const WrongAnswerReview({
    required this.id,
    required this.userAnswer,
    required this.isCorrect,
    this.timeTaken,
    this.confidenceLevel,
    this.notes,
    required this.createdAt,
  });

  factory WrongAnswerReview.fromJson(Map<String, dynamic> json) {
    return WrongAnswerReview(
      id: json['id'],
      userAnswer: json['user_answer'],
      isCorrect: json['is_correct'],
      timeTaken: json['time_taken'],
      confidenceLevel: json['confidence_level'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'time_taken': timeTaken,
      'confidence_level': confidenceLevel,
      'notes': notes,
    };
  }
}

class WrongAnswerStats {
  final int totalCount;
  final int masteredCount;
  final int reviewNeededCount;
  final Map<String, int> bySubject;
  final Map<String, int> byUnit;
  final Map<String, int> byDifficulty;
  final List<WrongAnswerReview> recentReviews;

  const WrongAnswerStats({
    required this.totalCount,
    required this.masteredCount,
    required this.reviewNeededCount,
    required this.bySubject,
    required this.byUnit,
    required this.byDifficulty,
    required this.recentReviews,
  });

  factory WrongAnswerStats.fromJson(Map<String, dynamic> json) {
    return WrongAnswerStats(
      totalCount: json['total_count'] ?? 0,
      masteredCount: json['mastered_count'] ?? 0,
      reviewNeededCount: json['review_needed_count'] ?? 0,
      bySubject: Map<String, int>.from(json['by_subject'] ?? {}),
      byUnit: Map<String, int>.from(json['by_unit'] ?? {}),
      byDifficulty: Map<String, int>.from(json['by_difficulty'] ?? {}),
      recentReviews: (json['recent_reviews'] as List<dynamic>? ?? [])
          .map((review) => WrongAnswerReview.fromJson(review))
          .toList(),
    );
  }

  /// 마스터율 계산
  double get masteryRate {
    if (totalCount == 0) return 0.0;
    return masteredCount / totalCount;
  }

  /// 복습 필요율 계산
  double get reviewNeededRate {
    if (totalCount == 0) return 0.0;
    return reviewNeededCount / totalCount;
  }
}

class WrongAnswerFilter {
  final String? subject;
  final String? unit;
  final double? difficultyMin;
  final double? difficultyMax;
  final bool? mastered;
  final String? sourceType;
  final int limit;
  final int offset;

  const WrongAnswerFilter({
    this.subject,
    this.unit,
    this.difficultyMin,
    this.difficultyMax,
    this.mastered,
    this.sourceType,
    this.limit = 20,
    this.offset = 0,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };

    if (subject != null) params['subject'] = subject;
    if (unit != null) params['unit'] = unit;
    if (difficultyMin != null) params['difficulty_min'] = difficultyMin;
    if (difficultyMax != null) params['difficulty_max'] = difficultyMax;
    if (mastered != null) params['mastered'] = mastered;
    if (sourceType != null) params['source_type'] = sourceType;

    return params;
  }
}
