import 'package:flutter/material.dart';
import '../models/medicine_response.dart';
import '../services/pill_api_service.dart';

class SearchPillScreen extends StatefulWidget {
  final Function(MedicineResponse) onPillSelected;

  const SearchPillScreen({super.key, required this.onPillSelected});

  @override
  State<SearchPillScreen> createState() => _SearchPillScreenState();
}

class _SearchPillScreenState extends State<SearchPillScreen> {
  final TextEditingController _controller = TextEditingController();
  final PillApiService _apiService = PillApiService();

  List<MedicineResponse> _results = [];
  MedicineResponse? _selectedPill;
  bool _isLoading = false;
  String? _error;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
      _selectedPill = null;
    });

    try {
      final results = await _apiService.searchPills(query);
      setState(() => _results = results);
    } catch (e) {
      setState(() => _error = '검색에 실패했습니다: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildResultItem(MedicineResponse pill) {
    final isSelected = pill == _selectedPill;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPill = pill;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.medication, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pill.itemName ?? '이름 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(pill.entpName ?? '제조사 없음', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('약 검색하기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: '약 이름 입력',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_results.isEmpty)
              const Text('검색 결과 없음')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, index) => _buildResultItem(_results[index]),
                ),
              ),
            const SizedBox(height: 16),
            if (_selectedPill != null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _selectedPill);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('선택하기'),
              ),
          ],
        ),
      ),
    );
  }
}
