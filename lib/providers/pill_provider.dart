import 'package:flutter/material.dart';
import '../models/pill_summary.dart';
import '../services/pill_api_service.dart';

class PillProvider extends ChangeNotifier {
  final PillApiService _apiService = PillApiService();

  List<PillSummary> _pills = [];
  bool _isLoading = false;

  List<PillSummary> get pills => _pills;
  bool get isLoading => _isLoading;

  Future<void> loadPills() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedPills = await _apiService.fetchPillSummaries();
      _pills = fetchedPills;
    } catch (e) {
      print('Error loading pills: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
