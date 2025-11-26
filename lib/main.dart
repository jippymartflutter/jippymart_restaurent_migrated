import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/splash_screen.dart';
import 'package:jippymart_restaurant/firebase_options.dart';
import 'package:jippymart_restaurant/utils/notification/daily_notification_service.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/global_setting_controller.dart';
import 'package:jippymart_restaurant/firebase_options.dart';
import 'package:jippymart_restaurant/models/language_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/service/localization_service.dart';
import 'package:jippymart_restaurant/themes/styles.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

// Old initialization code
/*
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
  );
  await Preferences.initPref();
  runApp(const MyApp());
}
*/

Future<void> initializeFirebase() async {
  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      print('Firebase is already initialized');
      return;
    }
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    await FirebaseAppCheck.instance.activate(
      // Use debug provider for development
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    print('Firebase App Check initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Don't rethrow the error, just log it
  }
}
// Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
//   log("Background FCM: ${message.messageId}");
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   await Preferences.initPref();
//   await AudioPlayerService.initAudio();
//   await AudioPlayerService.playSound(true);
// }
// Add this to your main screen or somewhere accessible
// Replace your _testNotifications function with this:

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // Initialize Firebase
    await initializeFirebase();

    // Initialize preferences
    await Preferences.initPref();
    // Initialize notifications immediately
    // Initialize notifications immediately
    // ✅ Start background service
    await initializeService();
    // Start background service
    await initializeService();
    // Initialize notifications
    final notificationService = NotificationService();
    await notificationService.initInfo();
    FirebaseMessaging.onBackgroundMessage(firebaseMessageBackgroundHandle);
    // Run the app
    runApp(const MyApp());
  } catch (e) {
    print('Error in main: $e');
    // Run the app even if there's an error
    runApp(const MyApp());
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStartService,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'order_channel',
      initialNotificationTitle: 'Jippymart Restaurant',
      initialNotificationContent: 'Listening for new orders...',
      foregroundServiceTypes: [AndroidForegroundType.mediaPlayback],
      // foregroundServiceType: AndroidForegroundType.mediaPlayback,
    ),
    iosConfiguration: IosConfiguration(),
  );
  await service.startService();
}

@pragma('vm:entry-point')
void onStartService(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Preferences.initPref();
  await AudioPlayerService.initAudio();
  FirebaseMessaging.onMessage.listen((message) async {
    log("🔥 ForegroundService received FCM");
    // await AudioPlayerService.playSound(true);
  });
  FirebaseMessaging.onBackgroundMessage(firebaseMessageBackgroundHandle);
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) async {
      await AudioPlayerService.playSound(false);
      service.stopSelf();
    });
    // Detect if user swiped app away or system killed app
    service.setAsForegroundService();
    service.on('onDestroy').listen((event) async {
      log("🛑 Service destroyed, stopping audio...");
      await AudioPlayerService.playSound(false);
    });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    getCurrentAppTheme();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Preferences.getString(
        Preferences.languageCodeKey,
      ).toString().isNotEmpty) {
        LanguageModel languageModel = Constant.getLanguage();
        LocalizationService().changeLocale(languageModel.slug.toString());
      } else {
        LanguageModel languageModel = LanguageModel(
          slug: "en",
          isRtl: false,
          title: "English",
        );
        Preferences.setString(
          Preferences.languageCodeKey,
          jsonEncode(languageModel.toJson()),
        );
      }
    });
    // In your initState or after login
    // ✅ FIXED: Initialize notifications only once
    _initializeNotificationsOnce();
    super.initState();
  }

  bool _notificationInitialized = false; // Add this flag
  // ✅ NEW: Initialize notifications only once
  Future<void> _initializeNotificationsOnce() async {
    if (!_notificationInitialized) {
      _notificationInitialized = true;
      await NotificationHandler().initializeNotification();
      print(
        "🎯 Daily 8 AM notification scheduled. No test notifications will be shown.",
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.paused) {
      AudioPlayerService.initAudio();
    }
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme = await themeChangeProvider
        .darkThemePreference
        .getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return themeChangeProvider;
      },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return GetMaterialApp(
            title: 'Jippymart Restaurant'.tr,
            debugShowCheckedModeBanner: false,
            theme: Styles.themeData(
              themeChangeProvider.darkTheme == 0
                  ? true
                  : themeChangeProvider.darkTheme == 1
                  ? false
                  : false,
              context,
            ),
            localizationsDelegates: const [CountryLocalizations.delegate],
            locale: LocalizationService.locale,
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            builder: EasyLoading.init(),
            home: GetBuilder<GlobalSettingController>(
              init: GlobalSettingController(),
              builder: (context) {
                return const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
