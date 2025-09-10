import 'package:flutter/material.dart';
import 'package:leet_god/utils/theme.dart';

/// 최근 활동 아이템을 표시하는 재사용 가능한 위젯
/// 
/// 활동 아이템의 표시 로직만을 담당합니다.
class ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const ActivityItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildIconContainer(),
        const SizedBox(width: AppTheme.spacingMD),
        _buildContentColumn(),
        const Spacer(),
        _buildTimeText(),
      ],
    );
  }

  /// 아이콘 컨테이너를 빌드합니다
  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSM),
      decoration: BoxDecoration(
        color: color.withOpacity(AppTheme.opacityLight),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSM),
      ),
      child: Icon(
        icon,
        color: color,
        size: AppTheme.iconSizeMD,
      ),
    );
  }

  /// 내용 컬럼을 빌드합니다
  Widget _buildContentColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleText(),
          _buildSubtitleText(),
        ],
      ),
    );
  }

  /// 제목 텍스트를 빌드합니다
  Widget _buildTitleText() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
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
    );
  }

  /// 시간 텍스트를 빌드합니다
  Widget _buildTimeText() {
    return Text(
      time,
      style: const TextStyle(
        fontSize: 12,
        color: AppTheme.textSecondaryColor,
      ),
    );
  }
}
