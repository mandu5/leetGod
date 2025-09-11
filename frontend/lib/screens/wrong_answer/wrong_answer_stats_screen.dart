/**
 * 오답 노트 통계 화면
 * 
 * 사용자의 오답 노트 통계를 시각적으로 보여주는 화면입니다.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wrong_answer_provider.dart';
import '../../models/wrong_answer.dart';
import '../../utils/theme.dart';
import '../../constants/app_constants.dart';

class WrongAnswerStatsScreen extends StatefulWidget {
  const WrongAnswerStatsScreen({super.key});

  @override
  State<WrongAnswerStatsScreen> createState() => _WrongAnswerStatsScreenState();
}

class _WrongAnswerStatsScreenState extends State<WrongAnswerStatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WrongAnswerProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WrongAnswerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.stats == null) {
          return _buildErrorWidget(provider.error!);
        }

        if (provider.stats == null) {
          return _buildEmptyWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewCards(provider.stats!),
              const SizedBox(height: AppTheme.spacingLG),
              _buildSubjectChart(provider.stats!),
              const SizedBox(height: AppTheme.spacingLG),
              _buildDifficultyChart(provider.stats!),
              const SizedBox(height: AppTheme.spacingLG),
              _buildRecentReviews(provider.stats!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(WrongAnswerStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '전체 현황',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingMD),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '총 오답 수',
                '${stats.totalCount}개',
                Icons.quiz_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: _buildStatCard(
                '마스터',
                '${stats.masteredCount}개',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMD),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '복습 필요',
                '${stats.reviewNeededCount}개',
                Icons.refresh,
                Colors.orange,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: _buildStatCard(
                '마스터율',
                '${(stats.masteryRate * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectChart(WrongAnswerStats stats) {
    if (stats.bySubject.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '과목별 분포',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            ...stats.bySubject.entries.map((entry) {
              final percentage = stats.totalCount > 0 
                  ? (entry.value / stats.totalCount * 100)
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${entry.value}개 (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSubjectColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChart(WrongAnswerStats stats) {
    if (stats.byDifficulty.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '난이도별 분포',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            ...stats.byDifficulty.entries.map((entry) {
              final percentage = stats.totalCount > 0 
                  ? (entry.value / stats.totalCount * 100)
                  : 0.0;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '난이도 ${entry.key}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${entry.value}개 (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getDifficultyColor(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviews(WrongAnswerStats stats) {
    if (stats.recentReviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '최근 복습 기록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            ...stats.recentReviews.map((review) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
                child: Row(
                  children: [
                    Icon(
                      review.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: review.isCorrect ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingSM),
                    Expanded(
                      child: Text(
                        '답안: ${review.userAnswer}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      _formatDateTime(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '통계 데이터가 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '통계를 불러오는데 실패했습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<WrongAnswerProvider>().loadStats();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case '언어이해':
        return Colors.blue;
      case '추리논증':
        return Colors.green;
      case '법학':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(String difficultyRange) {
    if (difficultyRange.contains('1.0-2.0')) return Colors.green;
    if (difficultyRange.contains('2.0-3.0')) return Colors.orange;
    if (difficultyRange.contains('3.0-4.0')) return Colors.red;
    return Colors.purple;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
