import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../daily/daily_newspaper_screen.dart';
import '../subscription/subscription_screen.dart';
import '../archive/archive_screen.dart';
import '../profile/profile_screen.dart';

class NewMainScreen extends StatefulWidget {
  const NewMainScreen({super.key});

  @override
  State<NewMainScreen> createState() => _NewMainScreenState();
}

class _NewMainScreenState extends State<NewMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DailyNewspaperScreen(),
    const SubscriptionScreen(),
    const ArchiveScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: '오늘의 일간지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_membership),
            label: '구독 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: '보관함',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
} 