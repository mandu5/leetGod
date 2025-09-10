import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 정보'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 앱 로고 및 버전 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.indigo[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.gavel,
                        size: 40,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '리트의신',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '버전 1.0.0',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 앱 정보 목록
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('개발자'),
                    subtitle: const Text('리트의신 개발팀'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showDeveloperInfo(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('문의하기'),
                    subtitle: const Text('support@leetgod.com'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showContactInfo(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('도움말'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showHelpInfo(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: const Text('개인정보처리방침'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showPrivacyPolicy(context);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text('이용약관'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showTermsOfService(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 앱 기능 정보
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '주요 기능',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem('AI 기반 진단 평가', '개인 맞춤형 리트 실력 진단'),
                    _buildFeatureItem('일일 모의고사', 'AI 추천 맞춤형 리트 문제'),
                    _buildFeatureItem('학습 대시보드', '진행 상황 및 통계'),
                    _buildFeatureItem('오답 노트', '틀린 문제 관리'),
                    _buildFeatureItem('이용권 관리', '다양한 학습 플랜'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Colors.indigo,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('개발자 정보'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('리트의신 개발팀'),
              SizedBox(height: 8),
              Text('AI 기반 리트 시험 학습 앱을 개발하는 팀입니다.'),
              SizedBox(height: 8),
              Text('• AI/ML 엔지니어'),
              Text('• Flutter 개발자'),
              Text('• 백엔드 개발자'),
              Text('• UI/UX 디자이너'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('문의하기'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('고객 지원팀에 문의하세요.'),
              SizedBox(height: 16),
              Text('📧 이메일: support@leetgod.com'),
              Text('📞 전화: 1588-0000'),
              Text('⏰ 운영시간: 평일 09:00-18:00'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('도움말'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('자주 묻는 질문'),
              SizedBox(height: 16),
              Text('Q: 진단 평가는 어떻게 진행되나요?'),
              Text('A: 30문제의 진단 테스트를 통해 현재 리트 실력을 파악합니다.'),
              SizedBox(height: 8),
              Text('Q: 일일 모의고사는 언제 받을 수 있나요?'),
              Text('A: 매일 새로운 리트 문제가 제공됩니다.'),
              SizedBox(height: 8),
              Text('Q: 이용권은 어떻게 변경하나요?'),
              Text('A: 프로필 > 이용권 관리에서 변경 가능합니다.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('개인정보처리방침'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('리트의신 개인정보처리방침'),
                SizedBox(height: 16),
                Text('1. 수집하는 개인정보'),
                Text('• 이메일 주소, 이름, 학습 데이터'),
                SizedBox(height: 8),
                Text('2. 개인정보의 이용목적'),
                Text('• 서비스 제공 및 개선'),
                Text('• 맞춤형 리트 학습 콘텐츠 제공'),
                SizedBox(height: 8),
                Text('3. 개인정보의 보유기간'),
                Text('• 서비스 이용 종료 시까지'),
                SizedBox(height: 8),
                Text('4. 개인정보의 파기'),
                Text('• 서비스 종료 시 즉시 파기'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('이용약관'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('리트의신 이용약관'),
                SizedBox(height: 16),
                Text('제1조 (목적)'),
                Text('본 약관은 리트의신 서비스 이용에 관한 조건을 정합니다.'),
                SizedBox(height: 8),
                Text('제2조 (서비스 내용)'),
                Text('• AI 기반 진단 평가'),
                Text('• 일일 모의고사 제공'),
                Text('• 학습 대시보드'),
                Text('• 오답 노트 기능'),
                SizedBox(height: 8),
                Text('제3조 (이용료)'),
                Text('• 이용권 구매 시 해당 요금이 부과됩니다.'),
                SizedBox(height: 8),
                Text('제4조 (책임제한)'),
                Text('• 서비스 이용으로 인한 학습 결과는 보장하지 않습니다.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
} 