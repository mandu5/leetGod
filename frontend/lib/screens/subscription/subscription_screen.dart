import 'package:flutter/material.dart';
import '../../models/daily_newspaper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Subscription? _currentSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  void _loadSubscription() {
    // TODO: 실제 API 호출로 변경
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _currentSubscription = Subscription(
          id: '1',
          userId: '1',
          planType: 'pro',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 335)),
          isActive: true,
          status: 'active',
        );
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSubscriptionContent(),
    );
  }

  Widget _buildSubscriptionContent() {
    if (_currentSubscription == null) {
      return _buildNoSubscriptionScreen();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 구독 정보
          _buildCurrentSubscriptionCard(),
          const SizedBox(height: 24),

          // 구독 혜택
          _buildBenefitsCard(),
          const SizedBox(height: 24),

          // 구독 관리 옵션
          _buildManagementOptions(),
        ],
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard() {
    final planName = _getPlanName(_currentSubscription!.planType);
    final planColor = _getPlanColor(_currentSubscription!.planType);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: planColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    planName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '현재 구독 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('구독 플랜', planName),
            _buildInfoRow('시작일', _formatDate(_currentSubscription!.startDate)),
            _buildInfoRow('만료일', _formatDate(_currentSubscription!.endDate!)),
            _buildInfoRow('남은 기간', _getRemainingDays()),
            _buildInfoRow('상태', '활성'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '구독 혜택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem('매일 새로운 일간지 배달'),
            _buildBenefitItem('PDF 다운로드'),
            _buildBenefitItem('과거 일간지 보관함 접근'),
            _buildBenefitItem('전문가 해설 제공'),
            _buildBenefitItem('맞춤형 난이도 설정'),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementOptions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('구독 변경'),
            subtitle: const Text('다른 플랜으로 변경'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _changeSubscription,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('결제 내역'),
            subtitle: const Text('결제 기록 확인'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _viewPaymentHistory,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('결제 수단 관리'),
            subtitle: const Text('카드 정보 변경'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _managePaymentMethod,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.red),
            title: const Text('구독 취소'),
            subtitle: const Text('구독을 중단합니다'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _cancelSubscription,
          ),
        ],
      ),
    );
  }

  Widget _buildNoSubscriptionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '구독 정보가 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '일간지 구독을 시작해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('구독 시작하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            benefit,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getPlanName(String planType) {
    switch (planType) {
      case 'pro':
        return '프로';
      case 'basic':
        return '베이직';
      case 'light':
        return '라이트';
      default:
        return '알 수 없음';
    }
  }

  Color _getPlanColor(String planType) {
    switch (planType) {
      case 'pro':
        return Colors.blue;
      case 'basic':
        return Colors.purple;
      case 'light':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _getRemainingDays() {
    if (_currentSubscription!.endDate == null) return '무제한';
    
    final remaining = _currentSubscription!.endDate!.difference(DateTime.now()).inDays;
    return '$remaining일';
  }

  void _changeSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('구독 변경 기능 준비 중입니다.')),
    );
  }

  void _viewPaymentHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('결제 내역 기능 준비 중입니다.')),
    );
  }

  void _managePaymentMethod() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('결제 수단 관리 기능 준비 중입니다.')),
    );
  }

  void _cancelSubscription() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('구독 취소'),
          content: const Text('정말로 구독을 취소하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('구독이 취소되었습니다.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('구독 취소'),
            ),
          ],
        );
      },
    );
  }

  void _startSubscription() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('구독 시작 기능 준비 중입니다.')),
    );
  }
} 