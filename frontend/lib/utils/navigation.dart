import 'package:flutter/material.dart';

/// 네비게이션 유틸리티 클래스
class NavigationUtils {
  /// 기본 페이지 전환 애니메이션
  static const Duration _defaultTransitionDuration = Duration(milliseconds: 300);
  static const Curve _defaultTransitionCurve = Curves.easeInOut;

  /// 화면을 푸시합니다 (기본 애니메이션)
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: transitionDuration ?? _defaultTransitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: transitionCurve ?? _defaultTransitionCurve)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// 화면을 푸시하고 이전 화면을 대체합니다
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: transitionDuration ?? _defaultTransitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: transitionCurve ?? _defaultTransitionCurve)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// 모든 화면을 제거하고 새로운 화면으로 이동합니다
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page, {
    Duration? transitionDuration,
    Curve? transitionCurve,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: transitionDuration ?? _defaultTransitionDuration,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).chain(CurveTween(curve: transitionCurve ?? _defaultTransitionCurve)),
            ),
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  /// 이전 화면으로 돌아갑니다
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// 모달 다이얼로그를 표시합니다
  static Future<T?> showModal<T extends Object?>(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: (context) => dialog,
    );
  }

  /// 바텀 시트를 표시합니다
  static Future<T?> showBottomSheet<T extends Object?>(
    BuildContext context,
    Widget bottomSheet, {
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => bottomSheet,
    );
  }

  /// 스낵바를 표시합니다
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }
}
