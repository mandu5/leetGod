/**
 * 학습 스트릭 위젯
 * 
 * 사용자의 연속 학습 일수와 성취를 보여주는 위젯입니다.
 */

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LearningStreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final bool isActiveToday;
  final List<String> recentAchievements;

  const LearningStreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.isActiveToday,
    this.recentAchievements = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade400,
              Colors.red.shade400,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '학습 스트릭',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isActiveToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '오늘 완료!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // 현재 스트릭
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '현재 연속',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$currentStreak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                '일',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '최고 기록',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$longestStreak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Text(
                                '일',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 진행률 바
              _buildProgressBar(),
              
              const SizedBox(height: 16),
              
              // 최근 성취
              if (recentAchievements.isNotEmpty) ...[
                const Text(
                  '최근 성취',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: recentAchievements.take(3).map((achievement) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        achievement,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    // 다음 마일스톤까지의 진행률 계산
    final milestones = [3, 7, 14, 30, 50, 100];
    int nextMilestone = milestones.firstWhere(
      (milestone) => milestone > currentStreak,
      orElse: () => currentStreak + 10,
    );
    
    int previousMilestone = 0;
    for (int milestone in milestones) {
      if (milestone <= currentStreak) {
        previousMilestone = milestone;
      } else {
        break;
      }
    }
    
    double progress = 0.0;
    if (nextMilestone > previousMilestone) {
      progress = (currentStreak - previousMilestone) / (nextMilestone - previousMilestone);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '다음 목표: ${nextMilestone}일',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class CompactStreakWidget extends StatelessWidget {
  final int currentStreak;
  final bool isActiveToday;
  final VoidCallback? onTap;

  const CompactStreakWidget({
    super.key,
    required this.currentStreak,
    required this.isActiveToday,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade400,
              Colors.red.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$currentStreak일',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isActiveToday) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
