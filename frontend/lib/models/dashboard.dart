class Dashboard {
  final UserInfo userInfo;
  final Stats stats;
  final Progress progress;
  final List<Activity> recentActivity;
  final List<String> recommendations;

  Dashboard({
    required this.userInfo,
    required this.stats,
    required this.progress,
    required this.recentActivity,
    required this.recommendations,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      userInfo: UserInfo.fromJson(json['user_info']),
      stats: Stats.fromJson(json['stats']),
      progress: Progress.fromJson(json['progress']),
      recentActivity: (json['recent_activity'] as List)
          .map((a) => Activity.fromJson(a))
          .toList(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_info': userInfo.toJson(),
      'stats': stats.toJson(),
      'progress': progress.toJson(),
      'recent_activity': recentActivity.map((a) => a.toJson()).toList(),
      'recommendations': recommendations,
    };
  }
}

class UserInfo {
  final String name;
  final String grade;
  final String targetGrade;
  final int studyTime;
  final String learningStyle;

  UserInfo({
    required this.name,
    required this.grade,
    required this.targetGrade,
    required this.studyTime,
    required this.learningStyle,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'],
      grade: json['grade'],
      targetGrade: json['target_grade'],
      studyTime: json['study_time'],
      learningStyle: json['learning_style'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
      'target_grade': targetGrade,
      'study_time': studyTime,
      'learning_style': learningStyle,
    };
  }
}

class Stats {
  final int totalStudyDays;
  final int consecutiveDays;
  final int totalQuestionsSolved;
  final double averageScore;
  final int totalWrongQuestions;
  final String strongestUnit;
  final String weakestUnit;
  final int currentStreak;
  final int bestStreak;

  Stats({
    required this.totalStudyDays,
    required this.consecutiveDays,
    required this.totalQuestionsSolved,
    required this.averageScore,
    required this.totalWrongQuestions,
    required this.strongestUnit,
    required this.weakestUnit,
    required this.currentStreak,
    required this.bestStreak,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalStudyDays: json['total_study_days'],
      consecutiveDays: json['consecutive_days'],
      totalQuestionsSolved: json['total_questions_solved'],
      averageScore: json['average_score'].toDouble(),
      totalWrongQuestions: json['total_wrong_questions'],
      strongestUnit: json['strongest_unit'],
      weakestUnit: json['weakest_unit'],
      currentStreak: json['current_streak'],
      bestStreak: json['best_streak'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_study_days': totalStudyDays,
      'consecutive_days': consecutiveDays,
      'total_questions_solved': totalQuestionsSolved,
      'average_score': averageScore,
      'total_wrong_questions': totalWrongQuestions,
      'strongest_unit': strongestUnit,
      'weakest_unit': weakestUnit,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
    };
  }
}

class Progress {
  final String currentGrade;
  final String targetGrade;
  final double progressPercentage;
  final int remainingGap;
  final String estimatedCompletion;

  Progress({
    required this.currentGrade,
    required this.targetGrade,
    required this.progressPercentage,
    required this.remainingGap,
    required this.estimatedCompletion,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      currentGrade: json['current_grade'],
      targetGrade: json['target_grade'],
      progressPercentage: json['progress_percentage'].toDouble(),
      remainingGap: json['remaining_gap'],
      estimatedCompletion: json['estimated_completion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_grade': currentGrade,
      'target_grade': targetGrade,
      'progress_percentage': progressPercentage,
      'remaining_gap': remainingGap,
      'estimated_completion': estimatedCompletion,
    };
  }
}

class Activity {
  final String type;
  final String title;
  final String description;
  final int? score;
  final DateTime timestamp;

  Activity({
    required this.type,
    required this.title,
    required this.description,
    this.score,
    required this.timestamp,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      type: json['type'],
      title: json['title'],
      description: json['description'],
      score: json['score'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'score': score,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 