import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'parent_dashboard_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  final ParentDashboardService _parentService = ParentDashboardService();

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission (Android 13+)
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          // Handle notification tap
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      _isInitialized = true;
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Notification service initialization error: $e');
    }
  }

  /// Show achievement notification
  Future<void> showAchievementNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Check if achievement alerts are enabled
    if (!_parentService.getSettings().achievementAlerts) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'achievements',
        'الإنجازات',
        channelDescription: 'إشعارات الإنجازات والملصقات',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails();

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Show badge unlocked notification
  Future<void> showBadgeUnlocked(String badgeId) async {
    final badgeNames = {
      'badge_first_star': 'أول نجمة',
      'badge_star_collector': 'جامع النجوم',
      'badge_star_master': 'سيد النجوم',
      'badge_getting_started': 'البداية',
      'badge_level_expert': 'خبير المستويات',
      'badge_daily_player': 'لاعب يومي',
      'badge_dedicated': 'متفانٍ',
    };

    final badgeName = badgeNames[badgeId] ?? badgeId;
    await showAchievementNotification(
      title: '🏆 إنجاز جديد!',
      body: 'لقد حصلت على إنجاز: $badgeName',
      payload: badgeId,
    );
  }

  /// Show sticker unlocked notification
  Future<void> showStickerUnlocked(String stickerId) async {
    final stickerNames = {
      'happy_brain': 'دماغ سعيد',
      'thinking_brain': 'دماغ مفكر',
      'winner_brain': 'دماغ فائز',
      'level_up': 'ارتقاء',
      'super_smart': 'ذكي جداً',
      'mini_genius': 'عبقري صغير',
    };

    final stickerName = stickerNames[stickerId] ?? stickerId;
    await showAchievementNotification(
      title: '⭐ ملصق جديد!',
      body: 'لقد حصلت على ملصق: $stickerName',
      payload: stickerId,
    );
  }
}

