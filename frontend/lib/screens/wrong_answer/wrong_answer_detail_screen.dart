/**
 * 오답 노트 상세 화면
 * 
 * 특정 틀린 문제의 상세 정보를 보여주고,
 * 복습 기능을 제공하는 화면입니다.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wrong_answer_provider.dart';
import '../../models/wrong_answer.dart';
import '../../utils/theme.dart';
import '../../constants/app_constants.dart';

class WrongAnswerDetailScreen extends StatefulWidget {
  final WrongAnswer wrongAnswer;

  const WrongAnswerDetailScreen({
    super.key,
    required this.wrongAnswer,
  });

  @override
  State<WrongAnswerDetailScreen> createState() => _WrongAnswerDetailScreenState();
}

class _WrongAnswerDetailScreenState extends State<WrongAnswerDetailScreen> {
  String? selectedAnswer;
  int confidenceLevel = 3;
  final TextEditingController notesController = TextEditingController();
  bool isReviewing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('문제 상세'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('삭제'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppTheme.spacingLG),
            _buildQuestionContent(),
            const SizedBox(height: AppTheme.spacingLG),
            _buildAnswerSection(),
            const SizedBox(height: AppTheme.spacingLG),
            _buildExplanation(),
            const SizedBox(height: AppTheme.spacingLG),
            _buildReviewSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getSubjectColor(widget.wrongAnswer.subject),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.wrongAnswer.subject ?? '기타',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (widget.wrongAnswer.mastered)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '마스터',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMD),
            if (widget.wrongAnswer.unit != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 20,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.wrongAnswer.unit!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingSM),
            ],
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 20,
                  color: _getDifficultyColor(widget.wrongAnswer.difficulty),
                ),
                const SizedBox(width: 8),
                Text(
                  '난이도: ${widget.wrongAnswer.difficultyText}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _getDifficultyColor(widget.wrongAnswer.difficulty),
                  ),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.stars,
                  size: 20,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.wrongAnswer.points}점',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Row(
              children: [
                Icon(
                  Icons.refresh,
                  size: 20,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '복습 횟수: ${widget.wrongAnswer.reviewCount}회',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.source,
                  size: 20,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.wrongAnswer.sourceText,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '문제',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text(
              widget.wrongAnswer.questionContent,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '답안',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '내 답안',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.wrongAnswer.userAnswer,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMD),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.green.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '정답',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.wrongAnswer.correctAnswer,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation() {
    if (widget.wrongAnswer.explanation == null || widget.wrongAnswer.explanation!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '해설',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text(
              widget.wrongAnswer.explanation!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    if (!isReviewing) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '복습하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            
            // 답안 선택
            const Text(
              '다시 풀어보세요:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Wrap(
              spacing: 12,
              children: ['①', '②', '③', '④', '⑤'].map((answer) {
                return ChoiceChip(
                  label: Text(answer),
                  selected: selectedAnswer == answer,
                  onSelected: (selected) {
                    setState(() {
                      selectedAnswer = selected ? answer : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // 확신도
            const Text(
              '확신도:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Slider(
              value: confidenceLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$confidenceLevel',
              onChanged: (value) {
                setState(() {
                  confidenceLevel = value.toInt();
                });
              },
            ),
            Text(
              _getConfidenceText(confidenceLevel),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMD),
            
            // 메모
            const Text(
              '메모 (선택사항):',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '복습 후 느낀 점이나 추가 메모를 작성하세요',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!isReviewing) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isReviewing = true;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 풀기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      isReviewing = false;
                      selectedAnswer = null;
                      confidenceLevel = 3;
                      notesController.clear();
                    });
                  },
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: selectedAnswer != null ? _submitReview : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('복습 완료'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'delete':
        _showDeleteConfirmDialog();
        break;
    }
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문제 삭제'),
        content: const Text('이 문제를 오답 노트에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context
                  .read<WrongAnswerProvider>()
                  .deleteWrongAnswer(widget.wrongAnswer.id);
              
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('문제가 삭제되었습니다')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _submitReview() async {
    if (selectedAnswer == null) return;

    final isCorrect = selectedAnswer == widget.wrongAnswer.correctAnswer;
    final review = WrongAnswerReview(
      id: 0, // 임시 ID
      userAnswer: selectedAnswer!,
      isCorrect: isCorrect,
      confidenceLevel: confidenceLevel,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await context
        .read<WrongAnswerProvider>()
        .reviewWrongAnswer(widget.wrongAnswer.id, review);

    if (success && mounted) {
      setState(() {
        isReviewing = false;
        selectedAnswer = null;
        confidenceLevel = 3;
        notesController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect ? '정답입니다! 🎉' : '아직 틀렸습니다. 다시 복습해보세요.',
          ),
          backgroundColor: isCorrect ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Color _getSubjectColor(String? subject) {
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

  Color _getDifficultyColor(double difficulty) {
    if (difficulty <= 2.0) return Colors.green;
    if (difficulty <= 3.0) return Colors.orange;
    if (difficulty <= 4.0) return Colors.red;
    return Colors.purple;
  }

  String _getConfidenceText(int level) {
    switch (level) {
      case 1:
        return '전혀 확신하지 못함';
      case 2:
        return '약간 확신하지 못함';
      case 3:
        return '보통';
      case 4:
        return '꽤 확신함';
      case 5:
        return '매우 확신함';
      default:
        return '보통';
    }
  }
}
