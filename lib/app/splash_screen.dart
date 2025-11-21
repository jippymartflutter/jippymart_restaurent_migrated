import 'package:flutter_svg/svg.dart';
import 'package:jippymart_restaurant/app/auth_screen/login_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/app/on_boarding_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/const/image_const.dart';
import 'package:jippymart_restaurant/utils/const/text_style_const.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/service/app_update_service.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToMainApp();
        }
      });
    } catch (e) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _navigateToMainApp();
        }
      });
    }
  }

  void _navigateToMainApp() async {
    try {
      try {
        bool updateRequired = await AppUpdateService.checkForUpdate();
        if (updateRequired) {
          return; // Don't proceed to next screen - let user decide
        }
      } catch (e) {}
      _proceedToMainApp();
    } catch (e) {
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1200),
      );
    }
  }

  void _proceedToMainApp() async {
    String userId = await FireStoreUtils.getCurrentUid();
    try {
      if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
        Get.offAll(
          () => const OnBoardingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200),
        );
      } else {
        bool isLogin = await FireStoreUtils.isLogin();
        if (isLogin == true) {
          await FireStoreUtils.getUserProfile(
           userId,
          ).then((value) async {
            if (value != null) {
              UserModel userModel = value;
              if (userModel.role == Constant.userRoleVendor) {
                if (userModel.active == true) {
                  userModel.fcmToken = await NotificationService.getToken();
                  await FireStoreUtils.updateUser(userModel);
                  Get.offAll(
                    () => const DashBoardScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 1200),
                  );
                } else {
                  await FirebaseAuth.instance.signOut();
                  Get.offAll(
                    () => const LoginScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 1200),
                  );
                }
              } else {
                await FirebaseAuth.instance.signOut();
                Get.offAll(
                  () => const LoginScreen(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 1200),
                );
              }
            }
          });
        } else {
          await FirebaseAuth.instance.signOut();
          Get.offAll(
            () => const LoginScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 1200),
          );
        }
      }
    } catch (e) {
      Get.offAll(
        () => const LoginScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 1200),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SvgPicture.asset(ImageConst.splashImage, fit: BoxFit.fill),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Welcome to Jippy Mart",
                style: TextStyleConst.whiteMedium24,
              ),
              Text("Merchant", style: TextStyleConst.whiteMedium24),
              SizedBox(height: 10),
              Center(
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_logo.png",
                          width: 150,
                          height: 150,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text("0% ", style: TextStyleConst.whiteMedium48),
              Text("Commission ", style: TextStyleConst.whiteMedium24),
              Text(
                "Let’s Build Local Together",
                style: TextStyleConst.whiteMedium24,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

typedef SplashScreen = VideoSplashScreen;
