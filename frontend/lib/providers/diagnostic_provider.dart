import 'package:flutter/material.dart';
import 'package:leet_god/services/api_service.dart';
import 'package:leet_god/models/question.dart';

class DiagnosticProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Question> _questions = [];
  Map<int, String> _answers = {};
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _result;

  List<Question> get questions => _questions;
  Map<int, String> get answers => _answers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get result => _result;

  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final questionsData = await _apiService.getDiagnosticQuestions();
      _questions = (questionsData['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadDiagnosticQuestions() async {
    await loadQuestions();
  }

  void setAnswer(int questionId, String answer) {
    _answers[questionId] = answer;
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }

  Future<Map<String, dynamic>> submitDiagnostic([Map<int, String>? answers]) async {
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
      _result = await _apiService.submitDiagnostic(answersToSubmit);
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

  Future<void> loadDiagnosticResult() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _result = await _apiService.getDiagnosticResult();
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
    _questions.clear();
    _answers.clear();
    _result = null;
    _error = null;
    notifyListeners();
  }
} 