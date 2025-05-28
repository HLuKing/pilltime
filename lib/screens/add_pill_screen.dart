import 'package:flutter/material.dart';
import 'package:pillsolo/screens/search_pill_screen.dart';
import '../models/pill_create_request.dart';
import '../services/pill_api_service.dart';

class AddPillScreen extends StatefulWidget {
  final int? pillId;

  const AddPillScreen({super.key, this.pillId});

  @override
  State<AddPillScreen> createState() => _AddPillScreenState();
}

class _AddPillScreenState extends State<AddPillScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pillNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dosePeriodController = TextEditingController();

  String doseTime = '아침';
  bool external = true;
  int? externalId;

  @override
  void initState() {
    super.initState();
    if (widget.pillId != null) {
      _loadPillData(widget.pillId!);
    }
  }

  Future<void> _loadPillData(int id) async {
    try {
      final pill = await PillApiService().fetchPillDetail(id);
      setState(() {
        _pillNameController.text = pill.name ?? '';
        _descriptionController.text = pill.description ?? '';
        _dosePeriodController.text = pill.dosePeriod.toString();
        doseTime = pill.doseTime ?? '아침';
        external = pill.external ?? true;
        externalId = pill.externalId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('약 정보 불러오기 실패: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약 추가하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _pillNameController,
                decoration: const InputDecoration(labelText: '약 이름'),
                readOnly: true,
                onTap: () async {
                  final selectedPill = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchPillScreen(
                        onPillSelected: (pill) {
                          Navigator.pop(context, pill);
                        },
                      ),
                    ),
                  );

                  if (selectedPill != null) {
                    setState(() {
                      _pillNameController.text = selectedPill.itemName ?? '';
                      externalId = selectedPill.itemSeq;
                      external = true;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: doseTime,
                items: ['아침', '점심', '저녁', '취침']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => doseTime = val!),
                decoration: const InputDecoration(labelText: '복용 시간'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosePeriodController,
                decoration: const InputDecoration(labelText: '복용 기간 (일 수)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '복용 설명'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  final request = PillCreateRequest(
                    name: _pillNameController.text,
                    doseTime: doseTime,
                    dosePeriod:
                        int.tryParse(_dosePeriodController.text) ?? 7,
                    description: _descriptionController.text,
                    external: external,
                    externalId: externalId,
                  );

                  try {
                    if (widget.pillId != null) {
                      await PillApiService()
                          .updatePill(widget.pillId!, request);
                    } else {
                      await PillApiService().addPill(request);
                    }

                    if (context.mounted) Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('오류: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('저장'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
