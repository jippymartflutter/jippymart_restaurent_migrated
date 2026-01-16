import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/firebase_options.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/notification/daily_notification_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';

// "Good Morning! Are you opening your restaurant today? ",
// "శుభోదయం!ఈరోజు మీ రెస్టారెంట్ తెరవాలా?",
Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Preferences.initPref();
      // Always check actual order state before playing sound (most reliable method)
      bool hasNewOrders = await NotificationService.checkIfHasNewOrders();
      await AudioPlayerService.initAudio();
        if (hasNewOrders) {
          await AudioPlayerService.playSound(true);
        } else {
          await AudioPlayerService.playSound(false);
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
        // Always check actual order state before playing sound (most reliable method)
        // This prevents sound from restarting when orders are accepted from admin panel
        bool hasNewOrders = await NotificationService.checkIfHasNewOrders();
        await AudioPlayerService.initAudio();
        if (hasNewOrders) {
          await AudioPlayerService.playSound(true);
        } else {
          // Stop sound if no new orders
          await AudioPlayerService.playSound(false);
        }
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      if (message.notification != null) {
        log(message.notification.toString());
      }
      // Always check actual order state before playing sound (most reliable method)
      bool hasNewOrders = await NotificationService.checkIfHasNewOrders();
      await AudioPlayerService.initAudio();
        if (hasNewOrders) {
          await AudioPlayerService.playSound(true);
        } else {
          await AudioPlayerService.playSound(false);
        }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await FirebaseMessaging.instance.subscribeToTopic("restaurant");
  }

  static getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    return token!;
  }

  /// Check if there are actually new orders in the system
  /// This prevents sound from playing when orders have been accepted/rejected
  static Future<bool> checkIfHasNewOrders() async {
    try {
      // Try to get HomeController if it's registered
      if (Get.isRegistered<HomeController>()) {
        HomeController controller = Get.find<HomeController>();
        if (controller.newOrderList.isNotEmpty) {
          return true;
        } else {
          return false;
        }
      } else {
        // If controller not available (e.g., in background isolate), default to false
        return false;
      }
    } catch (e) {
      // On error, default to false (don't play sound)
      return false;
    }
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
          return false;
        }
        
        // Play sound for new/pending orders
        if (status == Constant.orderPlaced || 
            status?.toLowerCase() == Constant.orderPending.toLowerCase()) {
          return true;
        }
      }
      
      // Check if notification type indicates a new order
      String? notificationType = message.data['type']?.toString();
      if (notificationType == Constant.newOrderPlaced || 
          notificationType == Constant.newDeliveryOrder) {
        return true;
      }
      
      // Default: don't play sound if we can't determine the status
      return false;
    } catch (e) {
      // On error, default to false (don't play sound)
      return false;
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
