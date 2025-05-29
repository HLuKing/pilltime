import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pillsolo/models/pill_detail.dart';
import 'package:pillsolo/services/pill_api_service.dart';
import 'package:pillsolo/screens/add_pill_screen.dart';

class PillDetailScreen extends StatefulWidget {
  final int pillId;

  const PillDetailScreen({super.key, required this.pillId});

  @override
  State<PillDetailScreen> createState() => _PillDetailScreenState();
}

class _PillDetailScreenState extends State<PillDetailScreen> {
  PillDetail? pill;
  List<DateTime> takenDates = [];
  bool isLoading = true;
  bool takenToday = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await PillApiService().fetchPillDetail(widget.pillId);
      final dates = await PillApiService().fetchTakenDates(widget.pillId);
      final todayTaken = await PillApiService().checkTodayTaken(widget.pillId);

      setState(() {
        pill = data;
        takenDates = dates;
        takenToday = todayTaken;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('불러오기 실패: ${e.toString()}')),
      );
    }
  }

  Future<void> _markAsTaken() async {
    try {
      await PillApiService().markAsTaken(widget.pillId);
      await _loadDetail();
      if (context.mounted) Navigator.pop(context, true);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복용 기록 실패: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deletePill() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말로 이 약을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('삭제')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PillApiService().deletePill(widget.pillId);
        if (context.mounted) Navigator.pop(context, true);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('삭제 실패: ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _buildInfoBlock(String title, String? content) {
    if (content == null || content.trim().isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(content),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (pill == null) {
      return const Scaffold(body: Center(child: Text('약 정보를 불러올 수 없습니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(pill!.name ?? '이름 없음')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (pill!.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.network(pill!.imageUrl!, height: 120),
              ),
            _buildInfoBlock('복용 시간', pill!.doseTime),
            _buildInfoBlock('복용 기간', '${pill!.dosePeriod ?? 0}일'),
            _buildInfoBlock('복용 메모', pill!.description),
            _buildInfoBlock('복용 방법', pill!.usage),
            _buildInfoBlock('효능/효과', pill!.warning),
            _buildInfoBlock('제조사', pill!.manufacturer),
            _buildInfoBlock('주의사항', pill!.precaution),
            _buildInfoBlock('상호작용', pill!.interaction),
            _buildInfoBlock('부작용', pill!.sideEffect),
            _buildInfoBlock('보관 방법', pill!.storage),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: takenToday ? null : _markAsTaken,
              icon: Icon(takenToday ? Icons.check : Icons.check_box_outline_blank),
              label: Text(takenToday ? '오늘 복용 완료' : '복용 완료로 기록'),
            ),
            const SizedBox(height: 24),
            const Text('복용 기록', style: TextStyle(fontWeight: FontWeight.bold)),
            ...takenDates.map((date) => ListTile(
              title: Text(DateFormat('yyyy-MM-dd').format(date)),
            )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("수정"),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddPillScreen(pillId: widget.pillId),
                      ),
                    );
                    if (result == true) _loadDetail();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text("삭제"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _deletePill,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
