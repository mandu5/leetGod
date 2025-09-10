import 'package:flutter/material.dart';

/// 조건부 렌더링을 위한 유틸리티 위젯
/// 
/// 조건부 렌더링 로직을 명확하고 재사용 가능하게 만듭니다.
class ConditionalWidget extends StatelessWidget {
  final bool condition;
  final Widget trueWidget;
  final Widget? falseWidget;

  const ConditionalWidget({
    super.key,
    required this.condition,
    required this.trueWidget,
    this.falseWidget,
  });

  @override
  Widget build(BuildContext context) {
    return condition ? trueWidget : (falseWidget ?? const SizedBox.shrink());
  }
}

/// 사용자 상태에 따른 조건부 렌더링을 위한 전용 위젯
class UserConditionalWidget extends StatelessWidget {
  final bool? userExists;
  final Widget authenticatedWidget;
  final Widget? unauthenticatedWidget;
  final Widget? loadingWidget;

  const UserConditionalWidget({
    super.key,
    required this.userExists,
    required this.authenticatedWidget,
    this.unauthenticatedWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 사용자 상태에 따른 명확한 조건 분기
    if (userExists == null) {
      return loadingWidget ?? const CircularProgressIndicator();
    }
    
    if (userExists == true) {
      return authenticatedWidget;
    }
    
    return unauthenticatedWidget ?? const SizedBox.shrink();
  }
}

/// 진단 완료 상태에 따른 조건부 렌더링을 위한 전용 위젯
class DiagnosticConditionalWidget extends StatelessWidget {
  final bool? diagnosticCompleted;
  final Widget incompleteWidget;
  final Widget? completeWidget;

  const DiagnosticConditionalWidget({
    super.key,
    required this.diagnosticCompleted,
    required this.incompleteWidget,
    this.completeWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 진단 완료 상태에 따른 명확한 조건 분기
    final shouldShowDiagnostic = diagnosticCompleted == false;
    
    return shouldShowDiagnostic 
        ? incompleteWidget 
        : (completeWidget ?? const SizedBox.shrink());
  }
}
