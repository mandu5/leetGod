import 'package:flutter/material.dart';
import 'package:leet_god/utils/theme.dart';

/// 빠른 액션을 위한 재사용 가능한 카드 위젯
/// 
/// 카드의 UI 로직과 비즈니스 로직을 분리합니다.
class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLG),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconContainer(),
              const SizedBox(height: AppTheme.spacingMD),
              _buildTitleText(),
              const SizedBox(height: AppTheme.spacingXS),
              _buildSubtitleText(),
            ],
          ),
        ),
      ),
    );
  }

  /// 아이콘 컨테이너를 빌드합니다
  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: color.withOpacity(AppTheme.opacityLight),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMD),
      ),
      child: Icon(
        icon,
        color: color,
        size: AppTheme.iconSizeLG,
      ),
    );
  }

  /// 제목 텍스트를 빌드합니다
  Widget _buildTitleText() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 부제목 텍스트를 빌드합니다
  Widget _buildSubtitleText() {
    return Text(
      subtitle,
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.textSecondaryColor,
      ),
      textAlign: TextAlign.center,
    );
  }
}
