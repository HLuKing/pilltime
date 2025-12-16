import 'package:flutter/material.dart';
import '../models/pill_summary.dart';
import '../services/pill_api_service.dart';
import '../services/notification_service.dart';

class PillProvider extends ChangeNotifier {
  final PillApiService _apiService = PillApiService();
  final NotificationService _notificationService = NotificationService();

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
      
      // 약 목록이 변경될 때마다 알림 다시 스케줄링
      await _notificationService.scheduleAllPillNotifications(_pills);
      
    } catch (e) {
      print('Error loading pills: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 테스트 알림 보내기 (디버깅용)
  Future<void> sendTestNotification() async {
    await _notificationService.showTestNotification();
  }

    // 1분 후 테스트 알림 예약
  Future<void> scheduleTestNotification() async {
    await _notificationService.scheduleTestNotification();
  }

  // 특정 약 알림 취소
  Future<void> cancelPillNotification(int pillId) async {
    await _notificationService.cancelPillNotification(pillId);
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }
}