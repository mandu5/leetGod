import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _dailyTestNotification = true;
  bool _studyReminder = true;
  bool _achievementNotification = true;
  bool _voucherExpiryNotification = true;
  bool _systemNotification = false;
  bool _marketingNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 알림 설정 설명
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '학습에 도움이 되는 알림을 받아보세요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 학습 관련 알림
            _buildNotificationSection(
              '학습 알림',
              [
                _buildNotificationItem(
                  '일일 모의고사 알림',
                  '매일 새로운 모의고사가 준비되었습니다',
                  _dailyTestNotification,
                  (value) {
                    setState(() {
                      _dailyTestNotification = value;
                    });
                  },
                ),
                _buildNotificationItem(
                  '학습 리마인더',
                  '설정한 시간에 학습 알림을 받습니다',
                  _studyReminder,
                  (value) {
                    setState(() {
                      _studyReminder = value;
                    });
                  },
                ),
                _buildNotificationItem(
                  '성취 알림',
                  '목표 달성 시 축하 메시지를 받습니다',
                  _achievementNotification,
                  (value) {
                    setState(() {
                      _achievementNotification = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 서비스 관련 알림
            _buildNotificationSection(
              '서비스 알림',
              [
                _buildNotificationItem(
                  '이용권 만료 알림',
                  '이용권 만료 7일 전 알림을 받습니다',
                  _voucherExpiryNotification,
                  (value) {
                    setState(() {
                      _voucherExpiryNotification = value;
                    });
                  },
                ),
                _buildNotificationItem(
                  '시스템 알림',
                  '앱 업데이트 및 시스템 관련 알림',
                  _systemNotification,
                  (value) {
                    setState(() {
                      _systemNotification = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 마케팅 알림
            _buildNotificationSection(
              '마케팅 알림',
              [
                _buildNotificationItem(
                  '이벤트 및 혜택 알림',
                  '새로운 이벤트와 특별 혜택을 받아보세요',
                  _marketingNotification,
                  (value) {
                    setState(() {
                      _marketingNotification = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 알림 시간 설정
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          color: Colors.orange[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '알림 시간 설정',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '학습 리마인더 알림 시간',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.access_time, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            '오후 8:00',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 설정 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '설정 저장',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  void _saveSettings() {
    // TODO: 실제 API 호출로 변경
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('알림 설정이 저장되었습니다.'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }
} 