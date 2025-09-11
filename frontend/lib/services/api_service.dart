import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leet_god/models/user.dart';
import 'package:leet_god/models/wrong_answer.dart';
import 'package:leet_god/constants/app_constants.dart';
import 'package:leet_god/utils/result.dart';

class ApiService {
  // 환경별 API URL 설정
  static const String _developmentBaseUrl = 'http://localhost:8000';
  static const String _productionBaseUrl = 'https://api.leetgod.com';
  
  // 현재 환경에 따른 기본 URL (개발 환경으로 설정)
  static const String baseUrl = _developmentBaseUrl;
  
  // HTTP 상태 코드는 AppConstants에서 가져옴

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.authTokenKey);
    
    print('Getting headers with token: $token'); // 디버깅용
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// HTTP 응답을 Result 타입으로 변환합니다
  Future<Result<dynamic>> _handleResponse(http.Response response) async {
    final isSuccessResponse = response.statusCode >= AppConstants.httpSuccessMin && 
                             response.statusCode <= AppConstants.httpSuccessMax;
    
    if (isSuccessResponse) {
      final data = json.decode(response.body);
      return Success(data);
    } else {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['detail'] ?? '요청 처리 중 오류가 발생했습니다.';
      return Failure(errorMessage);
    }
  }

  // 인증 관련 API (기존 호환성 유지)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final headers = await _getHeaders();
    headers.remove('Authorization'); // 로그인 시에는 토큰 불필요
    headers['Content-Type'] = 'application/x-www-form-urlencoded'; // Form 데이터로 변경

    final response = await http.post(
      Uri.parse('$baseUrl${AppConstants.authLoginEndpoint}'),
      headers: headers,
      body: 'email=$email&password=$password', // Form 데이터 형식으로 변경
    );

    final result = await _handleResponse(response);
    return result.dataOrThrow;
  }

  Future<User> register(UserCreate userData) async {
    final headers = await _getHeaders();
    headers.remove('Authorization'); // 회원가입 시에는 토큰 불필요

    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: headers,
      body: json.encode(userData.toJson()),
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return User.fromJson(result.dataOrThrow);
    } else {
      throw Exception(result.errorOrNull ?? '회원가입에 실패했습니다.');
    }
  }

  Future<User> getUserProfile() async {
    final headers = await _getHeaders();
    print('Profile request headers: $headers'); // 디버깅용
    
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: headers,
    );
    
    print('Profile response status: ${response.statusCode}'); // 디버깅용
    print('Profile response body: ${response.body}'); // 디버깅용

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return User.fromJson(result.dataOrThrow);
    } else {
      throw Exception(result.errorOrNull ?? '프로필 조회에 실패했습니다.');
    }
  }

  Future<User> updateUserProfile(Map<String, dynamic> updateData) async {
    final headers = await _getHeaders();
    
    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: headers,
      body: json.encode(updateData),
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return User.fromJson(result.dataOrThrow);
    } else {
      throw Exception(result.errorOrNull ?? '프로필 업데이트에 실패했습니다.');
    }
  }

  // 진단 평가 관련 API
  Future<Map<String, dynamic>> getDiagnosticQuestions() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/diagnostic/questions'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '진단 문제 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> submitDiagnostic(Map<int, String> answers) async {
    final headers = await _getHeaders();
    
    // Map<int, String>을 Map<String, String>으로 변환
    final answersMap = answers.map((key, value) => MapEntry(key.toString(), value));
    
    final response = await http.post(
      Uri.parse('$baseUrl/diagnostic/submit'),
      headers: headers,
      body: json.encode({'answers': answersMap}),
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '진단 제출에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getDiagnosticResult() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/diagnostic/result'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '진단 결과 조회에 실패했습니다.');
    }
  }

  // 일일 모의고사 관련 API
  Future<Map<String, dynamic>> getDailyTest() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/daily-test'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '일일 모의고사 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> submitDailyTest(Map<int, String> answers) async {
    final headers = await _getHeaders();
    
    // Map<int, String>을 Map<String, String>으로 변환
    final answersMap = answers.map((key, value) => MapEntry(key.toString(), value));
    
    final response = await http.post(
      Uri.parse('$baseUrl/daily-test/submit'),
      headers: headers,
      body: json.encode({'answers': answersMap}),
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '일일 모의고사 제출에 실패했습니다.');
    }
  }

  // 분석 및 통계 관련 API
  Future<Map<String, dynamic>> getDashboard() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/dashboard'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '대시보드 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getWeeklyReport() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/analytics/weekly-report'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '주간 리포트 조회에 실패했습니다.');
    }
  }

  // 오답 노트 관련 API
  Future<Map<String, dynamic>> getWrongAnswers(WrongAnswerFilter filter) async {
    final headers = await _getHeaders();
    final queryParams = filter.toQueryParams();
    
    final uri = Uri.parse('$baseUrl/wrong-notes').replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );
    
    final response = await http.get(uri, headers: headers);

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '오답 노트 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getWrongAnswerDetail(int wrongAnswerId) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/wrong-notes/$wrongAnswerId'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '오답 노트 상세 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> reviewWrongAnswer(int wrongAnswerId, Map<String, dynamic> reviewData) async {
    final headers = await _getHeaders();
    
    final response = await http.post(
      Uri.parse('$baseUrl/wrong-notes/$wrongAnswerId/review'),
      headers: headers,
      body: jsonEncode(reviewData),
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '오답 노트 복습에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getWrongAnswerStats() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/wrong-notes/stats'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '오답 노트 통계 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getReviewRecommendations({int limit = 10}) async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/wrong-notes/recommendations?limit=$limit'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '복습 추천 조회에 실패했습니다.');
    }
  }

  Future<void> deleteWrongAnswer(int wrongAnswerId) async {
    final headers = await _getHeaders();
    
    final response = await http.delete(
      Uri.parse('$baseUrl/wrong-notes/$wrongAnswerId'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (!result.isSuccess) {
      throw Exception(result.errorOrNull ?? '오답 노트 삭제에 실패했습니다.');
    }
  }

  // 이용권 관련 API
  Future<Map<String, dynamic>> getVoucherInfo() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/voucher/info'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '이용권 정보 조회에 실패했습니다.');
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/voucher/payment-history'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return List<Map<String, dynamic>>.from(result.dataOrThrow);
    } else {
      throw Exception(result.errorOrNull ?? '결제 내역 조회에 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>> getPaymentMethod() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/voucher/payment-method'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return result.dataOrThrow;
    } else {
      throw Exception(result.errorOrNull ?? '결제 수단 조회에 실패했습니다.');
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableVouchers() async {
    final headers = await _getHeaders();
    
    final response = await http.get(
      Uri.parse('$baseUrl/voucher/available'),
      headers: headers,
    );

    final result = await _handleResponse(response);
    if (result.isSuccess) {
      return List<Map<String, dynamic>>.from(result.dataOrThrow);
    } else {
      throw Exception(result.errorOrNull ?? '이용 가능한 이용권 조회에 실패했습니다.');
    }
  }

  // 헬스 체크
  Future<bool> checkServerHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == AppConstants.httpOk;
    } catch (e) {
      return false;
    }
  }

  // ===== 새로운 Result 타입을 사용하는 API 메서드들 =====
  
  /// 로그인 (Result 타입 사용)
  Future<Result<dynamic>> loginWithResult(String email, String password) async {
    try {
      final headers = await _getHeaders();
      headers.remove('Authorization');
      headers['Content-Type'] = 'application/x-www-form-urlencoded';

      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.authLoginEndpoint}'),
        headers: headers,
        body: 'email=$email&password=$password',
      );

      return await _handleResponse(response);
    } catch (e) {
      return Failure('로그인 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 사용자 프로필 조회 (Result 타입 사용)
  Future<Result<User>> getUserProfileWithResult() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.authProfileEndpoint}'),
        headers: headers,
      );

      final result = await _handleResponse(response);
      if (result.isSuccess) {
        final user = User.fromJson(result.dataOrThrow);
        return Success(user);
      } else {
        return Failure(result.errorOrNull ?? '사용자 정보를 가져올 수 없습니다');
      }
    } catch (e) {
      return Failure('사용자 정보 조회 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  /// 서버 헬스 체크 (Result 타입 사용)
  Future<Result<bool>> checkServerHealthWithResult() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );
      
      final isHealthy = response.statusCode == AppConstants.httpOk;
      return Success(isHealthy);
    } catch (e) {
      return Failure('서버 연결을 확인할 수 없습니다: ${e.toString()}');
    }
  }
} 