import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models/pill_summary.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // 복용 시간별 알림 시간 설정
  static const Map<String, int> doseTimeHours = {
    '아침': 9,
    '점심': 13,
    '저녁': 19,
    '취침': 23,
  };

  Future<void> init() async {
    // 타임존 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // 알림 권한 요청
    await _requestPermissions();

    // 알림 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermissions() async {
    // Android 13+ 알림 권한 요청
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    
    // iOS 알림 권한 요청
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // 알림 탭 시 처리
  void _onNotificationTapped(NotificationResponse response) {
    print('알림 탭됨: ${response.payload}');
    // 여기에 알림 탭 시 특정 화면으로 이동하는 로직 추가 가능
  }

  // 모든 약에 대한 알림 스케줄링
  Future<void> scheduleAllPillNotifications(List<PillSummary> pills) async {
    // 기존 알림 모두 취소
    await cancelAllNotifications();

    // 각 약에 대해 알림 스케줄링
    for (PillSummary pill in pills) {
      await _schedulePillNotification(pill);
    }
  }

  // 개별 약 알림 스케줄링
  Future<void> _schedulePillNotification(PillSummary pill) async {
    final hour = doseTimeHours[pill.doseTime];
    if (hour == null) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, 0);
    
    // 오늘 시간이 지났으면 내일로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      pill.id, // 알림 ID로 약 ID 사용
      '💊 복약 알림',
      '${pill.name} 복용 시간입니다 (${pill.doseTime})',
      tzScheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminder',
          '복약 알림',
          channelDescription: '약 복용 시간을 알려주는 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // 필수 파라미터 추가
      payload: 'pill_${pill.id}',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
    );
  }

  // 특정 약 알림 취소
  Future<void> cancelPillNotification(int pillId) async {
    await _notifications.cancel(pillId);
  }

  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // 즉시 테스트 알림 보내기
  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      '💊 테스트 알림',
      '알림이 정상적으로 작동합니다!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminder',
          '복약 알림',
          channelDescription: '약 복용 시간을 알려주는 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(const Duration(minutes: 1));

    await _notifications.zonedSchedule(
      998,
      '💊 예약 테스트 알림',
      '아침 약 복용 시간입니다!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pill_reminder',
          '복약 알림',
          channelDescription: '약 복용 시간을 알려주는 알림',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 예약된 알림 목록 확인 (디버깅용)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}