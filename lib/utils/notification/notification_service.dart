import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jippymart_restaurant/firebase_options.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/notification/daily_notification_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:jippymart_restaurant/constant/constant.dart';

// "Good Morning! Are you opening your restaurant today? ",
// "శుభోదయం!ఈరోజు మీ రెస్టారెంట్ తెరవాలా?",
Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Preferences.initPref();
  // Only play sound for new order notifications
  bool shouldPlaySound = NotificationService.shouldPlaySoundForNotification(message);
  if (shouldPlaySound) {
    await AudioPlayerService.initAudio();
    await AudioPlayerService.playSound(true);
  }
  final notificationService = NotificationService();
  await notificationService.initInfo();
}
class NotificationService {
  NotificationHandler notificationHandler = NotificationHandler();
  //////////////
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initInfo() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized ||
        request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings(
            '@mipmap/ic_launcher',
            // '@mipmap/ic_launcher'
          );
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iosInitializationSettings,
          );
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (payload) async {
          await AudioPlayerService.playSound(false);
        },
      );
      // ✅ Initialize and schedule daily 8 AM notification
      await notificationHandler.initializeNotification();
      setupInteractedMessage();
    }
  }

  // In NotificationService, update the _initializeDailyNotification method:

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      FirebaseMessaging.onBackgroundMessage(
        (message) => firebaseMessageBackgroundHandle(message),
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("::::::::::::onMessage:::::::::::::::::");
      if (message.notification != null) {
        log(message.notification.toString());
        display(message);
        // Only play sound for new order notifications, not for already accepted/rejected orders
        bool shouldPlaySound = NotificationService.shouldPlaySoundForNotification(message);
        if (shouldPlaySound) {
          await AudioPlayerService.initAudio();
          await AudioPlayerService.playSound(true); // 🔊 Start continuous sound
        } else {
          log("Skipping sound - notification is not for a new pending order");
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        log(message.notification.toString());
      }
      // Only play sound for new order notifications
      bool shouldPlaySound = NotificationService.shouldPlaySoundForNotification(message);
      if (shouldPlaySound) {
        await AudioPlayerService.initAudio();
        await AudioPlayerService.playSound(true);
      }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("restaurant");
  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  /// Check if sound should be played for this notification (static version for background handler)
  /// Only play sound for new/pending orders, not for already accepted/rejected orders
  static bool shouldPlaySoundForNotification(RemoteMessage message) {
    try {
      // Check notification data for order status
      if (message.data.containsKey('status')) {
        String? status = message.data['status']?.toString();
        log("Notification status: $status");
        
        // Don't play sound if order is already accepted, rejected, cancelled, or completed
        if (status == Constant.orderAccepted ||
            status == Constant.orderRejected ||
            status == Constant.orderCancelled ||
            status == Constant.orderCompleted ||
            status == Constant.orderInTransit ||
            status == Constant.orderShipped) {
          log("Skipping sound - order status is: $status");
          return false;
        }
        
        // Play sound for new/pending orders
        if (status == Constant.orderPlaced || 
            status?.toLowerCase() == Constant.orderPending.toLowerCase()) {
          log("Playing sound - new order detected with status: $status");
          return true;
        }
      }
      
      // Check if notification type indicates a new order
      // If no status is provided but it's a new order notification, play sound
      // This handles cases where status might not be in the data payload
      String? notificationType = message.data['type']?.toString();
      if (notificationType == Constant.newOrderPlaced || 
          notificationType == Constant.newDeliveryOrder) {
        log("Playing sound - new order notification type: $notificationType");
        return true;
      }
      
      // Default: play sound if we can't determine the status
      // This ensures backward compatibility but logs a warning
      log("Warning: Could not determine order status from notification data. Playing sound by default.");
      return true;
    } catch (e) {
      log("Error checking notification status: $e");
      // On error, default to playing sound for backward compatibility
      return true;
    }
  }


  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data:  [32m${message.notification!.body.toString()} [0m');
    try {
      AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'order_channel', // <-- new channel ID
        'Order Notifications', // <-- new channel name
        description: 'Channel for order notifications',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound(
          'order_ringtone',
        ), // <-- custom sound
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      AndroidNotificationDetails notificationDetails =
          AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            sound: RawResourceAndroidNotificationSound('order_ringtone'),
            // icon: '@mipmap/ic_launcher',
            // largeIcon: const DrawableResourceAndroidBitmap(
            //   'ic_launcher',
            // ), // Optional: for large
          );
      const DarwinNotificationDetails darwinNotificationDetails =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );
      NotificationDetails notificationDetailsBoth = NotificationDetails(
        android: notificationDetails,
        iOS: darwinNotificationDetails,
      );
      await FlutterLocalNotificationsPlugin().show(
        0,
        message.notification!.title,
        message.notification!.body,
        notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}

//
//
// import 'dart:convert';
// import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
//   log("BackGround Message :: ${message.messageId}");
// }
//
// class NotificationService {
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   initInfo() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     var request = await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//
//     if (request.authorizationStatus == AuthorizationStatus.authorized ||
//         request.authorizationStatus == AuthorizationStatus.provisional) {
//       const AndroidInitializationSettings initializationSettingsAndroid =
//           AndroidInitializationSettings('@mipmap/ic_launcher');
//       var iosInitializationSettings = const DarwinInitializationSettings();
//       final InitializationSettings initializationSettings =
//           InitializationSettings(
//               android: initializationSettingsAndroid,
//               iOS: iosInitializationSettings);
//       await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//           onDidReceiveNotificationResponse: (payload) {});
//       setupInteractedMessage();
//     }
//   }
//
//   Future<void> setupInteractedMessage() async {
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       FirebaseMessaging.onBackgroundMessage(
//           (message) => firebaseMessageBackgroundHandle(message));
//     }
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       log("::::::::::::onMessage:::::::::::::::::");
//       if (message.notification != null) {
//         log(message.notification.toString());
//         display(message);
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         log(message.notification.toString());
//       }
//     });
//     log("::::::::::::Permission authorized:::::::::::::::::");
//     await FirebaseMessaging.instance.subscribeToTopic("restaurant");
//   }
//
//   static getToken() async {
//     String? token = await FirebaseMessaging.instance.getToken();
//     return token!;
//   }
//
//   void display(RemoteMessage message) async {
//     log('Got a message whilst in the foreground!');
//     log('Message data:  [32m${message.notification!.body.toString()} [0m');
//     try {
//       AndroidNotificationChannel channel = const AndroidNotificationChannel(
//         'order_channel', // <-- new channel ID
//         'Order Notifications', // <-- new channel name
//         description: 'Channel for order notifications',
//         importance: Importance.max,
//         sound: RawResourceAndroidNotificationSound('order_ringtone'), // <-- custom sound
//       );
//       await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
//       AndroidNotificationDetails notificationDetails =
//           AndroidNotificationDetails(channel.id, channel.name,
//               channelDescription: channel.description,
//               importance: Importance.high,
//               priority: Priority.high,
//               ticker: 'ticker',
//               sound: RawResourceAndroidNotificationSound('order_ringtone'));
//       const DarwinNotificationDetails darwinNotificationDetails =
//           DarwinNotificationDetails(
//               presentAlert: true, presentBadge: true, presentSound: true);
//       NotificationDetails notificationDetailsBoth = NotificationDetails(
//           android: notificationDetails, iOS: darwinNotificationDetails);
//       await FlutterLocalNotificationsPlugin().show(
//         0,
//         message.notification!.title,
//         message.notification!.body,
//         notificationDetailsBoth,
//         payload: jsonEncode(message.data),
//       );
//     } on Exception catch (e) {
//       log(e.toString());
//     }
//   }
// }
