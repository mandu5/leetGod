/**
 * 오답 노트 메인 화면
 * 
 * 사용자가 틀린 문제들을 조회하고 관리할 수 있는 화면입니다.
 * 필터링, 검색, 통계 보기 등의 기능을 제공합니다.
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wrong_answer_provider.dart';
import '../../models/wrong_answer.dart';
import '../../utils/theme.dart';
import '../../constants/app_constants.dart';
import 'wrong_answer_detail_screen.dart';
import 'wrong_answer_stats_screen.dart';

class WrongAnswerScreen extends StatefulWidget {
  const WrongAnswerScreen({super.key});

  @override
  State<WrongAnswerScreen> createState() => _WrongAnswerScreenState();
}

class _WrongAnswerScreenState extends State<WrongAnswerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WrongAnswerProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // 무한 스크롤 - 더 많은 데이터 로드
      context.read<WrongAnswerProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '오답 노트',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: '전체 오답'),
            Tab(text: '복습 추천'),
            Tab(text: '통계'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<WrongAnswerProvider>().refresh();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllWrongAnswersTab(),
          _buildRecommendationsTab(),
          const WrongAnswerStatsScreen(),
        ],
      ),
    );
  }

  Widget _buildAllWrongAnswersTab() {
    return Consumer<WrongAnswerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.wrongAnswers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.wrongAnswers.isEmpty) {
          return _buildErrorWidget(provider.error!);
        }

        if (provider.wrongAnswers.isEmpty) {
          return _buildEmptyWidget('아직 틀린 문제가 없습니다.\n열심히 공부하고 계시네요! 👏');
        }

        return RefreshIndicator(
          onRefresh: provider.refresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            itemCount: provider.wrongAnswers.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == provider.wrongAnswers.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.spacingMD),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final wrongAnswer = provider.wrongAnswers[index];
              return _buildWrongAnswerCard(wrongAnswer);
            },
          ),
        );
      },
    );
  }

  Widget _buildRecommendationsTab() {
    return Consumer<WrongAnswerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.recommendations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.recommendations.isEmpty) {
          return _buildEmptyWidget('복습할 문제가 없습니다.\n모든 문제를 마스터했습니다! 🎉');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          itemCount: provider.recommendations.length,
          itemBuilder: (context, index) {
            final wrongAnswer = provider.recommendations[index];
            return _buildWrongAnswerCard(wrongAnswer, isRecommendation: true);
          },
        );
      },
    );
  }

  Widget _buildWrongAnswerCard(WrongAnswer wrongAnswer, {bool isRecommendation = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WrongAnswerDetailScreen(wrongAnswer: wrongAnswer),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 정보
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubjectColor(wrongAnswer.subject),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      wrongAnswer.subject ?? '기타',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (wrongAnswer.mastered)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '마스터',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (isRecommendation)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '복습 추천',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    wrongAnswer.sourceText,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppTheme.spacingSM),
              
              // 단원 정보
              if (wrongAnswer.unit != null)
                Text(
                  wrongAnswer.unit!,
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              
              const SizedBox(height: AppTheme.spacingSM),
              
              // 문제 내용 (일부만 표시)
              Text(
                wrongAnswer.questionContent.length > 100
                    ? '${wrongAnswer.questionContent.substring(0, 100)}...'
                    : wrongAnswer.questionContent,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: AppTheme.spacingMD),
              
              // 하단 정보
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: _getDifficultyColor(wrongAnswer.difficulty),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    wrongAnswer.difficultyText,
                    style: TextStyle(
                      color: _getDifficultyColor(wrongAnswer.difficulty),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.refresh,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '복습 ${wrongAnswer.reviewCount}회',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (wrongAnswer.needsReview)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '복습 필요',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
              height: 1.5,
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
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            '데이터를 불러오는데 실패했습니다',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          ElevatedButton(
            onPressed: () {
              context.read<WrongAnswerProvider>().refresh();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
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
}

class _FilterBottomSheet extends StatefulWidget {
  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String? selectedSubject;
  String? selectedUnit;
  bool? selectedMastered;
  RangeValues difficultyRange = const RangeValues(1.0, 5.0);

  @override
  void initState() {
    super.initState();
    final provider = context.read<WrongAnswerProvider>();
    final filter = provider.currentFilter;
    
    selectedSubject = filter.subject;
    selectedUnit = filter.unit;
    selectedMastered = filter.mastered;
    difficultyRange = RangeValues(
      filter.difficultyMin ?? 1.0,
      filter.difficultyMax ?? 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '필터',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('초기화'),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMD),
          
          // 과목 선택
          const Text(
            '과목',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Wrap(
            spacing: 8,
            children: ['언어이해', '추리논증', '법학'].map((subject) {
              return FilterChip(
                label: Text(subject),
                selected: selectedSubject == subject,
                onSelected: (selected) {
                  setState(() {
                    selectedSubject = selected ? subject : null;
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppTheme.spacingMD),
          
          // 마스터 여부
          const Text(
            '학습 상태',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('마스터'),
                selected: selectedMastered == true,
                onSelected: (selected) {
                  setState(() {
                    selectedMastered = selected ? true : null;
                  });
                },
              ),
              FilterChip(
                label: const Text('미마스터'),
                selected: selectedMastered == false,
                onSelected: (selected) {
                  setState(() {
                    selectedMastered = selected ? false : null;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMD),
          
          // 난이도 범위
          const Text(
            '난이도 범위',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          RangeSlider(
            values: difficultyRange,
            min: 1.0,
            max: 5.0,
            divisions: 8,
            labels: RangeLabels(
              difficultyRange.start.toStringAsFixed(1),
              difficultyRange.end.toStringAsFixed(1),
            ),
            onChanged: (values) {
              setState(() {
                difficultyRange = values;
              });
            },
          ),
          
          const SizedBox(height: AppTheme.spacingLG),
          
          // 적용 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '필터 적용',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedSubject = null;
      selectedUnit = null;
      selectedMastered = null;
      difficultyRange = const RangeValues(1.0, 5.0);
    });
  }

  void _applyFilters() {
    final filter = WrongAnswerFilter(
      subject: selectedSubject,
      unit: selectedUnit,
      mastered: selectedMastered,
      difficultyMin: difficultyRange.start,
      difficultyMax: difficultyRange.end,
    );
    
    context.read<WrongAnswerProvider>().applyFilter(filter);
    Navigator.pop(context);
  }
}
