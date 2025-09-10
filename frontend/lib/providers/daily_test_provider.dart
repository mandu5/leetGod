import 'package:flutter/material.dart';
import 'package:leet_god/services/api_service.dart';
import 'package:leet_god/models/question.dart';

class DailyTestProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  DailyTest? _dailyTest;
  Map<int, String> _answers = {};
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _result;

  DailyTest? get dailyTest => _dailyTest;
  Map<int, String> get answers => _answers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get result => _result;

  Future<void> loadDailyTest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getDailyTest();
      
      // API 응답 구조 확인
      if (response['already_completed'] == true) {
        _error = "오늘의 모의고사를 이미 완료했습니다.";
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      if (response['daily_test'] != null) {
        _dailyTest = DailyTest.fromJson(response['daily_test']);
      } else {
        _error = "일일 모의고사를 불러올 수 없습니다.";
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void setAnswer(int questionId, String answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitDailyTest([Map<int, String>? answers]) async {
    final answersToSubmit = answers ?? _answers;
    
    if (answersToSubmit.isEmpty) {
      _error = "답안을 입력해주세요.";
      notifyListeners();
      throw Exception("답안을 입력해주세요.");
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _apiService.submitDailyTest(answersToSubmit);
      _isLoading = false;
      notifyListeners();
      return _result!;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _dailyTest = null;
    _answers.clear();
    _result = null;
    _error = null;
    notifyListeners();
  }

  int get progress {
    if (_dailyTest == null) return 0;
    final totalQuestions = _dailyTest!.questions.length;
    if (totalQuestions == 0) return 0;
    return ((_answers.length / totalQuestions) * 100).round();
  }

  bool get isCompleted {
    if (_dailyTest == null) return false;
    return _answers.length >= _dailyTest!.questions.length;
  }
} 