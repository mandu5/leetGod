/// API 호출 결과를 나타내는 Result 타입
/// 
/// 성공/실패 상태를 명확히 구분하는 타입을 제공합니다.
sealed class Result<T> {
  const Result();
}

/// 성공 결과를 나타냅니다
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  String toString() => 'Success(data: $data)';
}

/// 실패 결과를 나타냅니다
class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  
  const Failure(this.message, [this.exception]);
  
  @override
  String toString() => 'Failure(message: $message, exception: $exception)';
}

/// Result 타입을 위한 확장 메서드들
extension ResultExtensions<T> on Result<T> {
  /// 성공 여부를 확인합니다
  bool get isSuccess => this is Success<T>;
  
  /// 실패 여부를 확인합니다
  bool get isFailure => this is Failure<T>;
  
  /// 성공 시 데이터를 반환하고, 실패 시 null을 반환합니다
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => null,
  };
  
  /// 실패 시 에러 메시지를 반환하고, 성공 시 null을 반환합니다
  String? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(message: final message) => message,
  };
  
  /// 성공 시 데이터를 반환하고, 실패 시 기본값을 반환합니다
  T dataOr(T defaultValue) => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => defaultValue,
  };
  
  /// 성공 시 데이터를 반환하고, 실패 시 예외를 던집니다
  T get dataOrThrow => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>(message: final message, exception: final exception) => 
      throw exception ?? Exception(message),
  };
}
