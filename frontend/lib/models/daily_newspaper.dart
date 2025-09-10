class DailyNewspaper {
  final String id;
  final DateTime date;
  final String title;
  final String subtitle;
  final List<DailyProblem> problems;
  final int totalProblems;
  final int estimatedTime;

  DailyNewspaper({
    required this.id,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.problems,
    required this.totalProblems,
    required this.estimatedTime,
  });

  factory DailyNewspaper.fromJson(Map<String, dynamic> json) {
    return DailyNewspaper(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      subtitle: json['subtitle'],
      problems: (json['problems'] as List)
          .map((problem) => DailyProblem.fromJson(problem))
          .toList(),
      totalProblems: json['total_problems'],
      estimatedTime: json['estimated_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'subtitle': subtitle,
      'problems': problems.map((problem) => problem.toJson()).toList(),
      'total_problems': totalProblems,
      'estimated_time': estimatedTime,
    };
  }
}

class DailyProblem {
  final String id;
  final int number;
  final String subject;
  final String topic;
  final double difficulty;
  final int timeLimit;

  DailyProblem({
    required this.id,
    required this.number,
    required this.subject,
    required this.topic,
    required this.difficulty,
    required this.timeLimit,
  });

  factory DailyProblem.fromJson(Map<String, dynamic> json) {
    return DailyProblem(
      id: json['id'],
      number: json['number'],
      subject: json['subject'],
      topic: json['topic'],
      difficulty: json['difficulty'].toDouble(),
      timeLimit: json['time_limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'subject': subject,
      'topic': topic,
      'difficulty': difficulty,
      'time_limit': timeLimit,
    };
  }
}

class Subscription {
  final String id;
  final String userId;
  final String planType; // 'pro', 'basic', 'light'
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String status; // 'active', 'expired', 'cancelled'

  Subscription({
    required this.id,
    required this.userId,
    required this.planType,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      planType: json['plan_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      isActive: json['is_active'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_type': planType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'status': status,
    };
  }
} 