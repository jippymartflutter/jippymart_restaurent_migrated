import 'dart:convert';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();

  factory NotificationHandler() => _instance;

  NotificationHandler._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel for daily notifications
  static const String channelDailyId = "daily_channel_id";
  static const String channelDailyName = "Daily Reminder";
  static const String channelDailyDescription = "Daily shop opening reminder";

  // Channel for custom notifications
  static const String channelCustomId = "custom_channel_id";
  static const String channelCustomName = "Custom Notifications";
  static const String channelCustomDescription = "Custom order notifications";

  Future<void> initializeNotification() async {
    try {
      print("🔄 Starting notification initialization...");

      // ✅ Initialize timezone
      tz.initializeTimeZones();
      final String currentTimeZone = tz.local.name;
      print("🕒 Timezone initialized: $currentTimeZone");

      // Android initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization
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

      // Create notification channels for Android
      await _createNotificationChannels();

      // ✅ Initialize notifications
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _onNotificationTap(response);
        },
      );

      print("✅ Notification Initialized Successfully!");

      // Schedule daily notification after initialization
      await scheduleDaily8AMNotification();
    } catch (e, stackTrace) {
      print("❌ Error initializing notifications: $e");
      print("Stack trace: $stackTrace");
    }
  }

  /// Create notification channels (Android only)
  Future<void> _createNotificationChannels() async {
    try {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        // Daily notification channel
        const AndroidNotificationChannel dailyChannel =
            AndroidNotificationChannel(
              channelDailyId,
              channelDailyName,
              description: channelDailyDescription,
              importance: Importance.high,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('order_ringtone'),
              enableVibration: true,
              showBadge: true,
            );

        // Custom notification channel
        const AndroidNotificationChannel customChannel =
            AndroidNotificationChannel(
              channelCustomId,
              channelCustomName,
              description: channelCustomDescription,
              importance: Importance.max,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('order_ringtone'),
              enableVibration: true,
              showBadge: true,
            );

        await androidPlugin.createNotificationChannel(dailyChannel);
        await androidPlugin.createNotificationChannel(customChannel);

        print("✅ Notification channels created successfully");
      }
    } catch (e) {
      print("❌ Error creating notification channels: $e");
    }
  }

  /// Schedule daily notification at 8 AM local time
  Future<void> scheduleDaily8AMNotification() async {
    try {
      // Cancel any existing daily notifications
      await cancelAllDailyNotifications();

      // Get current time in local timezone
      final now = tz.TZDateTime.now(tz.local);
      print("🕒 Current local time: $now");
      // Create 8 AM today
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        8, // 8 AM
        0, // 0 minutes
      );

      // If it's already past 8 AM today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        print("⏰ Scheduled time has passed, scheduling for tomorrow");
      }

      print("📅 Scheduling daily notification for: $scheduledDate");
      print("⏰ That's in: ${scheduledDate.difference(now)} from now");
      await flutterLocalNotificationsPlugin.zonedSchedule(
        8888, // Fixed ID for daily notification
        "Good Morning! Are you opening your restaurant today? ",
        "శుభోదయం!ఈరోజు మీ రెస్టారెంట్ తెరవాలా?",
        scheduledDate,
        NotificationDetails(
          android: _getAndroidNotificationDetails(channelDailyId),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print("✅ Daily 8 AM notification scheduled successfully!");
    } catch (e, stackTrace) {
      print("❌ Error scheduling daily notification: $e");
      print("Stack trace: $stackTrace");
    }
  }

  /// Get Android notification details
  AndroidNotificationDetails _getAndroidNotificationDetails(String channelId) {
    return AndroidNotificationDetails(
      channelId,
      channelId == channelDailyId ? channelDailyName : channelCustomName,
      channelDescription: channelId == channelDailyId
          ? channelDailyDescription
          : channelCustomDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('order_ringtone'),
      enableVibration: true,
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: const BigTextStyleInformation(''),
      autoCancel: true,
      ongoing: false,
      showWhen: true,
    );
  }

  /// Show custom notification for orders
  Future<void> showCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    try {
      int randomId = Random().nextInt(100000);
      print("🔔 Showing custom notification: $title - $body");

      await flutterLocalNotificationsPlugin.show(
        randomId,
        title,
        body,
        NotificationDetails(
          android: _getAndroidNotificationDetails(channelCustomId),
          iOS: const DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload != null ? jsonEncode(payload) : null,
      );

      print("✅ Custom notification shown successfully! ID: $randomId");
    } catch (e) {
      print("❌ Error showing custom notification: $e");
    }
  }

  /// Cancel all daily notifications
  Future<void> cancelAllDailyNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(8888);
      print("🗑️ Cancelled all daily notifications");
    } catch (e) {
      print("❌ Error cancelling daily notifications: $e");
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      print("🗑️ Cancelled all notifications");
    } catch (e) {
      print("❌ Error cancelling all notifications: $e");
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print(
      "👆 Notification tapped: ID: ${response.id}, Payload: ${response.payload}",
    );

    try {
      if (response.payload != null) {
        final payload = jsonDecode(response.payload!);
        print("📦 Notification payload: $payload");
        // Handle different notification types
        switch (payload['type']) {
          case 'test':
            // Handle test notification
            break;
          case 'order':
            // Handle order notification
            break;
        }
      }
    } catch (e) {
      print("❌ Error handling notification tap: $e");
    }
  }
}
