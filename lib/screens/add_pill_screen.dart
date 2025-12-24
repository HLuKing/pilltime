import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _dosePeriodController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];
  bool isExternal = false;
  int? externalId;
  String? imageUrl;
  String? manufacturer;

  final List<Color> _colors = [
const Color(0xFFEF5350), // 빨강
    const Color(0xFFFFA726), // 주황
    const Color(0xFF26A69A), // 청록
    const Color(0xFF42A5F5), // 파랑
    const Color(0xFF7E57C2), // 보라
    const Color(0xFFEC407A), // 분홍
    const Color(0xFF26C6DA), // 하늘
    const Color(0xFFFF7043), // 다홍
  ];
  Color _selectedColor = const Color(0xFFEF5350); // 색깔 기본값: 빨강
  // String doseTime = '아침';
  // bool external = true;
  // int? externalId;

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
        _dosePeriodController.text = (pill.dosePeriod ?? 7).toString();
        isExternal = pill.external ?? false;
        externalId = pill.externalId;
        imageUrl = pill.imageUrl;
        manufacturer = pill.manufacturer;

        // TODO: 백엔드에서 받은 시간 문자열을 TimeOfDay 리스트로 변환하는 로직 필요
        // 현재 백엔드 상세 조회 DTO 수정에 따라 이 부분은 추후 보완 예정
        // 임시로 기존 값 유지
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('약 정보 불러오기 실패: ${e.toString()}')),
      );
    }
  }

  void _showTimePicker(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('취소'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoButton(
                      child: const Text('완료', style: TextStyle(fontWeight:FontWeight.bold)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime(2025, 1, 1, _selectedTimes[index].hour, _selectedTimes[index].minute),
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedTimes[index] = TimeOfDay.fromDateTime(newDateTime);
                    });
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pillId != null ? '약 수정하기' : '약 추가하기'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel('약 이름'),
              GestureDetector(
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
                      isExternal = true;
                      imageUrl = selectedPill.itemImage;
                      manufacturer = selectedPill.entpName;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _pillNameController,
                    decoration: InputDecoration(
                      hintText: '예: 타이레놀 (터치하여 검색)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (val) => val == null || val.isEmpty ? '약 이름을 입력해주세요' : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. 복용량 및 설명
              _buildLabel('복용량 및 설명'),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "예: 1정, 식후 30분",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // 3. 복용 시간 (동적 추가/삭제)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('복용 시간'),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedTimes.add(const TimeOfDay(hour: 9, minute: 0));
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('시간 추가'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  ),
                ],
              ),
              ..._selectedTimes.asMap().entries.map((entry) {
                int idx = entry.key;
                TimeOfDay time = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showTimePicker(idx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              time.format(context),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 삭제 버튼 (1개일 때는 삭제 불가)
                      if (_selectedTimes.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedTimes.removeAt(idx);
                            });
                          },
                        ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),

              // 4. 복용 기간
              _buildLabel('복용 기간 (일 수)'),
              TextFormField(
                controller: _dosePeriodController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '예: 7',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (val) => val == null || val.isEmpty ? '기간을 입력해주세요' : null,
              ),
              const SizedBox(height: 20),

              // 5. 색상 선택
              _buildLabel('색상'),
              Wrap(
                spacing: 12,
                children: _colors.map((color) {
                  bool isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.grey, width: 3) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: isSelected
                          ?const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _savePill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF536DFE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: const Text('추가하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _savePill() async {
    if (!_formKey.currentState!.validate()) return;

    List<String> formattedTimes = _selectedTimes.map((t) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      return DateFormat('HH:mm:00').format(dt);
    }).toList();

    String colorString = '0x${_selectedColor.value.toRadixString(16).toUpperCase()}';

    final request = PillCreateRequest(
      name: _pillNameController.text,
      dosePeriod: int.tryParse(_dosePeriodController.text) ?? 7,
      description: _descriptionController.text,
      external: isExternal,
      externalId: externalId != null ? externalId : null,
      imageUrl: imageUrl,
      manufacturer: manufacturer,
      doseTimes: formattedTimes,
      color: colorString,
    );

    try {
      if (widget.pillId != null) {
        // 수정 로직 (추후 구현)
      } else {
        await PillApiService().addPill(request);
      }
      if (context.mounted) Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('약 저장 실패: ${e.toString()}')),
        );
      }
    }
  
}
