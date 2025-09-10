import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leet_god/providers/diagnostic_provider.dart';
import 'diagnostic_result_screen.dart';

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  int _currentQuestionIndex = 0;
  Map<int, String> _answers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiagnosticProvider>(context, listen: false).loadQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 평가'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<DiagnosticProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.questions.isEmpty) {
            return const Center(child: Text('문제를 불러오는 중...'));
          }

          final question = provider.questions[_currentQuestionIndex];
          final totalQuestions = provider.questions.length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 진행률 표시
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / totalQuestions,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_currentQuestionIndex + 1} / $totalQuestions',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                
                // 문제 내용
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '문제 ${_currentQuestionIndex + 1}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '단원: ${question.unit} | 난이도: ${question.difficulty}점 | 배점: ${question.points}점',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 답안 선택
                if (question.options.isNotEmpty) ...[
                  ...question.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _answers[_currentQuestionIndex] == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _answers[_currentQuestionIndex] = option;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: isSelected ? Colors.blue[50] : Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.blue : Colors.grey[300],
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? Colors.blue : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ] else ...[
                  // 주관식 답안 입력
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: '답안을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _answers[_currentQuestionIndex] = value;
                    },
                  ),
                ],

                const Spacer(),

                // 네비게이션 버튼
                Row(
                  children: [
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex--;
                            });
                          },
                          child: const Text('이전'),
                        ),
                      ),
                    if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _answers[_currentQuestionIndex] != null
                            ? () {
                                if (_currentQuestionIndex < totalQuestions - 1) {
                                  setState(() {
                                    _currentQuestionIndex++;
                                  });
                                } else {
                                  _submitDiagnostic();
                                }
                              }
                            : null,
                        child: Text(
                          _currentQuestionIndex < totalQuestions - 1 ? '다음' : '제출',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submitDiagnostic() async {
    try {
      final provider = Provider.of<DiagnosticProvider>(context, listen: false);
      final result = await provider.submitDiagnostic(_answers);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => DiagnosticResultScreen(result: result),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제출 실패: $e')),
        );
      }
    }
  }
} 