import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leet_god/services/api_service.dart';
import 'package:leet_god/models/user.dart';
import 'package:leet_god/constants/app_constants.dart';
import 'package:leet_god/utils/result.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn {
    final hasValidToken = _token != null;
    final hasUserData = _user != null;
    return hasValidToken && hasUserData;
  }

  final ApiService _apiService = ApiService();

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(AppConstants.authTokenKey);
      
      final hasStoredToken = _token != null;
      if (hasStoredToken) {
        // 토큰이 있으면 사용자 정보 로드
        await _loadUserInfo();
      }
    } catch (e) {
      _error = '인증 정보 로드 중 오류가 발생했습니다.';
      notifyListeners();
    }
  }

  Future<void> _loadUserInfo() async {
    try {
      _user = await _apiService.getUserProfile();
      notifyListeners();
    } catch (e) {
      _error = '사용자 정보 로드 중 오류가 발생했습니다.';
      _token = null;
      notifyListeners();
    }
  }

  Future<bool> checkLoginStatus() async {
    await _loadStoredAuth();
    return isLoggedIn;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      print('Login response: $response'); // 디버깅용
      
      _token = response['access_token'];
      print('Token: $_token'); // 디버깅용
      
      // 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, _token!);
      print('Token saved to SharedPreferences'); // 디버깅용

      // 사용자 정보 로드
      _user = await _apiService.getUserProfile();
      print('User loaded: ${_user?.email}'); // 디버깅용

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      print('Login error: $_error'); // 디버깅용
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(UserCreate userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(userData);
      _user = response;
      
      // 회원가입 후 자동 로그인
      final loginResponse = await _apiService.login(userData.email, userData.password);
      _token = loginResponse['access_token'];

      // 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // 로컬 저장소에서 토큰 제거
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      
      _token = null;
      _user = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '로그아웃 중 오류가 발생했습니다.';
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updateData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _apiService.updateUserProfile(updateData);
      _user = updatedUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ===== 새로운 Result 타입을 사용하는 메서드들 =====
  
  /// 로그인 (Result 타입 사용)
  Future<Result<bool>> loginWithResult(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.loginWithResult(email, password);
      
      if (result.isSuccess) {
        final response = result.dataOrThrow;
        _token = response['access_token'];
        
        // 토큰 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.authTokenKey, _token!);

        // 사용자 정보 로드
        final userResult = await _apiService.getUserProfileWithResult();
        if (userResult.isSuccess) {
          _user = userResult.dataOrThrow;
          _isLoading = false;
          notifyListeners();
          return const Success(true);
        } else {
          _error = userResult.errorOrNull;
          _isLoading = false;
          notifyListeners();
          return Failure(userResult.errorOrNull ?? '사용자 정보를 가져올 수 없습니다');
        }
      } else {
        _error = result.errorOrNull;
        _isLoading = false;
        notifyListeners();
        return Failure(result.errorOrNull ?? '로그인에 실패했습니다');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return Failure('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 사용자 정보 로드 (Result 타입 사용)
  Future<Result<User>> loadUserInfoWithResult() async {
    try {
      final result = await _apiService.getUserProfileWithResult();
      
      if (result.isSuccess) {
        _user = result.dataOrThrow;
        notifyListeners();
        return result;
      } else {
        _error = result.errorOrNull;
        _token = null;
        notifyListeners();
        return result;
      }
    } catch (e) {
      _error = '사용자 정보 로드 중 오류가 발생했습니다.';
      _token = null;
      notifyListeners();
      return Failure('사용자 정보 로드 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
} 