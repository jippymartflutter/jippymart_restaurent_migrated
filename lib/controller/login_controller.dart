import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jippymart_restaurant/app/auth_screen/signup_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/app_not_access_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:jippymart_restaurant/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
//import 'package:jippymart_restaurant/utils/send_notification.dart';
import 'package:http/http.dart' as http;


class LoginController extends GetxController {
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> passwordEditingController =
      TextEditingController().obs;

  RxBool passwordVisible = true.obs;
  @override
  void onInit() {
    super.onInit();
  }
  static Future<Map<String, dynamic>> loginWithEmailAndPasswordApi(
      String email, String password) async {
    try {
      final body = {
        'email': email,
        'password': password,
      };
      print(" loginWithEmailAndPasswordApi ${body}");
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
  loginWithEmailAndPassword() async {
    ShowToastDialog.showLoader("Please wait.".tr);
    try {
      final response = await loginWithEmailAndPasswordApi(
        emailEditingController.value.text.toLowerCase().trim(),
        passwordEditingController.value.text.trim(),
      );
      if (response['success'] == true) {
        final userData = response['data'];
        await _saveUserDataToSharedPreferences(userData);
        UserModel? userModel = await _convertApiResponseToUserModel(userData);
        if (userModel != null) {
          if (userModel.role == Constant.userRoleVendor) {
            if (userModel.active == true) {
              userModel.fcmToken = await NotificationService.getToken();
              await FireStoreUtils.updateUser(userModel);
              bool isPlanExpire = false;
              if (userModel.subscriptionPlan?.id != null) {
                if (userModel.subscriptionExpiryDate == null) {
                  if (userModel.subscriptionPlan?.expiryDay == '-1') {
                    isPlanExpire = false;
                  } else {
                    isPlanExpire = true;
                  }
                } else {
                  DateTime expiryDate = userModel.subscriptionExpiryDate!.toDate();
                  isPlanExpire = expiryDate.isBefore(DateTime.now());
                }
              } else {
                isPlanExpire = true;
              }

              if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
                if (Constant.adminCommission?.isEnabled == false &&
                    Constant.isSubscriptionModelApplied == false) {
                  Get.offAll(const DashBoardScreen());
                } else {
                  Get.offAll(const SubscriptionPlanScreen());
                }
              } else if (userModel.subscriptionPlan?.features?.restaurantMobileApp == true) {
                Get.offAll(const DashBoardScreen());
              } else {
                Get.offAll(const AppNotAccessScreen());
              }
            } else {
              await _clearUserData();
              ShowToastDialog.showToast(
                  "This user is disable please contact to administrator".tr);
            }
          } else {
            await _clearUserData();
          }
        }
      } else {
        ShowToastDialog.showToast(response['message'] ?? "Login failed".tr);
      }
    } catch (e) {
      print("Login error: $e");
      ShowToastDialog.showToast("Login failed. Please try again.".tr);
    }
    ShowToastDialog.closeLoader();
  }

// Helper method to save user data to SharedPreferences
  Future<void> _saveUserDataToSharedPreferences(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_id', userData['firebase_id'] ?? '');
    await prefs.setString('email', userData['email'] ?? '');
    await prefs.setString('fcm_token', userData['fcmToken'] ?? '');
    await prefs.setString('first_name', userData['firstName'] ?? '');
    await prefs.setString('last_name', userData['lastName'] ?? '');
    await prefs.setString('phone_number', userData['phoneNumber'] ?? '');
    await prefs.setString('country_code', userData['countryCode'] ?? '');
    await prefs.setString('role', userData['role'] ?? '');
    await prefs.setBool('is_active', userData['isActive'] ?? false);
    await prefs.setString('user_id', userData['id'].toString());
    await prefs.setString('profile_picture', userData['profilePictureURL'] ?? '');
    await prefs.setString('zone_id', userData['zoneId'] ?? '');
    await prefs.setBool('is_document_verify', userData['isDocumentVerify'] == "1");
    await prefs.setBool('is_logged_in', true);
  }

// Helper method to convert API response to UserModel
  Future<UserModel?> _convertApiResponseToUserModel(Map<String, dynamic> userData) async {
    try {
      // Convert the API response to your UserModel
      // You'll need to adjust this based on your actual UserModel structure
      return UserModel(
        id: userData['id']?.toString() ?? userData['firebase_id'],
        firebaseId: userData['firebase_id'],
        firstName: userData['firstName'],
        lastName: userData['lastName'],
        email: userData['email'],
        phoneNumber: userData['phoneNumber'],
        countryCode: userData['countryCode'],
        role: userData['role'],
        active: userData['isActive'] ?? userData['active'] == 1,
        profilePictureURL: userData['profilePictureURL'],
        fcmToken: userData['fcmToken'],
        zoneId: userData['zoneId'],
        isDocumentVerify: userData['isDocumentVerify'] == "1",
        subscriptionPlanId: userData['subscriptionPlanId'],
        subscriptionExpiryDate: userData['subscriptionExpiryDate'] != null
            ? Timestamp.fromDate(DateTime.parse(userData['subscriptionExpiryDate']))
            : null,
        // Add other fields as needed
      );
    } catch (e) {
      print("Error converting to UserModel: $e");
      return null;
    }
  }

// Helper method to clear user data on logout/error
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_id');
    await prefs.remove('email');
    await prefs.remove('fcm_token');
    await prefs.remove('first_name');
    await prefs.remove('last_name');
    await prefs.remove('phone_number');
    await prefs.remove('country_code');
    await prefs.remove('role');
    await prefs.remove('is_active');
    await prefs.remove('user_id');
    await prefs.remove('profile_picture');
    await prefs.remove('zone_id');
    await prefs.remove('is_document_verify');
    await prefs.setBool('is_logged_in', false);
  }
  // loginWithEmailAndPassword() async {
  //   ShowToastDialog.showLoader("Please wait.".tr);
  //   try {
  //     final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailEditingController.value.text.toLowerCase().trim(),
  //       password: passwordEditingController.value.text.trim(),
  //     );
  //     UserModel? userModel =
  //         await FireStoreUtils.getUserProfile(credential.user!.uid);
  //     if (userModel != null) {
  //       if (userModel.role == Constant.userRoleVendor) {
  //         if (userModel.active == true) {
  //           userModel.fcmToken = await NotificationService.getToken();
  //           await FireStoreUtils.updateUser(userModel);
  //           bool isPlanExpire = false;
  //           if (userModel.subscriptionPlan?.id != null) {
  //             if (userModel.subscriptionExpiryDate == null) {
  //               if (userModel.subscriptionPlan?.expiryDay == '-1') {
  //                 isPlanExpire = false;
  //               } else {
  //                 isPlanExpire = true;
  //               }
  //             } else {
  //               DateTime expiryDate =
  //                   userModel.subscriptionExpiryDate!.toDate();
  //               isPlanExpire = expiryDate.isBefore(DateTime.now());
  //             }
  //           } else {
  //             isPlanExpire = true;
  //           }
  //           if (userModel.subscriptionPlanId == null || isPlanExpire == true) {
  //             if (Constant.adminCommission?.isEnabled == false &&
  //                 Constant.isSubscriptionModelApplied == false) {
  //               Get.offAll(const DashBoardScreen());
  //             } else {
  //               Get.offAll(const SubscriptionPlanScreen());
  //             }
  //           } else if (userModel
  //                   .subscriptionPlan?.features?.restaurantMobileApp ==
  //               true) {
  //             Get.offAll(const DashBoardScreen());
  //           } else {
  //             Get.offAll(const AppNotAccessScreen());
  //           }
  //         } else {
  //           await FirebaseAuth.instance.signOut();
  //           ShowToastDialog.showToast(
  //               "This user is disable please contact to administrator".tr);
  //         }
  //       } else {
  //         await FirebaseAuth.instance.signOut();
  //         // ShowToastDialog.showToast("This user is disable please contact to administrator".tr);
  //       }
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     print(e.code);
  //     if (e.code == 'user-not-found') {
  //       ShowToastDialog.showToast("No user found for that email.".tr);
  //     } else if (e.code == 'wrong-password') {
  //       ShowToastDialog.showToast("Wrong password provided for that user.".tr);
  //     } else if (e.code == 'invalid-email') {
  //       ShowToastDialog.showToast("Invalid Email.".tr);
  //     } else {
  //       ShowToastDialog.showToast("${e.message}");
  //     }
  //   }
  //   ShowToastDialog.closeLoader();
  // }

}


   Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firebase_id': prefs.getString('firebase_id') ?? '',
      'email': prefs.getString('email') ?? '',
      'fcm_token': prefs.getString('fcm_token') ?? '',
      'first_name': prefs.getString('first_name') ?? '',
      'last_name': prefs.getString('last_name') ?? '',
      'phone_number': prefs.getString('phone_number') ?? '',
      'country_code': prefs.getString('country_code') ?? '',
      'role': prefs.getString('role') ?? '',
      'is_active': prefs.getBool('is_active') ?? false,
      'user_id': prefs.getString('user_id') ?? '',
      'profile_picture': prefs.getString('profile_picture') ?? '',
      'zone_id': prefs.getString('zone_id') ?? '',
      'is_document_verify': prefs.getBool('is_document_verify') ?? false,
      'is_logged_in': prefs.getBool('is_logged_in') ?? false,
    };
  }
Future<String>? getFirebaseId() async {
  final prefs = await SharedPreferences.getInstance();
  return  prefs.getString('firebase_id')??'' ;
}

Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

   Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
