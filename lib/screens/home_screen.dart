import 'package:flutter/material.dart';
import 'package:pillsolo/screens/pill_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../models/pill_summary.dart';
import 'add_pill_screen.dart';
import 'today_pill_screen.dart';

// 복용 시간 순서 정의
const doseOrder = ['아침', '점심', '저녁', '취침'];

// 복용 시간별로 그룹핑 함수
Map<String, List<PillSummary>> groupByDoseTime(List<PillSummary> pills) {
  final Map<String, List<PillSummary>> grouped = {
    for (var time in doseOrder) time: [],
  };
  for (var pill in pills) {
    if (grouped.containsKey(pill.doseTime)) {
      grouped[pill.doseTime]!.add(pill);
    } else {
      grouped[pill.doseTime] = [pill]; // 예상치 못한 복용 시간 처리
    }
  }
  return grouped;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PillProvider>(context, listen: false).loadPills());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PillProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('복약 관리'),
        actions: [
          // 테스트 알림 버튼 (개발용)
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'instant') {
                await provider.sendTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('테스트 알림을 보냈습니다!')),
                  );
                }
              } else if (value == 'scheduled') {
                await provider.scheduleTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('1분 후 알림이 예약되었습니다!')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'instant',
                child: Text('즉시 알림 테스트'),
              ),
              const PopupMenuItem(
                value: 'scheduled',
                child: Text('1분 후 알림 테스트'),
              ),
            ],
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TodayPillScreen()),
                      );
                    },
                    child: const Text('오늘 복용할 약 보기'),
                  ),
                ),
                const SizedBox(height: 8),
                // 알림 설정 안내
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.teal),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '알림 시간: 아침 9시, 점심 1시, 저녁 7시, 취침 11시',
                          style: TextStyle(fontSize: 12, color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: groupByDoseTime(provider.pills)
                        .entries
                        .where((entry) => entry.value.isNotEmpty)
                        .expand((entry) => [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                                child: Row(
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    Text(
                                      _getDoseTimeText(entry.key),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...entry.value.map((pill) => Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    child: ListTile(
                                      leading: pill.imageUrl != null
                                          ? Image.network(pill.imageUrl!)
                                          : const Icon(Icons.medication),
                                      title: Text(pill.name),
                                      subtitle: Text(
                                          '${pill.description ?? ''}, ${pill.takenPercent}% 복용'),
                                      trailing: Text(
                                          '${pill.takenDays}/${pill.dosePeriod}일'),
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PillDetailScreen(pillId: pill.id),
                                          ),
                                        );
                                        if (result == true && context.mounted) {
                                          Provider.of<PillProvider>(context,
                                                  listen: false)
                                              .loadPills();
                                        }
                                      },
                                    ),
                                  )),
                            ])
                        .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPillScreen()),
          );
          if (result == true) {
            if (context.mounted) {
              Provider.of<PillProvider>(context, listen: false).loadPills();
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getDoseTimeText(String doseTime) {
    switch (doseTime) {
      case '아침': return '오전 9시';
      case '점심': return '오후 1시';
      case '저녁': return '오후 7시';
      case '취침': return '오후 11시';
      default: return '';
    }
  }
}