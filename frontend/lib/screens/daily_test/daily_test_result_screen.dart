import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyTestResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DailyTestResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final accuracy = result['accuracy']?.toDouble() ?? 0.0;
    final correctCount = result['correct_count'] ?? 0;
    final totalQuestions = result['total_questions'] ?? 0;
    final totalScore = result['total_score'] ?? 0;
    final totalPoints = result['total_points'] ?? 0;
    final wrongQuestions = List<Map<String, dynamic>>.from(result['wrong_questions'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘의 리트 모의고사 결과'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 전체 결과 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      '오늘의 리트 모의고사 결과',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 정답률 원형 차트
                    SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Center(
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: CircularProgressIndicator(
                                value: accuracy / 100,
                                strokeWidth: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getAccuracyColor(accuracy),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${accuracy.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text('정답률'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 점수 정보
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreCard(
                          '정답',
                          '$correctCount/$totalQuestions',
                          Colors.green,
                        ),
                        _buildScoreCard(
                          '점수',
                          '$totalScore/$totalPoints',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 성취도 메시지
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      '오늘의 성취도',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getAchievementMessage(accuracy),
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getMotivationMessage(accuracy),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 틀린 문제 목록
            if (wrongQuestions.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '틀린 문제 목록',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...wrongQuestions.take(5).map((question) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ExpansionTile(
                          title: Text(
                            question['content'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '단원: ${question['unit']} | 배점: ${question['points']}점',
                            style: const TextStyle(fontSize: 12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('내 답안: ${question['user_answer']}'),
                                  Text('정답: ${question['correct_answer']}'),
                                  if (question['explanation'] != null) ...[
                                    const SizedBox(height: 8),
                                    Text('해설: ${question['explanation']}'),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // 다음 단계 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/dashboard',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '학습 대시보드로 이동',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getAchievementMessage(double accuracy) {
    if (accuracy >= 90) {
      return '🎉 훌륭합니다! 거의 완벽한 성과입니다.';
    } else if (accuracy >= 80) {
      return '👍 잘했어요! 꾸준한 실력 향상을 보여주고 있습니다.';
    } else if (accuracy >= 70) {
      return '💪 좋아요! 조금만 더 노력하면 더 좋은 결과를 얻을 수 있어요.';
    } else if (accuracy >= 60) {
      return '📚 괜찮아요! 부족한 부분을 보완하면 더 좋아질 거예요.';
    } else {
      return '💪 힘내세요! 오늘의 학습으로 한 걸음 더 나아갔습니다.';
    }
  }

  String _getMotivationMessage(double accuracy) {
    if (accuracy >= 90) {
      return '이런 페이스를 유지하면 목표 등급 달성이 가능합니다!';
    } else if (accuracy >= 80) {
      return '약점 단원을 집중적으로 학습하면 더 좋은 결과를 얻을 수 있어요.';
    } else if (accuracy >= 70) {
      return '틀린 문제들을 꼼꼼히 복습해보세요.';
    } else if (accuracy >= 60) {
      return '기초를 다지는 것이 중요합니다. 천천히 차근차근 학습해보세요.';
    } else {
      return '포기하지 마세요! 매일 조금씩이라도 꾸준히 학습하면 분명 좋아집니다.';
    }
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }
} 