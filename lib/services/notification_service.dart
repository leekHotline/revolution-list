import 'package:flutter/foundation.dart';

class NotificationService {
  static Future<void> init() async {
    // Web 平台不需要初始化
    if (kIsWeb) {
      debugPrint('Notifications: Web platform - using browser notifications');
      return;
    }
    debugPrint('Notifications: Mobile platform initialized');
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    // 简单打印通知内容（实际移动端可以后续集成）
    debugPrint('📢 Notification: $title - $body');
  }
}