/// 애플리케이션 전역 상수 정의
/// 
/// 매직 넘버와 하드코딩된 값들을 의미있는 상수로 정의하여
/// 코드의 가독성과 유지보수성을 향상시킵니다.
class AppConstants {
  // HTTP 관련 상수
  static const int httpSuccessMin = 200;
  static const int httpSuccessMax = 299;
  static const int httpOk = 200;
  
  // API 엔드포인트
  static const String authLoginEndpoint = '/auth/login';
  static const String authRegisterEndpoint = '/auth/register';
  static const String authProfileEndpoint = '/auth/profile';
  static const String diagnosticQuestionsEndpoint = '/diagnostic/questions';
  static const String diagnosticSubmitEndpoint = '/diagnostic/submit';
  static const String diagnosticResultEndpoint = '/diagnostic/result';
  static const String dailyTestEndpoint = '/daily-test';
  static const String dailyTestSubmitEndpoint = '/daily-test/submit';
  static const String analyticsDashboardEndpoint = '/analytics/dashboard';
  static const String analyticsWeeklyReportEndpoint = '/analytics/weekly-report';
  static const String wrongNotesEndpoint = '/wrong-notes';
  static const String voucherInfoEndpoint = '/voucher/info';
  static const String voucherPaymentHistoryEndpoint = '/voucher/payment-history';
  static const String voucherPaymentMethodEndpoint = '/voucher/payment-method';
  static const String voucherAvailableEndpoint = '/voucher/available';
  static const String healthEndpoint = '/health';
  
  // SharedPreferences 키
  static const String authTokenKey = 'auth_token';
  
  // 네비게이션 탭 인덱스
  static const int homeTabIndex = 0;
  static const int dailyTestTabIndex = 1;
  static const int analyticsTabIndex = 2;
  static const int profileTabIndex = 3;
  
  // 애니메이션 지속시간 (밀리초)
  static const int animationDurationFastMs = 200;
  static const int animationDurationNormalMs = 300;
  static const int animationDurationSlowMs = 500;
  
  // 네트워크 타임아웃 (초)
  static const int networkTimeoutSeconds = 30;
  
  // 페이지네이션
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // 유효성 검사
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxEmailLength = 100;
  
  // LEET 시험 관련 상수
  static const int leetMaxScore = 200;
  static const int leetPassingScore = 120;
  static const int leetQuestionCount = 15;
  static const int leetTimeLimitMinutes = 90;
  
  // 디버깅
  static const bool isDebugMode = true;
}
