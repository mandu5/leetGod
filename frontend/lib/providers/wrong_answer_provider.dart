/**
 * 오답 노트 상태 관리 Provider
 * 
 * 오답 노트의 상태와 비즈니스 로직을 관리합니다.
 */

import 'package:flutter/material.dart';
import '../models/wrong_answer.dart';
import '../services/api_service.dart';

class WrongAnswerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // 상태 변수들
  List<WrongAnswer> _wrongAnswers = [];
  WrongAnswerStats? _stats;
  List<WrongAnswer> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  
  // 필터링 상태
  WrongAnswerFilter _currentFilter = const WrongAnswerFilter();
  
  // Getters
  List<WrongAnswer> get wrongAnswers => _wrongAnswers;
  WrongAnswerStats? get stats => _stats;
  List<WrongAnswer> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  WrongAnswerFilter get currentFilter => _currentFilter;

  /// 오답 노트 목록 조회
  Future<void> loadWrongAnswers({WrongAnswerFilter? filter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (filter != null) {
        _currentFilter = filter;
      }
      
      final response = await _apiService.getWrongAnswers(_currentFilter);
      _wrongAnswers = (response['wrong_notes'] as List)
          .map((item) => WrongAnswer.fromJson(item))
          .toList();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 오답 노트 통계 조회
  Future<void> loadStats() async {
    try {
      final response = await _apiService.getWrongAnswerStats();
      _stats = WrongAnswerStats.fromJson(response);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 복습 추천 문제 조회
  Future<void> loadRecommendations({int limit = 10}) async {
    try {
      final response = await _apiService.getReviewRecommendations(limit: limit);
      _recommendations = (response['recommendations'] as List)
          .map((item) => WrongAnswer.fromJson(item))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 특정 오답 노트 상세 조회
  Future<WrongAnswer?> getWrongAnswerDetail(int wrongAnswerId) async {
    try {
      final response = await _apiService.getWrongAnswerDetail(wrongAnswerId);
      return WrongAnswer.fromJson(response);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// 오답 노트 문제 복습
  Future<bool> reviewWrongAnswer(int wrongAnswerId, WrongAnswerReview review) async {
    try {
      await _apiService.reviewWrongAnswer(wrongAnswerId, review.toJson());
      
      // 로컬 상태 업데이트
      final index = _wrongAnswers.indexWhere((item) => item.id == wrongAnswerId);
      if (index != -1) {
        final updatedItem = WrongAnswer(
          id: _wrongAnswers[index].id,
          questionId: _wrongAnswers[index].questionId,
          questionContent: _wrongAnswers[index].questionContent,
          userAnswer: _wrongAnswers[index].userAnswer,
          correctAnswer: _wrongAnswers[index].correctAnswer,
          explanation: _wrongAnswers[index].explanation,
          unit: _wrongAnswers[index].unit,
          subject: _wrongAnswers[index].subject,
          topic: _wrongAnswers[index].topic,
          difficulty: _wrongAnswers[index].difficulty,
          points: _wrongAnswers[index].points,
          sourceType: _wrongAnswers[index].sourceType,
          reviewCount: _wrongAnswers[index].reviewCount + 1,
          lastReviewedAt: DateTime.now(),
          mastered: _wrongAnswers[index].mastered,
          masteredAt: _wrongAnswers[index].masteredAt,
          createdAt: _wrongAnswers[index].createdAt,
        );
        
        _wrongAnswers[index] = updatedItem;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 오답 노트 항목 삭제
  Future<bool> deleteWrongAnswer(int wrongAnswerId) async {
    try {
      await _apiService.deleteWrongAnswer(wrongAnswerId);
      
      // 로컬 상태에서 제거
      _wrongAnswers.removeWhere((item) => item.id == wrongAnswerId);
      _recommendations.removeWhere((item) => item.id == wrongAnswerId);
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 필터 적용
  void applyFilter(WrongAnswerFilter filter) {
    _currentFilter = filter;
    loadWrongAnswers();
  }

  /// 필터 초기화
  void clearFilter() {
    _currentFilter = const WrongAnswerFilter();
    loadWrongAnswers();
  }

  /// 에러 메시지 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 과목별 필터링
  void filterBySubject(String? subject) {
    final newFilter = WrongAnswerFilter(
      subject: subject,
      unit: _currentFilter.unit,
      difficultyMin: _currentFilter.difficultyMin,
      difficultyMax: _currentFilter.difficultyMax,
      mastered: _currentFilter.mastered,
      sourceType: _currentFilter.sourceType,
      limit: _currentFilter.limit,
      offset: 0, // 새 필터 적용 시 첫 페이지로
    );
    applyFilter(newFilter);
  }

  /// 단원별 필터링
  void filterByUnit(String? unit) {
    final newFilter = WrongAnswerFilter(
      subject: _currentFilter.subject,
      unit: unit,
      difficultyMin: _currentFilter.difficultyMin,
      difficultyMax: _currentFilter.difficultyMax,
      mastered: _currentFilter.mastered,
      sourceType: _currentFilter.sourceType,
      limit: _currentFilter.limit,
      offset: 0,
    );
    applyFilter(newFilter);
  }

  /// 마스터 여부로 필터링
  void filterByMastered(bool? mastered) {
    final newFilter = WrongAnswerFilter(
      subject: _currentFilter.subject,
      unit: _currentFilter.unit,
      difficultyMin: _currentFilter.difficultyMin,
      difficultyMax: _currentFilter.difficultyMax,
      mastered: mastered,
      sourceType: _currentFilter.sourceType,
      limit: _currentFilter.limit,
      offset: 0,
    );
    applyFilter(newFilter);
  }

  /// 난이도로 필터링
  void filterByDifficulty(double? minDifficulty, double? maxDifficulty) {
    final newFilter = WrongAnswerFilter(
      subject: _currentFilter.subject,
      unit: _currentFilter.unit,
      difficultyMin: minDifficulty,
      difficultyMax: maxDifficulty,
      mastered: _currentFilter.mastered,
      sourceType: _currentFilter.sourceType,
      limit: _currentFilter.limit,
      offset: 0,
    );
    applyFilter(newFilter);
  }

  /// 페이지네이션 - 다음 페이지 로드
  Future<void> loadMore() async {
    if (_isLoading) return;

    final newFilter = WrongAnswerFilter(
      subject: _currentFilter.subject,
      unit: _currentFilter.unit,
      difficultyMin: _currentFilter.difficultyMin,
      difficultyMax: _currentFilter.difficultyMax,
      mastered: _currentFilter.mastered,
      sourceType: _currentFilter.sourceType,
      limit: _currentFilter.limit,
      offset: _currentFilter.offset + _currentFilter.limit,
    );

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getWrongAnswers(newFilter);
      final newItems = (response['wrong_notes'] as List)
          .map((item) => WrongAnswer.fromJson(item))
          .toList();
      
      _wrongAnswers.addAll(newItems);
      _currentFilter = newFilter;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    _currentFilter = WrongAnswerFilter(
      subject: _currentFilter.subject,
      unit: _currentFilter.unit,
      difficultyMin: _currentFilter.difficultyMin,
      difficultyMax: _currentFilter.difficultyMax,
      mastered: _currentFilter.mastered,
      sourceType: _currentFilter.sourceType,
      limit: _currentFilter.limit,
      offset: 0,
    );
    
    await Future.wait([
      loadWrongAnswers(),
      loadStats(),
      loadRecommendations(),
    ]);
  }
}
