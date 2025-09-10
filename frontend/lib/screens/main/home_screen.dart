import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leet_god/providers/auth_provider.dart';
import 'package:leet_god/providers/diagnostic_provider.dart';
import 'package:leet_god/providers/daily_test_provider.dart';
import 'package:leet_god/providers/analytics_provider.dart';
import 'package:leet_god/screens/diagnostic/diagnostic_screen.dart';
import 'package:leet_god/screens/daily_test/daily_test_screen.dart';
import 'package:leet_god/screens/analytics/dashboard_screen.dart';
import 'package:leet_god/screens/profile/profile_screen.dart';
import 'package:leet_god/utils/theme.dart';
import 'package:leet_god/constants/app_constants.dart';
import 'package:leet_god/widgets/common/action_card.dart';
import 'package:leet_god/widgets/common/activity_item.dart';
import 'package:leet_god/widgets/common/conditional_widget.dart';
import 'package:leet_god/utils/navigation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = AppConstants.homeTabIndex;

  final List<Widget> _screens = [
    const _HomeTab(),
    const _DailyTestTab(),
    const _AnalyticsTab(),
    const _ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: '일일 리트 모의고사',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '분석',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('리트의신'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 알림 화면으로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 환영 메시지
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return _WelcomeCard(user: user);
              },
            ),
            
            const SizedBox(height: AppTheme.spacingXXL),
            
            // 진단 평가 섹션
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;
                return DiagnosticConditionalWidget(
                  diagnosticCompleted: user?.diagnosticCompleted,
                  incompleteWidget: const _DiagnosticSection(),
                );
              },
            ),
            
            const SizedBox(height: AppTheme.spacingXXL),
            
            // 오늘의 학습
            _TodayLearningSection(),
            
            const SizedBox(height: AppTheme.spacingXXL),
            
            // 빠른 액션
            _QuickActionsSection(),
            
            const SizedBox(height: AppTheme.spacingXXL),
            
            // 최근 활동
            _RecentActivitySection(),
          ],
        ),
      ),
    );
  }
}

/// 사용자 환영 메시지를 표시하는 카드 위젯
class _WelcomeCard extends StatelessWidget {
  final dynamic user;

  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingText(context),
            const SizedBox(height: AppTheme.spacingSM),
            _buildMotivationText(context),
          ],
        ),
      ),
    );
  }

  /// 인사말 텍스트를 빌드합니다
  Widget _buildGreetingText(BuildContext context) {
    final userName = user?.name ?? '수험생';
    return Text(
      '안녕하세요, ${userName}님!',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  /// 동기부여 텍스트를 빌드합니다
  Widget _buildMotivationText(BuildContext context) {
    return Text(
      '오늘도 리트 시험 합격을 위해 함께해요!',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondaryColor,
      ),
    );
  }
}

class _DiagnosticSection extends StatelessWidget {
  const _DiagnosticSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSM),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(AppTheme.opacityLight),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSM),
                  ),
                  child: const Icon(
                    Icons.gavel,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI 진단 평가',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '현재 리트 실력을 정확히 파악해보세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLG),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => NavigationUtils.push(context, const DiagnosticScreen()),
                child: const Text('진단 평가 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayLearningSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '오늘의 학습',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingLG),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.article,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '일일 리트 모의고사',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'AI가 추천하는 맞춤형 리트 문제',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLG),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => NavigationUtils.push(context, const DailyTestScreen()),
                    child: const Text('모의고사 시작하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingLG),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: AppTheme.quickActionGridColumns,
          crossAxisSpacing: AppTheme.spacingLG,
          mainAxisSpacing: AppTheme.spacingLG,
          childAspectRatio: AppTheme.quickActionCardAspectRatio,
          children: [
            ActionCard(
              icon: Icons.analytics,
              title: '학습 분석',
              subtitle: '리트 점수 추이 확인',
              color: AppTheme.accentColor,
              onTap: () => _navigateToDashboard(context),
            ),
            ActionCard(
              icon: Icons.book,
              title: '오답 노트',
              subtitle: '틀린 문제 복습',
              color: AppTheme.warningColor,
              onTap: () => _navigateToWrongNotes(context),
            ),
            ActionCard(
              icon: Icons.trending_up,
              title: '점수 향상',
              subtitle: '리트 목표 달성 현황',
              color: AppTheme.successColor,
              onTap: () => _navigateToScoreImprovement(context),
            ),
            ActionCard(
              icon: Icons.settings,
              title: '설정',
              subtitle: '앱 설정 관리',
              color: AppTheme.secondaryColor,
              onTap: () => _navigateToSettings(context),
            ),
          ],
        ),
      ],
    );
  }

  /// 대시보드로 네비게이션합니다
  void _navigateToDashboard(BuildContext context) {
    NavigationUtils.push(context, const DashboardScreen());
  }

  /// 오답 노트로 네비게이션합니다
  void _navigateToWrongNotes(BuildContext context) {
    // TODO: 오답 노트 화면 구현 후 연결
    NavigationUtils.showSnackBar(context, '오답 노트 기능은 준비 중입니다');
  }

  /// 점수 향상 화면으로 네비게이션합니다
  void _navigateToScoreImprovement(BuildContext context) {
    // TODO: 점수 향상 화면 구현 후 연결
    NavigationUtils.showSnackBar(context, '점수 향상 기능은 준비 중입니다');
  }

  /// 설정 화면으로 네비게이션합니다
  void _navigateToSettings(BuildContext context) {
    // TODO: 설정 화면 구현 후 연결
    NavigationUtils.showSnackBar(context, '설정 기능은 준비 중입니다');
  }
}


class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '최근 활동',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacingLG),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Column(
              children: [
                ActivityItem(
                  icon: Icons.article,
                  title: '일일 리트 모의고사 완료',
                  subtitle: '15문제 중 12문제 정답',
                  time: '2시간 전',
                  color: AppTheme.successColor,
                ),
                const Divider(),
                ActivityItem(
                  icon: Icons.analytics,
                  title: '주간 리포트 확인',
                  subtitle: '리트 점수 향상 15% 달성',
                  time: '1일 전',
                  color: AppTheme.accentColor,
                ),
                const Divider(),
                ActivityItem(
                  icon: Icons.book,
                  title: '오답 노트 추가',
                  subtitle: '민법 단원 3문제',
                  time: '2일 전',
                  color: AppTheme.warningColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _DailyTestTab extends StatelessWidget {
  const _DailyTestTab();

  @override
  Widget build(BuildContext context) {
    return const DailyTestScreen();
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
} 