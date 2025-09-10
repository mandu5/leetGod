import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/daily_newspaper.dart';

class DailyNewspaperScreen extends StatefulWidget {
  const DailyNewspaperScreen({super.key});

  @override
  State<DailyNewspaperScreen> createState() => _DailyNewspaperScreenState();
}

class _DailyNewspaperScreenState extends State<DailyNewspaperScreen> {
  DailyNewspaper? _todayNewspaper;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayNewspaper();
  }

  void _loadTodayNewspaper() {
    // TODO: 실제 API 호출로 변경
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _todayNewspaper = DailyNewspaper(
          id: '1',
          date: DateTime.now(),
          title: '알고리즘 데일리',
          subtitle: '2024년 1월 15일',
          problems: [
            DailyProblem(
              id: '1',
              number: 1,
              subject: '수학I',
              topic: '지수함수와 로그함수',
              difficulty: 3.5,
              timeLimit: 5,
            ),
            DailyProblem(
              id: '2',
              number: 2,
              subject: '수학II',
              topic: '미분법',
              difficulty: 4.2,
              timeLimit: 8,
            ),
            DailyProblem(
              id: '3',
              number: 3,
              subject: '수학I',
              topic: '삼각함수',
              difficulty: 3.8,
              timeLimit: 6,
            ),
          ],
          totalProblems: 25,
          estimatedTime: 120,
        );
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? _buildLoadingScreen()
          : _buildNewspaperScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '오늘의 일간지를 준비하고 있습니다...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNewspaperScreen() {
    if (_todayNewspaper == null) {
      return _buildNoNewspaperScreen();
    }

    return CustomScrollView(
      slivers: [
        // 헤더
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: Colors.blue[600],
          flexibleSpace: FlexibleSpaceBar(
            title: const Text(
              '알고리즘 데일리',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[600]!,
                    Colors.blue[800]!,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.newspaper,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _todayNewspaper!.subtitle,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 일간지 내용
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 일간지 정보 카드
                _buildNewspaperInfoCard(),
                const SizedBox(height: 24),

                // 문제 목록
                _buildProblemsList(),
                const SizedBox(height: 24),

                // 액션 버튼들
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewspaperInfoCard() {
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
                Icon(
                  Icons.schedule,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '오늘의 일간지',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('총 문제 수', '${_todayNewspaper!.totalProblems}문제'),
            _buildInfoRow('예상 소요 시간', '${_todayNewspaper!.estimatedTime}분'),
            _buildInfoRow('난이도', '고급'),
            _buildInfoRow('출제 범위', '수학I, 수학II'),
          ],
        ),
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

  Widget _buildProblemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '문제 미리보기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._todayNewspaper!.problems.map((problem) => _buildProblemCard(problem)),
      ],
    );
  }

  Widget _buildProblemCard(DailyProblem problem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${problem.number}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    problem.subject,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    problem.topic,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.orange[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${problem.timeLimit}분',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '난이도 ${problem.difficulty.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _startSolving,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '오늘의 일간지 풀기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _downloadPDF,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'PDF 다운로드',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _viewArchive,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '과거 일간지',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoNewspaperScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '오늘의 일간지가 준비되지 않았습니다',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '매일 00시에 새로운 일간지가 배달됩니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadTodayNewspaper,
            child: const Text('새로고침'),
          ),
        ],
      ),
    );
  }

  void _startSolving() {
    // TODO: 일간지 풀이 화면으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일간지 풀이 기능 준비 중입니다.')),
    );
  }

  void _downloadPDF() {
    // TODO: PDF 다운로드 기능
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF 다운로드 기능 준비 중입니다.')),
    );
  }

  void _viewArchive() {
    // TODO: 과거 일간지 보관함으로 이동
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('과거 일간지 보관함 기능 준비 중입니다.')),
    );
  }
} 