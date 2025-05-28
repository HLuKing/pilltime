import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pill_provider.dart';
import 'screens/home_screen.dart';
import 'screens/today_pill_screen.dart';
import 'screens/add_pill_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PillProvider()..loadPills(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillSolo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TodayPillScreen(),
    const AddPillScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '약 목록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: '오늘 복용',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: '약 추가',
          ),
        ],
      ),
    );
  }
}
