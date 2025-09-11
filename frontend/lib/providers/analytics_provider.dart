import 'package:flutter/material.dart';
import 'package:leet_god/services/api_service.dart';
import 'package:leet_god/models/dashboard.dart';

class AnalyticsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Dashboard? _dashboard;
  Map<String, dynamic>? _weeklyReport;
  bool _isLoading = false;
  String? _error;

  Dashboard? get dashboard => _dashboard;
  Map<String, dynamic>? get weeklyReport => _weeklyReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final dashboardData = await _apiService.getDashboard();
      _dashboard = Dashboard.fromJson(dashboardData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadWeeklyReport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weeklyReport = await _apiService.getWeeklyReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _dashboard = null;
    _weeklyReport = null;
    _error = null;
    notifyListeners();
  }

  // 대시보드 데이터 헬퍼 메서드
  String get currentGrade {
    if (_dashboard == null) return "미정";
    return "${_dashboard!.userInfo.grade}점";
  }

  String get targetGrade {
    if (_dashboard == null) return "미정";
    return "${_dashboard!.userInfo.targetGrade}점";
  }

  int get totalTests {
    if (_dashboard == null) return 0;
    return _dashboard!.stats.totalQuestionsSolved;
  }

  double get averageScore {
    if (_dashboard == null) return 0.0;
    return _dashboard!.stats.averageScore;
  }

  int get consecutiveDays {
    if (_dashboard == null) return 0;
    return _dashboard!.stats.consecutiveDays;
  }

  int get totalWrongQuestions {
    if (_dashboard == null) return 0;
    return _dashboard!.stats.totalWrongQuestions;
  }

  String get progressTrend {
    if (_dashboard == null) return "stable";
    return "stable"; // 임시로 stable 반환
  }

  double get improvementRate {
    if (_dashboard == null) return 0.0;
    return 0.0; // 임시로 0.0 반환
  }
} 