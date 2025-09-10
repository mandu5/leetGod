import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DiagnosticResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const DiagnosticResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final accuracy = result['accuracy']?.toDouble() ?? 0.0;
    final estimatedGrade = result['estimated_grade'] ?? '미정';
    final strongUnits = List<String>.from(result['strong_units'] ?? []);
    final weakUnits = List<String>.from(result['weak_units'] ?? []);
    final unitScores = Map<String, dynamic>.from(result['unit_scores'] ?? {});
    final wrongQuestions = List<Map<String, dynamic>>.from(result['wrong_questions'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 평가 결과'),
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
                      '진단 평가 결과',
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
                    
                    // 예상 등급
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(estimatedGrade),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '예상 등급: $estimatedGrade',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 단원별 분석
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '단원별 분석',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // 강점 단원
                    if (strongUnits.isNotEmpty) ...[
                      const Text(
                        '강점 단원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: strongUnits.map((unit) => Chip(
                          label: Text(unit),
                          backgroundColor: Colors.green[100],
                          labelStyle: const TextStyle(color: Colors.green),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 약점 단원
                    if (weakUnits.isNotEmpty) ...[
                      const Text(
                        '약점 단원',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: weakUnits.map((unit) => Chip(
                          label: Text(unit),
                          backgroundColor: Colors.red[100],
                          labelStyle: const TextStyle(color: Colors.red),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // 단원별 점수 차트
                    if (unitScores.isNotEmpty) ...[
                      const Text(
                        '단원별 점수',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final units = unitScores.keys.toList();
                                    if (value.toInt() < units.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          units[value.toInt()],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '${value.toInt()}%',
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: unitScores.entries.map((entry) {
                              final index = unitScores.keys.toList().indexOf(entry.key);
                              final scores = entry.value as Map<String, dynamic>;
                              final accuracy = (scores['correct'] / scores['total'] * 100).toDouble();
                              
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: accuracy,
                                    color: _getAccuracyColor(accuracy),
                                    width: 20,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
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
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '학습 대시보드로 이동',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return Colors.green;
    if (accuracy >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case '1등급':
        return Colors.purple;
      case '2등급':
        return Colors.blue;
      case '3등급':
        return Colors.green;
      case '4등급':
        return Colors.orange;
      case '5등급':
        return Colors.red;
      case '6등급':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }
} 