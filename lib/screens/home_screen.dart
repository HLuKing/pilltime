import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('약 알림'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // 나중에 알림 설정 등 할것 
            },
          )
        ]
      ),
      body: const Center(
        child: Text('복용중인 약이 없습니다'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 약 추가화면으로 이동 예정
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
