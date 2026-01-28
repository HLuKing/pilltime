import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pillsolo/screens/pill_detail_screen.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../models/pill_summary.dart';
import 'add_pill_screen.dart';
import 'today_pill_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 데이터 가져오기
    Future.microtask(() =>
        Provider.of<PillProvider>(context, listen: false).loadPills());
  }
  // 시간 문자열(예: "09:00")을 받아서 시간대(아침/점심/저녁/취침)로 분류
  String _getDoseSlot(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      final hour = int.parse(parts[0]);

      if (hour >= 6 && hour < 12) return '아침';
      else if (hour >= 12 && hour < 18) return '점심';
      else if (hour >= 18 && hour < 22) return '저녁';
      return '취침';
    } catch (e) {
      return '기타';
    }
  }

  // 약 목록을 시간대별로 찢어서 정리하는 함수
  // (약 하나가 2번 복용이면 리스트에 2번 들어감)
  Map<String, List<Map<String, dynamic>>> _groupPillsBySlot(List<PillSummary> pills) {
    final Map<String, List<Map<String, dynamic>>> grouped = {
      '아침': [],
      '점심': [],
      '저녁': [],
      '취침': [],
    };

    for (var pill in pills) {
      // "09:00, 18:00" 처럼 콤마로 된 문자열을 분리
      final times = pill.doseTime.split(',');

      for (var t in times) {
        String cleanTime = t.trim();
        String slot = _getDoseSlot(cleanTime);

        if (grouped.containsKey(slot)) {
          grouped[slot]!.add({
            'pill': pill,
            'time': cleanTime,
            // TODO: 실제로는 해당 시간의 복용 여부를 체크해야 함 (현재는 전체 퍼센트로 임시 판별)
            // 백엔드에서 시간대별 복용 여부를 주는 API가 필요할 수 있음
            'isTaken': pill.takenPercent == 100,
          });
        }
      }
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PillProvider>(context);
    final groupedPills = _groupPillsBySlot(provider.pills);

    int totalItems = 0;
    int takenItems = 0;
    groupedPills.forEach((key, list) {
      totalItems += list.length;
      takenItems += list.where((item) => item['isTaken'] == true).length;
    });
    double progress = totalItems == 0 ? 0 : takenItems / totalItems;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('약 알림', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. 상단 요약 카드 (날짜 + 진행률)
                _buildSummaryCard(progress, takenItems, totalItems),
                const SizedBox(height: 24),

                _buildTimeSlotSection('아침', Icons.wb_twilight, Colors.orangeAccent, groupedPills['아침']!),
                _buildTimeSlotSection('점심', Icons.wb_sunny, Colors.amber, groupedPills['점심']!),
                _buildTimeSlotSection('저녁', Icons.nights_stay, Colors.deepPurpleAccent, groupedPills['저녁']!),
                _buildTimeSlotSection('취침', Icons.bed, Colors.indigo, groupedPills['취침']!),

                const SizedBox(height: 80),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPillScreen()),
          );
          if (result == true && context.mounted) {
            provider.loadPills();
          }
        },
        backgroundColor: const Color(0xFF536DFE),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(double progress, int taken, int total) {
    String today = DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(DateTime.now());
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(today, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('복용 확률', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('$taken/$total', style: const TextStyle(fontSize: 18, color: Color(0xFF536DFE), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: const Color(0xFF536DFE),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSection(String title, IconData icon, Color color, List<Map<String, dynamic>> items) {
    
  }
}