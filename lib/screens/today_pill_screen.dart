import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pill_provider.dart';
import '../models/pill_summary.dart';

class TodayPillScreen extends StatelessWidget {
  const TodayPillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PillProvider>(context);
    final pills = provider.pills;

    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 복약')),
      body: ListView.builder(
        itemCount: pills.length,
        itemBuilder: (context, index) {
          final PillSummary pill = pills[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: pill.imageUrl != null
                  ? Image.network(pill.imageUrl!)
                  : const Icon(Icons.medication),
              title: Text(pill.name),
              subtitle: Text('${pill.doseTime} 복용'),
              trailing: Icon(
                pill.takenPercent == 100 ? Icons.check_circle : Icons.radio_button_unchecked,
                color: pill.takenPercent == 100 ? Colors.green : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
