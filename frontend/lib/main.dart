import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leet_god/providers/auth_provider.dart';
import 'package:leet_god/providers/diagnostic_provider.dart';
import 'package:leet_god/providers/daily_test_provider.dart';
import 'package:leet_god/providers/analytics_provider.dart';
import 'package:leet_god/providers/voucher_provider.dart';
import 'package:leet_god/providers/wrong_answer_provider.dart';
import 'package:leet_god/screens/splash_screen.dart';
import 'package:leet_god/utils/theme.dart';

void main() {
  runApp(const LeetGodApp());
}

class LeetGodApp extends StatelessWidget {
  const LeetGodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DiagnosticProvider()),
        ChangeNotifierProvider(create: (_) => DailyTestProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => WrongAnswerProvider()),
      ],
      child: MaterialApp(
        title: '리트의신',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
} 