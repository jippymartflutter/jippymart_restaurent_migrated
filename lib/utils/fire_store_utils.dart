import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/controller/login_controller.dart';
import 'package:mime/mime.dart';
import 'package:jippymart_restaurant/app/chat_screens/ChatVideoContainer.dart';
import 'package:jippymart_restaurant/constant/collection_name.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/AttributesModel.dart';
import 'package:jippymart_restaurant/models/admin_commission.dart';
import 'package:jippymart_restaurant/models/advertisement_model.dart';
import 'package:jippymart_restaurant/models/conversation_model.dart';
import 'package:jippymart_restaurant/models/dine_in_booking_model.dart';
import 'package:jippymart_restaurant/models/document_model.dart';
import 'package:jippymart_restaurant/models/driver_document_model.dart';
import 'package:jippymart_restaurant/models/email_template_model.dart';
import 'package:jippymart_restaurant/models/coupon_model.dart';
import 'package:jippymart_restaurant/models/inbox_model.dart';
import 'package:jippymart_restaurant/models/mail_setting.dart';
import 'package:jippymart_restaurant/models/notification_model.dart';
import 'package:jippymart_restaurant/models/on_boarding_model.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/payment_model/cod_setting_model.dart';
import 'package:jippymart_restaurant/models/payment_model/flutter_wave_model.dart';
import 'package:jippymart_restaurant/models/payment_model/mercado_pago_model.dart';
import 'package:jippymart_restaurant/models/payment_model/mid_trans.dart';
import 'package:jippymart_restaurant/models/payment_model/orange_money.dart';
import 'package:jippymart_restaurant/models/payment_model/pay_fast_model.dart';
import 'package:jippymart_restaurant/models/payment_model/pay_stack_model.dart';
import 'package:jippymart_restaurant/models/payment_model/paypal_model.dart';
import 'package:jippymart_restaurant/models/payment_model/paytm_model.dart';
import 'package:jippymart_restaurant/models/payment_model/razorpay_model.dart';
import 'package:jippymart_restaurant/models/payment_model/stripe_model.dart';
import 'package:jippymart_restaurant/models/payment_model/wallet_setting_model.dart';
import 'package:jippymart_restaurant/models/payment_model/xendit.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/rating_model.dart';
import 'package:jippymart_restaurant/models/referral_model.dart';
import 'package:jippymart_restaurant/models/review_attribute_model.dart';
import 'package:jippymart_restaurant/models/story_model.dart';
import 'package:jippymart_restaurant/models/subscription_history.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/models/wallet_transaction_model.dart';
import 'package:jippymart_restaurant/models/withdraw_method_model.dart';
import 'package:jippymart_restaurant/models/withdrawal_model.dart';
import 'package:jippymart_restaurant/models/zone_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;

final headers = {
  "Accept": "application/json",
  "Content-Type": "application/json",
  "User-Agent": "Flutter-App",
};
class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<String> getCurrentUid() async{
    return await getFirebaseId()??'';
  }
  static Future<bool> isLogin() async {
    bool isLogin = false;
    String? userId = await getFirebaseId();
    print("isLogin $userId ");
    if (userId != null) {
      isLogin = await userExistOrNot(userId);
    } else {
      isLogin = false;
    }
    return isLogin;
  }



  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;
    print("userExistOrNot ${'${Constant.baseUrl}restaurant/exists/$uid'} ");
    await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/exists/$uid')
    ).then((response) {
      print("userExistOrNot ${response.body} ");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        isExist = data['exists'] ?? false;
      } else {
        isExist = false;
        log("Failed to check user exist: ${response.statusCode}");
      }
    }).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });

    return isExist;
  }


  static Future<UserModel?> getUserProfile(String uuid) async {
    try {
      String url = '${Constant.baseUrl}restaurant/users/$uuid';
      print(" getUserProfile $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        log(" getUserProfileresponse body ${response.body}");
        if (responseData['success'] ?? true) {
          final userData = responseData['data'] ?? responseData; // Adjust based on your API structure
          final userModel = UserModel.fromJson(userData);
          Constant.userModel = userModel;
          print(" getUserProfile  ${  Constant.userModel?.toJson()} ");
          return userModel;
        } else {
          log("API returned error: ${responseData['message']}");
          return null;
        }
      } else {
        log("Failed to get user profile: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (error) {
      log("Error getting user profile: $error");
      return null;
    }
  }
  static Future<UserModel?> getUserById(String uuid) async {
    try {
      String url = '${Constant.baseUrl}restaurant/users/$uuid';
      log("getUserById:: $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map<String, dynamic>) {
          return UserModel.fromJson(responseData);
        }
        else if (responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        }
        // Option 3: With success flag
        else if (responseData['success'] == true && responseData['user'] != null) {
          return UserModel.fromJson(responseData['user']);
        }
        // Option 4: With success flag and data field
        else if (responseData['success'] == true && responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        }
        else {
          log("Unexpected API response structure: $responseData");
          return null;
        }
      } else if (response.statusCode == 404) {
        log("User not found with UUID: $uuid");
        return null;
      } else {
        log("Failed to get user by ID. Status: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (error) {
      log("Error getting user by ID: $error");
      return null;
    }
  }
  static Future<bool?> updateUserWallet({
    required String amount,
    required String userId
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/update-user-wallet'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'amount': amount,
        }),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] ?? true; // Adjust based on your API response
      } else {
        print('Failed to update wallet: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Handle network or other errors
      print('Error updating wallet: $e');
      return false;
    }
  }
  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    try {
      String? userId = await getFirebaseId();
      userModel.id = userId;
      print("updateUser  ${ userModel.toJson()}");
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/updateUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userModel.toJson()),
      );
      if (response.statusCode == 200) {
        Constant.userModel = userModel;
        isUpdate = true;
      } else {
        log("Failed to update user: ${response.statusCode} - ${response.body}");
        isUpdate = false;
      }
    } catch (error) {
      log("Failed to update users: $error");
      isUpdate = false;
    }
    return isUpdate;
  }
  // Rate limiting: Track last request time and minimum delay between requests
  static DateTime? _lastUpdateDriverUserRequest;
  static const Duration _minDelayBetweenRequests = Duration(milliseconds: 200); // 200ms delay between requests
  
  static Future<bool> updateDriverUser(UserModel userModel, {int maxRetries = 3}) async {
    // Rate limiting: Ensure minimum delay between requests
    if (_lastUpdateDriverUserRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastUpdateDriverUserRequest!);
      if (timeSinceLastRequest < _minDelayBetweenRequests) {
        final delayNeeded = _minDelayBetweenRequests - timeSinceLastRequest;
        await Future.delayed(delayNeeded);
      }
    }
    
    int attempt = 0;
    while (attempt < maxRetries) {
      try {
        userModel.id = userModel.firebaseId;
        log("updateDriverUser ${'${Constant.baseUrl}restaurant/updateUser'} ");
        log("updateDriverUser ${userModel.firebaseId} ${userModel.id} ");
        Map<String, dynamic> userJson = _convertTimestampsToJson(userModel.toJson());
        log("updateDriverUser ${userJson}");
        _lastUpdateDriverUserRequest = DateTime.now();
        final response = await http.post(
          Uri.parse('${Constant.baseUrl}restaurant/updateUser'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(userJson),
        );
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          return responseData['success'] ?? true; // Adjust based on your API response structure
        } else if (response.statusCode == 429) {
          // Rate limited - retry with exponential backoff
          attempt++;
          if (attempt < maxRetries) {
            final backoffDelay = Duration(milliseconds: 500 * (1 << (attempt - 1))); // Exponential backoff: 500ms, 1s, 2s
            log("Rate limited (429). Retrying in ${backoffDelay.inMilliseconds}ms (attempt $attempt/$maxRetries)");
            await Future.delayed(backoffDelay);
            continue;
          } else {
            log("Failed to update user after $maxRetries attempts: ${response.statusCode} - ${response.body}");
            return false;
          }
        } else {
          log("Failed to update user: ${response.statusCode} - ${response.body}");
          return false;
        }
      } catch (error) {
        attempt++;
        if (attempt < maxRetries) {
          final backoffDelay = Duration(milliseconds: 500 * (1 << (attempt - 1)));
          log("Error updating user. Retrying in ${backoffDelay.inMilliseconds}ms (attempt $attempt/$maxRetries): $error");
          await Future.delayed(backoffDelay);
          continue;
        } else {
          log("Failed to update userds after $maxRetries attempts: $error");
          return false;
        }
      }
    }
    return false;
  }
  static Future<bool> withdrawWalletAmount(WithdrawalModel userModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/withdraw'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: userModel.toJson(),
      );
      if (response.statusCode == 200) {
        // Optionally parse the response if needed
        // final responseData = json.decode(response.body);
        return true;
      } else {
        log("Failed to withdraw: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      log("Error during withdrawal: $error");
      return false;
    }
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}onboarding/restaurantApp'),
        headers: headers
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<OnBoardingModel> onBoardingModel = [];
          for (var element in responseData['data']) {
            OnBoardingModel documentModel = OnBoardingModel.fromJson(element);
            onBoardingModel.add(documentModel);
          }
          return onBoardingModel;
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load onboarding data: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      rethrow; // or return an empty list: return [];
    }
  }

  static Future<bool?> setWalletTransaction(
      WalletTransactionModel walletTransactionModel) async {
    try {
      // Convert Timestamps to JSON-serializable format before encoding
      Map<String, dynamic> transactionJson = _convertTimestampsToJson(walletTransactionModel.toJson());
      
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/transaction'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(transactionJson),
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final bool success = responseData['success'] ?? false;
        final String message = responseData['message'] ?? '';
        if (success) {
          log("Wallet transaction saved successfully: $message");
          return true;
        } else {
          log("Failed to save wallet transaction: $message");
          return false;
        }
      } else {
        log("HTTP Error: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      log("Error adding wallet transaction: $error");
      return false;
    }
  }

  getSettings() async {
    try {
      final response = await http.get(Uri.parse('${Constant.baseUrl}settings/mobile'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body)['data'];
        final Map<String, dynamic> documents = data['documents'];
        final Map<String, dynamic> derived = data['derived'];
        // Global Settings
        final globalSettings = documents['globalSettings'] ?? {};
        Constant.orderRingtoneUrl = globalSettings['order_ringtone_url'] ?? '';
        Preferences.setString(Preferences.orderRingtone, Constant.orderRingtoneUrl);
        if (globalSettings['app_restaurant_color'] != null) {
          AppThemeData.secondary300 = Color(int.parse(
              globalSettings['app_restaurant_color'].replaceFirst("#", "0xff")));
        }
        Constant.isEnableAdsFeature = globalSettings['isEnableAdsFeature'] ?? false;
        Constant.isSelfDeliveryFeature = globalSettings['isSelfDelivery'] ?? false;

        if (Constant.orderRingtoneUrl.isNotEmpty) {
          await AudioPlayerService.initAudio();
        }

        // Schedule Order Notification
        final scheduleOrder = documents['scheduleOrderNotification'] ?? {};
        if (scheduleOrder.isNotEmpty) {
          Constant.scheduleOrderTime = scheduleOrder["notifyTime"];
          Constant.scheduleOrderTimeType = scheduleOrder["timeUnit"];
        }

        // Dine-in Settings
        final dineInSettings = documents['DineinForRestaurant'] ?? {};
        if (dineInSettings.isNotEmpty) {
          Constant.isDineInEnable = dineInSettings["isEnabled"];
        }

        // Restaurant Settings
        final restaurantSettings = documents['restaurant'] ?? {};
        Constant.autoApproveRestaurant = restaurantSettings['auto_approve_restaurant'] ?? false;
        Constant.isSubscriptionModelApplied = restaurantSettings['subscription_model'] ?? false;

        // Admin Commission
        final adminCommission = documents['AdminCommission'] ?? {};
        if (adminCommission.isNotEmpty) {
          Constant.adminCommission = AdminCommission.fromJson(adminCommission);
        }

        // Google Map Key
        final googleMapSettings = documents['googleMapKey'] ?? {};
        Constant.mapAPIKey = googleMapSettings["key"] ?? '';
        Constant.placeHolderImage = googleMapSettings["placeHolderImage"] ?? '';

        // Story Settings
        final storySettings = documents['story'] ?? {};
        Constant.storyEnable = storySettings['isEnabled'] ?? false;

        // Placeholder Image
        final placeholderSettings = documents['placeHolderImage'] ?? {};
        Constant.placeholderImage = placeholderSettings['image'] ?? '';

        // Version Settings
        final versionSettings = documents['Version'] ?? {};
        Constant.googlePlayLink = versionSettings["googlePlayLink"] ?? '';
        Constant.appStoreLink = versionSettings["appStoreLink"] ?? '';
        Constant.appVersion = versionSettings["app_version"] ?? '';
        Constant.storeUrl = versionSettings["storeUrl"] ?? '';

        // Restaurant Nearby
        final restaurantNearby = documents['RestaurantNearBy'] ?? {};
        if (restaurantNearby.isNotEmpty) {
          Constant.distanceType = restaurantNearby["distanceType"];
        }

        // Special Discount Offer
        final specialDiscount = documents['specialDiscountOffer'] ?? {};
        if (specialDiscount.isNotEmpty) {
          Constant.specialDiscountOfferEnable = specialDiscount["isEnable"];
        }

        // Email Settings
        final emailSettings = documents['emailSetting'] ?? {};
        if (emailSettings.isNotEmpty) {
          Constant.mailSettings = MailSettings.fromJson(emailSettings);
        }

        // Contact Us
        final contactSettings = documents['ContactUs'] ?? {};
        if (contactSettings.isNotEmpty) {
          Constant.adminEmail = contactSettings["Email"];
        }

        // Driver Nearby
        final driverNearby = documents['DriverNearBy'] ?? {};
        if (driverNearby.isNotEmpty) {
          Constant.selectedMapType = driverNearby["selectedMapType"];
          Constant.singleOrderReceive = driverNearby['singleOrderReceive'];
        }

        // Notification Settings
        final notificationSettings = documents['notification_setting'] ?? {};
        Constant.senderId = notificationSettings["projectId"];
        Constant.jsonNotificationFileURL = notificationSettings["serviceJson"];

        // Document Verification
        final docVerification = documents['document_verification_settings'] ?? {};
        Constant.isRestaurantVerification = docVerification['isRestaurantVerification'] ?? false;

        // Privacy Policy
        final privacyPolicy = documents['privacyPolicy'] ?? {};
        if (privacyPolicy.isNotEmpty) {
          Constant.privacyPolicy = privacyPolicy["privacy_policy"];
        }

        // Terms and Conditions
        final termsConditions = documents['termsAndConditions'] ?? {};
        if (termsConditions.isNotEmpty) {
          Constant.termsAndConditions = termsConditions["termsAndConditions"];
        }

        // Also set derived values for consistency
        Constant.isSubscriptionModelApplied = derived['isSubscriptionModelApplied'] ?? false;
        Constant.autoApproveRestaurant = derived['autoApproveRestaurant'] ?? false;
        Constant.isEnableAdsFeature = derived['isEnableAdsFeature'] ?? false;
        Constant.isSelfDeliveryFeature = derived['isSelfDeliveryFeature'] ?? false;
        Constant.mapAPIKey = derived['mapAPIKey'] ?? Constant.mapAPIKey;
        Constant.placeHolderImage = derived['placeHolderImage'] ?? Constant.placeHolderImage;
        Constant.senderId = derived['senderId'] ?? Constant.senderId;
        Constant.jsonNotificationFileURL = derived['jsonNotificationFileURL'] ?? Constant.jsonNotificationFileURL;
        Constant.privacyPolicy = derived['privacyPolicy'] ?? Constant.privacyPolicy;
        Constant.termsAndConditions = derived['termsAndConditions'] ?? Constant.termsAndConditions;
        Constant.googlePlayLink = derived['googlePlayLink'] ?? Constant.googlePlayLink;
        Constant.appStoreLink = derived['appStoreLink'] ?? Constant.appStoreLink;
        Constant.appVersion = derived['appVersion'] ?? Constant.appVersion;
        Constant.storyEnable = derived['storyEnable'] ?? Constant.storyEnable;
        Constant.placeholderImage = derived['placeholderImage'] ?? Constant.placeholderImage;
        Constant.specialDiscountOfferEnable = derived['specialDiscountOffer'] ?? Constant.specialDiscountOfferEnable;

      } else {
        throw Exception('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    }
  }
  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExist;
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/referral/check-code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'referralCode': referralCode,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          isExist = responseData['data'] ?? false;
        } else {
          isExist = false;
        }
      } else {
        // Handle non-200 status codes
        print('API Error: ${response.statusCode}');
        isExist = false;
      }
    } catch (e, s) {
      print('checkReferralCodeValidOrNot $e $s');
      return false;
    }
    return isExist;
  }
  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/referral/get-by-code'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'referralCode': referralCode,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          return ReferralModel.fromJson(responseData['data']);
        } else {
          log('API returned unsuccessful response: ${response.body}');
          return null;
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e, s) {
      log('getReferralUserByCode error: $e $s');
      return null;
    }
  }

  static Future<OrderModel?> getOrderByOrderId(String orderId) async {
    OrderModel? orderModel;
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          orderModel = OrderModel.fromJson(jsonResponse['data']);
        }
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e, s) {
      log('getOrderByOrderId API call failed: $e $s');
      return null;
    }
    return orderModel;
  }

  static Future<String?> referralAdd(ReferralModel referralModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/referral/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(referralModel.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          log('Referral added successfully: ${responseData['message']}');
          return null; // Success
        } else {
          log('Failed to add referral: ${responseData['message']}');
          return responseData['message'] ?? 'Failed to add referral';
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        return 'HTTP Error: ${response.statusCode}';
      }
    } catch (e, s) {
      log('referralAdd error: $e $s');
      return e.toString();
    }
  }

  static Future<List<ZoneModel>?> getZone() async {
    List<ZoneModel> zoneList = [];
    try {


      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/zones'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> zonesData = responseData['data'];
          for (var element in zonesData) {
            // Filter zones where publish == 1 (equivalent to true)
            if (element['publish'] == 1) {
              ZoneModel zoneModel = ZoneModel.fromJson(element);
              zoneList.add(zoneModel);
            }
          }
        }
      } else {
        throw Exception('Failed to load zones: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString(),name: " getZone ");
      return null;
    }
    return zoneList;
  }

  static Future<List<OrderModel>?> getAllOrder() async {
    List<OrderModel> orderList = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/orders?vendorID=${Constant.userModel!.vendorID}'),
        headers: {
          'Content-Type': 'application/json',
          // Add any required authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          for (var element in data) {
            OrderModel orderModel = OrderModel.fromJson(element);
            orderList.add(orderModel);
          }
          orderList.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1; // Put a after b
            if (b.createdAt == null) return -1; // Put a before b
            return b.createdAt!.compareTo(a.createdAt!);
          });
        } else {
          log('API returned success: false');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      log(e.toString());
    }
    return orderList;
  }
  static Future<bool> updateOrder(OrderModel orderModel) async {
    bool isUpdate = false;
    try {
      log(" updateOrder ${orderModel.toJson()} ");
      // Convert the entire model to JSON and handle any remaining Timestamps
      Map<String, dynamic> orderJson = _convertTimestampsToJson(orderModel.toJson());

      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/orders/${orderModel.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderJson),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        isUpdate = true;
      } else {
        print("Failed to update order: ${response.statusCode} - ${response.body}");
        isUpdate = false;
      }
    } catch (error) {
      print("Failed to update order: $error");
      isUpdate = false;
    }
    return isUpdate;
  }

// Recursive method to convert any Timestamp objects to strings
  static dynamic _convertTimestampsToJson(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is Map<String, dynamic>) {
      return value.map((key, value) => MapEntry(key, _convertTimestampsToJson(value)));
    } else if (value is List) {
      return value.map((e) => _convertTimestampsToJson(e)).toList();
    }
    return value;
  }
  // static Future<bool> updateOrder(OrderModel orderModel) async {
  //   bool isUpdate = false;
  //   // try {
  //     log(" updateOrder ${orderModel.toJson()} ");
  //     final response = await http.post(
  //       Uri.parse('${Constant.baseUrl}restaurant/orders/${orderModel.id}'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(orderModel.toJson()),
  //     );
  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       isUpdate = true;
  //     } else {
  //       print("Failed to update order: ${response.statusCode} - ${response.body}");
  //       isUpdate = false;
  //     }
  //   // } catch (error) {
  //   //   print("Failed to update order: $error");
  //     isUpdate = false;
  //   // }
  //   return isUpdate;
  // }

  static Future restaurantVendorWalletSet(OrderModel orderModel) async {
    double subTotal = 0.0;
    double specialDiscount = 0.0;
    double taxAmount = 0.0;
    // double adminCommission = 0.0;

    for (var element in orderModel.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal = subTotal +
            double.parse(element.price.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      } else {
        subTotal = subTotal +
            double.parse(element.discountPrice.toString()) *
                double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) *
                double.parse(element.quantity.toString()));
      }
    }

    if (orderModel.specialDiscount != null &&
        orderModel.specialDiscount!['special_discount'] != null) {
      specialDiscount = double.parse(
          orderModel.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.taxSetting != null) {
      for (var element in orderModel.taxSetting!) {
        taxAmount = taxAmount +
            Constant.calculateTax(
                amount: (subTotal -
                        double.parse(orderModel.discount.toString()) -
                        specialDiscount)
                    .toString(),
                taxModel: element);
      }
    }

    double basePrice = 0;
    // var totalamount = (subTotal + taxAmount) - double.parse(orderModel.discount.toString()) - specialDiscount;
    if (Constant.adminCommission!.isEnabled == true) {
      basePrice =
          (subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100))) -
              double.parse(orderModel.discount.toString()) -
              specialDiscount;
    } else {
      basePrice = subTotal -
          double.parse(orderModel.discount.toString()) -
          specialDiscount;
    }
    // if (Constant.isAdminCommissionModelApplied == true) {
    //   if (orderModel.adminCommissionType == 'Percent') {
    //     adminCommission = (subTotal - double.parse(orderModel.discount.toString()) - specialDiscount) * double.parse(orderModel.adminCommission!) / 100;
    //   } else {
    //     adminCommission = double.parse(orderModel.adminCommission!);
    //   }
    // }
    WalletTransactionModel historyModel = WalletTransactionModel(
        amount: basePrice,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.vendor!.author,
        date: Timestamp.now(),
        isTopup: true,
        note: "Order Amount credited",
        paymentMethod: "Wallet",
        paymentStatus: "success",
        transactionUser: "vendor");
    addWalletTransaction(historyModel);

    WalletTransactionModel taxModel = WalletTransactionModel(
        amount: taxAmount,
        id: const Uuid().v4(),
        orderId: orderModel.id,
        userId: orderModel.vendor!.author,
        date: Timestamp.now(),
        isTopup: true,
        note: "Order Tax credited",
        paymentMethod: "tax",
        paymentStatus: "success",
        transactionUser: "vendor");
    // addWalletTransaction(historyModel);

    addWalletTransaction(taxModel);

    await updateUserWallet(
        amount: (basePrice + taxAmount).toString(),
        userId: orderModel.vendor!.author.toString());
  }

  static Future<bool> addWalletTransaction(WalletTransactionModel historyModel) async {
    try {
      // Convert Timestamps to JSON-serializable format before encoding
      Map<String, dynamic> transactionJson = _convertTimestampsToJson(historyModel.toJson());
      
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/transaction'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(transactionJson),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Wallet transaction added successfully");
        return true;
      } else {
        log("Failed to add wallet transaction: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      log("Error adding wallet transaction: $error");
      return false;
    }
  }
  static Future<RatingModel?> getOrderReviewsByID(
      String orderId, String productID) async {
    RatingModel? ratingModel;

    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/reviews/order?orderId=$orderId&productID=$productID'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          ratingModel = RatingModel.fromJson(jsonResponse['data']);
          print("======> Review found");
        } else {
          print("======> No review found");
          ratingModel = null;
        }
      } else {
        print("Failed to fetch review: ${response.statusCode} - ${response.body}");
        ratingModel = null;
      }
    } catch (error) {
      print("Error fetching review: $error");
      ratingModel = null;
    }

    return ratingModel;
  }
  static Future<List<ProductModel>?> getProduct() async {
    List<ProductModel> productList = [];
    try {
      String url = '${Constant.baseUrl}restaurant/products?vendorID=${Constant.userModel!.vendorID}';
      print("getProduct $url ");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> productsData = jsonResponse['data'];
          print("======>");
          print(productsData.length);

          for (int i = 0; i < productsData.length; i++) {
            try {
              final productData = productsData[i];
              print("Processing product $i: ${productData['name']}");
              ProductModel productModel = ProductModel.fromJson(productData);
              productList.add(productModel);
            } catch (e, stackTrace) {
              print("Error processing product $i: $e");
              print("Stack trace: $stackTrace");
              print("Problematic product data: ${productsData[i]}");
              // Continue with next product instead of failing completely
              continue;
            }
          }
        } else {
          print("No products found or API returned error");
        }
      } else {
        print("Failed to fetch products: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (error) {
      print("Error fetching products: $error");
      return null;
    }
    return productList;
  }

  static Future<List<AdvertisementModel>?> getAdvertisement() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}advertisements?vendorId=${Constant.userModel!.vendorID}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          List<AdvertisementModel> advertisementList = [];

          for (var element in responseData['data']) {
            AdvertisementModel advertisementModel = AdvertisementModel.fromJson(element);
            advertisementList.add(advertisementModel);
          }
          advertisementList.sort((a, b) {
            if (a.createdAt == null || b.createdAt == null) return 0;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return advertisementList;
        } else {
          log('API returned success: false');
          return null;
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }

  static Future<AdvertisementModel> getAdvertisementById({
    required String advertisementId,
  }) async {
    AdvertisementModel advertisementdata = AdvertisementModel();

    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}advertisements/$advertisementId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          AdvertisementModel advertisementModel =
          AdvertisementModel.fromJson(responseData['data']);
          advertisementdata = advertisementModel;
        } else {
          log('API returned success: false for advertisement ID: $advertisementId');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      log(error.toString());
    }

    return advertisementdata;
  }

  static Future<bool> updateProduct(ProductModel productModel) async {
    bool isUpdate = false;
    try {
      log("updateProduct ${productModel.toJson()} ");
      print("updateProduct url  ${productModel.id} ");
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/products'
            // '/${productModel.id}'
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(productModel.toJson()),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        isUpdate = true;
      } else {
        print("Failed to update product: ${response.statusCode} - ${response.body}");
        isUpdate = false;
      }
    } catch (error) {
      print("Failed to update productss: $error");
      isUpdate = false;
    }
    return isUpdate;
  }


  static Future<bool> deleteProduct(ProductModel productModel) async {
    bool isDeleted = false;

    try {
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}restaurant/products/${productModel.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        isDeleted = true;
      } else {
        print("Failed to delete product: ${response.statusCode} - ${response.body}");
        isDeleted = false;
      }
    } catch (error) {
      print("Failed to delete product: $error");
      isDeleted = false;
    }

    return isDeleted;
  }
  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionList = [];

    try {
      final String userId = await FireStoreUtils.getCurrentUid(); // Get current user ID

      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/transactions?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          // Parse the list of transactions from the response
          List<dynamic> transactions = responseData['data'];

          for (var transactionData in transactions) {
            try {
              WalletTransactionModel walletTransactionModel =
              WalletTransactionModel.fromJson(transactionData);
              walletTransactionList.add(walletTransactionModel);
            } catch (e) {
              log('Error parsing transaction: $e');
            }
          }

          // Sort by date in descending order (most recent first)
          walletTransactionList.sort((a, b) {
            // Handle different date types - API returns String, Firebase uses Timestamp
            DateTime? dateA = _parseDate(a.date);
            DateTime? dateB = _parseDate(b.date);

            // Handle null cases
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1; // Put null dates at the end
            if (dateB == null) return -1; // Put null dates at the end

            return dateB.compareTo(dateA); // Descending order
          });
        }
      } else {
        throw Exception('Failed to load wallet transactions: ${response.statusCode}');
      }
    } catch (error) {
      log('getWalletTransaction error: $error');
      return null;
    }

    return walletTransactionList;
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;

    if (date is String) {
      // Remove extra quotes if they exist
      String dateString = date.replaceAll('"', '');
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        log('Error parsing date string: $dateString');
        return null;
      }
    } else if (date is Timestamp) {
      return date.toDate();
    } else if (date is DateTime) {
      return date;
    }

    return null;
  }

  static Future<List<WalletTransactionModel>?> getFilterWalletTransaction(
      Timestamp startTime, Timestamp endTime) async {
    try {
      String startTimeIso = startTime.toDate().toUtc().toIso8601String();
      String endTimeIso = endTime.toDate().toUtc().toIso8601String();
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/transactions/filtered'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': FireStoreUtils.getCurrentUid(),
          'startTime': startTimeIso,
          'endTime': endTimeIso,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          List<WalletTransactionModel> walletTransactionList = [];

          // Parse the data array from response
          final List<dynamic> transactions = responseData['data'];

          for (var transactionData in transactions) {
            try {
              WalletTransactionModel walletTransactionModel =
              WalletTransactionModel.fromJson(transactionData);
              walletTransactionList.add(walletTransactionModel);
            } catch (e) {
              log("Error parsing transaction: $e");
            }
          }

          walletTransactionList.sort((a, b) {
            final aDate = a.date;
            final bDate = b.date;

            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1; // Put null dates at the end
            if (bDate == null) return -1; // Put null dates at the end

            return bDate.compareTo(aDate); // Descending order
          });

          return walletTransactionList;
        } else {
          log("API returned error: ${responseData['message']}");
          return null;
        }
      } else {
        log("Failed to get wallet transactions: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (error) {
      log("Error getting wallet transactions: $error");
      return null;
    }
  }
  static Future<List<WithdrawalModel>?> getWithdrawHistory() async {
    List<WithdrawalModel> walletTransactionList = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/withdraw-history?vendorID=${Constant.userModel!.vendorID.toString()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          for (var element in data) {
            WithdrawalModel walletTransactionModel = WithdrawalModel.fromJson(element);
            walletTransactionList.add(walletTransactionModel);
          }
          walletTransactionList.sort((a, b) {
            if (a.paidDate == null && b.paidDate == null) return 0;
            if (a.paidDate == null) return 1; // put a after b
            if (b.paidDate == null) return -1; // put a before b
            return b.paidDate!.compareTo(a.paidDate!);
          });
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load withdrawal history: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }

    return walletTransactionList;
  }

  static Future getPaymentSettingsData() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}settings/payment'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final Map<String, dynamic> paymentData = responseData['data'];
          if (paymentData['payFastSettings'] != null) {
            PayFastModel payFastModel = PayFastModel.fromJson(paymentData['payFastSettings']);
            await Preferences.setString(
                Preferences.payFastSettings,
                jsonEncode(payFastModel.toJson())
            );
          }

          if (paymentData['MercadoPago'] != null) {
            MercadoPagoModel mercadoPagoModel = MercadoPagoModel.fromJson(paymentData['MercadoPago']);
            await Preferences.setString(
                Preferences.mercadoPago,
                jsonEncode(mercadoPagoModel.toJson())
            );
          }

          if (paymentData['paypalSettings'] != null) {
            PayPalModel payPalModel = PayPalModel.fromJson(paymentData['paypalSettings']);
            await Preferences.setString(
                Preferences.paypalSettings,
                jsonEncode(payPalModel.toJson())
            );
          }

          if (paymentData['stripeSettings'] != null) {
            StripeModel stripeModel = StripeModel.fromJson(paymentData['stripeSettings']);
            await Preferences.setString(
                Preferences.stripeSettings,
                jsonEncode(stripeModel.toJson())
            );
          }

          if (paymentData['flutterWave'] != null) {
            FlutterWaveModel flutterWaveModel = FlutterWaveModel.fromJson(paymentData['flutterWave']);
            await Preferences.setString(
                Preferences.flutterWave,
                jsonEncode(flutterWaveModel.toJson())
            );
          }

          if (paymentData['payStack'] != null) {
            PayStackModel payStackModel = PayStackModel.fromJson(paymentData['payStack']);
            await Preferences.setString(
                Preferences.payStack,
                jsonEncode(payStackModel.toJson())
            );
          }

          if (paymentData['PaytmSettings'] != null) {
            PaytmModel paytmModel = PaytmModel.fromJson(paymentData['PaytmSettings']);
            await Preferences.setString(
                Preferences.paytmSettings,
                jsonEncode(paytmModel.toJson())
            );
          }

          if (paymentData['walletSettings'] != null) {
            WalletSettingModel walletSettingModel = WalletSettingModel.fromJson(paymentData['walletSettings']);
            await Preferences.setString(
                Preferences.walletSettings,
                jsonEncode(walletSettingModel.toJson())
            );
          }

          if (paymentData['razorpaySettings'] != null) {
            RazorPayModel razorPayModel = RazorPayModel.fromJson(paymentData['razorpaySettings']);
            await Preferences.setString(
                Preferences.razorpaySettings,
                jsonEncode(razorPayModel.toJson())
            );
          }

          if (paymentData['CODSettings'] != null) {
            CodSettingModel codSettingModel = CodSettingModel.fromJson(paymentData['CODSettings']);
            await Preferences.setString(
                Preferences.codSettings,
                jsonEncode(codSettingModel.toJson())
            );
          }

          if (paymentData['midtrans_settings'] != null) {
            MidTrans midTrans = MidTrans.fromJson(paymentData['midtrans_settings']);
            await Preferences.setString(
                Preferences.midTransSettings,
                jsonEncode(midTrans.toJson())
            );
          }

          if (paymentData['orange_money_settings'] != null) {
            OrangeMoney orangeMoney = OrangeMoney.fromJson(paymentData['orange_money_settings']);
            await Preferences.setString(
                Preferences.orangeMoneySettings,
                jsonEncode(orangeMoney.toJson())
            );
          }

          if (paymentData['xendit_settings'] != null) {
            Xendit xendit = Xendit.fromJson(paymentData['xendit_settings']);
            await Preferences.setString(
                Preferences.xenditSettings,
                jsonEncode(xendit.toJson())
            );
          }
        } else {
          throw Exception('API returned unsuccessful response');
        }
      } else {
        throw Exception('Failed to load payment settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment settings: $e');
      rethrow;
    }
  }
  static Future<VendorModel?> getVendorById(String vendorId) async {
    VendorModel? vendorModel;
    try {
      print("getVendorById  ");
      if (vendorId.isNotEmpty) {
        final response = await http.get(
          Uri.parse('${Constant.baseUrl}restaurant/vendors/$vendorId'),
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          print("getVendorById  ${response.body}");
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData['success'] == true && responseData['data'] != null) {
            vendorModel = VendorModel.fromJson(responseData['data']);
            print("getVendorById  ${response.body}");
          }
        } else if (response.statusCode == 404) {
          return null;
        } else {
          throw Exception('Failed to load vendor: ${response.statusCode}');
        }
      }
    } catch (e, s) {
      log('getVendorById error: $e $s');
      return null;
    }
    return vendorModel;
  }

  static Future<List<VendorCategoryModel>?> getVendorCategoryById() async {
    try {
      print("getVendorCategoryById ");
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/vendor-categories'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          // Handle the case where data is a List
          if (jsonResponse['data'] is List) {
            List<VendorCategoryModel> categories = (jsonResponse['data'] as List)
                .map((categoryJson) => VendorCategoryModel.fromJson(categoryJson))
                .toList();
            return categories;
          }
          else if (jsonResponse['data'] is Map) {
            VendorCategoryModel categoryModel = VendorCategoryModel.fromJson(jsonResponse['data']);
            return [categoryModel];
          } else {
            throw Exception('Invalid data format in API response');
          }
        } else {
          throw Exception('API returned unsuccessful response: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vendor categories getVendorCategoryById: $e');
      return null;
    }
  }


  static Future<ProductModel?> getProductById(String productId) async {
    ProductModel? productModel;

    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          productModel = ProductModel.fromJson(jsonResponse['data']);
        } else {
          print("Product not found or API returned error");
        }
      } else {
        print("Failed to fetch product: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e, s) {
      print('getProductById error: $e $s');
      return null;
    }

    return productModel;
  }
  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/vendor-categories/$categoryId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          vendorCategoryModel = VendorCategoryModel.fromJson(responseData['data']);
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load vendor category: ${response.statusCode}');
      }
    } catch (e, s) {
      log('getVendorCategoryByCategoryId error: $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(String attributeId) async {
    ReviewAttributeModel? vendorCategoryModel;
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/review-attributes/$attributeId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          vendorCategoryModel = ReviewAttributeModel.fromJson(responseData['data']);
        }
      } else {
        throw Exception('Failed to load review attribute: ${response.statusCode}');
      }
    } catch (e, s) {
      log('getVendorReviewAttribute error: $e $s');
      return null;
    }
    return vendorCategoryModel;
  }
  static Future<List<AttributesModel>?> getAttributes() async {
    List<AttributesModel> attributeList = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/attributes'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> attributesData = responseData['data'];

          for (var element in attributesData) {
            AttributesModel attributeModel = AttributesModel.fromJson(element);
            attributeList.add(attributeModel);
          }
        }
      } else {
        throw Exception('Failed to load attributes: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
    return attributeList;
  }

  static Future<DeliveryCharge?> getDeliveryCharge() async {
    DeliveryCharge? deliveryCharge;
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/delivery-charge'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          deliveryCharge = DeliveryCharge.fromJson(responseData['data']);
        }
      } else {
        throw Exception('Failed to load delivery charge: ${response.statusCode}');
      }
    } catch (e, s) {
      log('getDeliveryCharge error: $e $s');
      return null;
    }
    return deliveryCharge;
  }



  static Future<List<CouponModel>> getAllVendorCoupons(String vendorId) async {
    List<CouponModel> coupon = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}coupons/vendor/$vendorId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> couponsData = responseData['data'];
          for (var element in couponsData) {
            if (_isCouponValid(element)) {
              CouponModel couponModel = CouponModel.fromJson(element);
              coupon.add(couponModel);
            }
          }
        }
      } else {
        throw Exception('Failed to load vendor coupons: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
    }
    return coupon;
  }

// Helper method to check if coupon meets all criteria
  static bool _isCouponValid(Map<String, dynamic> couponData) {
    // Check if coupon is enabled
    if (couponData['isEnabled'] != true && couponData['isEnabled'] != 1) {
      return false;
    }

    // Check if coupon is public
    if (couponData['isPublic'] != true && couponData['isPublic'] != 1) {
      return false;
    }

    // Check expiration date
    if (couponData['expiresAt'] != null) {
      DateTime expiresAt;

      // Handle different timestamp formats
      if (couponData['expiresAt'] is String) {
        expiresAt = DateTime.parse(couponData['expiresAt']);
      } else if (couponData['expiresAt'] is Map) {
        // Handle Firebase timestamp format if needed
        final timestamp = couponData['expiresAt'];
        if (timestamp['_seconds'] != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
        } else {
          return false;
        }
      } else {
        return false;
      }

      // Check if coupon hasn't expired
      if (expiresAt.isBefore(DateTime.now())) {
        return false;
      }
    } else {
      return false; // No expiration date provided
    }
    return true;
  }
  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderModel.toJson()),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        isAdded = true;
      } else {
        print("Failed to create order: ${response.statusCode} - ${response.body}");
        isAdded = false;
      }
    } catch (error) {
      print("Failed to create order: $error");
      isAdded = false;
    }

    return isAdded;
  }


  static Future<bool?> setCoupon(CouponModel orderModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}coupons'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: orderModel.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        log("Failed to add coupon: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (error) {
      log("Failed to add coupon: $error");
      return false;
    }
  }
  static Future<bool?> deleteCoupon(CouponModel couponModel) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}coupons/${couponModel.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return true;
        } else {
          print('API returned unsuccessful response: ${jsonResponse['message']}');
          return false;
        }
      } else if (response.statusCode == 404) {
        print('Coupon not found (404)');
        return false;
      } else {
        print('Failed to delete coupon: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting coupon: $e');
      return false;
    }
  }

  static Future<List<CouponModel>> getOffer(String vendorId) async {
    List<CouponModel> list = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}offers/vendor/$vendorId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> offersData = responseData['data'];
          for (var element in offersData) {
            CouponModel couponModel = CouponModel.fromJson(element);
            list.add(couponModel);
          }
        }
      } else {
        throw Exception('Failed to load vendor offers: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
    }
    return list;
  }

  static Future<List<DocumentModel>> getDocumentList() async {
    List<DocumentModel> documentList = [];
    try {
      String url = '${Constant.baseUrl}documents';
      print(" getDocumentList  $url");
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      print(" getDocumentList  ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> documentsData = responseData['data'];
          for (var element in documentsData) {
            if (element['type'] == "restaurant" && element['enable'] == 1) {
              DocumentModel documentModel = DocumentModel.fromJson(element);
              documentList.add(documentModel);
            }
          }
        }
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
    }
    return documentList;
  }

  static Future<DriverDocumentModel?> getDocumentOfDriver() async {
    try {
      String? userId = await getFirebaseId();
   String url =    '${Constant.baseUrl}documents/driver';
      print("getDocumentOfDriver userId: $userId  $url");
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "userId": userId,
        }),
      );
      print("API Status Code: ${response.statusCode}");
      print("API Response: ${response.body}");
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return DriverDocumentModel.fromJson(jsonResponse['data']);
        } else if (jsonResponse['success'] == true && jsonResponse['data'] == null) {
          print('No document found for driver');
          return null;
        } else {
          throw Exception('API unsuccessful: ${jsonResponse['message']}');
        }
      } else if (response.statusCode == 404) {
        print('Driver document not found (404)');
        return null;
      } else {
        throw Exception('Failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching driver document: $e');
      return null;
    }
  }


  static Future<InboxModel> addRestaurantInbox(InboxModel inboxModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-restaurant/inbox'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(inboxModel.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return inboxModel;
      } else {
        throw Exception('Failed to add restaurant inbox: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add restaurant inbox: $e');
    }
  }


  static Future<InboxModel> addAdminInbox(InboxModel inboxModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-admin/inbox'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(inboxModel.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return inboxModel;
      } else {
        throw Exception('Failed to add admin inbox: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add admin inbox: $e');
    }
  }


  static Future<ConversationModel> addRestaurantChat(ConversationModel conversationModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-restaurant/thread'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: conversationModel.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return conversationModel;
      } else {
        throw Exception('Failed to add chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add chat: $e');
    }
  }

  static Future<ConversationModel> addAdminChat(ConversationModel conversationModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}chat-admin/thread'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(conversationModel.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return conversationModel;
      } else {
        throw Exception('Failed to add admin chat: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add admin chat: $e');
    }
  }
  static Future<bool> uploadDriverDocument(Documents documents) async {
    String userId = await FireStoreUtils.getCurrentUid();
    bool isAdded = false;

    print("------------ Document Upload Debug Log ------------");
    print("User ID      : $userId");
    print("documentId   : ${documents.documentId}");
    print("status       : ${documents.status}");
    print("type         : restaurant");
    print("frontImage   : ${documents.frontImage}");
    print("backImage    : ${documents.backImage}");
    print("--------------------------------------------------");

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constant.baseUrl}documents/driver/upload'),
      );
      // === IMPORTANT: Use backend-expected field names ===
      request.fields['user_id'] = userId;
      request.fields['documentId'] = documents.documentId ?? '';
      request.fields['status'] = documents.status ?? '';
      request.fields['type'] = 'restaurant';
      // === FRONT IMAGE FILE ===
      if (documents.frontImage != null &&
          documents.frontImage!.isNotEmpty &&
          !documents.frontImage!.startsWith('http')) {
        final file = File(documents.frontImage!);
        print("Front exists: ${file.existsSync()} / Size: ${file.lengthSync()}");
        if (file.existsSync() && file.lengthSync() > 0) {
          request.files.add(await http.MultipartFile.fromPath(
            'front_image',   // <-- CHANGE TO MATCH LARAVEL
            documents.frontImage!,
          ));
        }
      }

      // === BACK IMAGE FILE ===
      if (documents.backImage != null &&
          documents.backImage!.isNotEmpty &&
          !documents.backImage!.startsWith('http')) {
        final file = File(documents.backImage!);
        print("Back exists: ${file.existsSync()} / Size: ${file.lengthSync()}");
        if (file.existsSync() && file.lengthSync() > 0) {
          request.files.add(await http.MultipartFile.fromPath(
            'back_image',    // <-- CHANGE TO MATCH LARAVEL
            documents.backImage!,
          ));
        }
      }
      // SEND REQUEST
      var response = await request.send();
      print("📤 uploadDriverDocument Status: ${response.statusCode}");

      // READ RESPONSE BODY
      final respStr = await response.stream.bytesToString();
      print("📥 Response Body: $respStr");

      isAdded = response.statusCode == 200;
    } catch (e) {
      print("❌ Error uploading document: $e");
    }

    return isAdded;
  }


  // static Future<bool> uploadDriverDocument(Documents documents) async {
  //   String userId = await FireStoreUtils.getCurrentUid(); // FIXED
  //   bool isAdded = false;
  //
  //   print("------------ Document Upload Debug Log ------------");
  //   print("User ID      : $userId");
  //   print("documentId   : ${documents.documentId}");
  //   print("status       : ${documents.status}");
  //   print("type         : restaurant");
  //   print("frontImage   : ${documents.frontImage}");
  //   print("backImage    : ${documents.backImage}");
  //   print("--------------------------------------------------");
  //
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${Constant.baseUrl}documents/driver/upload'),
  //     );
  //
  //     request.fields['userId'] = userId;
  //     request.fields['documentId'] = documents.documentId ?? '';
  //     request.fields['status'] = documents.status ?? '';
  //     request.fields['type'] = 'restaurant';
  //
  //     // ⛔ Prevent URL upload — Only upload Local Files
  //     if (documents.frontImage != null && documents.frontImage!.isNotEmpty) {
  //       if (documents.frontImage!.startsWith("http")) {
  //         print("⚠ frontImage is URL → Skipping upload");
  //       } else {
  //         request.files.add(await http.MultipartFile.fromPath(
  //           'frontImage',
  //           documents.frontImage!,
  //         ));
  //       }
  //     }
  //
  //     if (documents.backImage != null && documents.backImage!.isNotEmpty) {
  //       if (documents.backImage!.startsWith("http")) {
  //         print("⚠ backImage is URL → Skipping upload");
  //       } else {
  //         request.files.add(await http.MultipartFile.fromPath(
  //           'backImage',
  //           documents.backImage!,
  //         ));
  //       }
  //     }
  //
  //     var response = await request.send();
  //     print("📤 uploadDriverDocument Status: ${response.statusCode}");
  //
  //     isAdded = response.statusCode == 200;
  //
  //   } catch (e) {
  //     print("❌ Error uploading document: $e");
  //   }
  //
  //   return isAdded;
  // }

  // static Future<bool> uploadDriverDocument(Documents documents) async {
  //   String userId = await FireStoreUtils.getCurrentUid();
  //   bool isAdded = false;
  //
  //   print("------------ Document Upload Debug Log ------------");
  //   print("User ID      : $userId");
  //   print("documentId   : ${documents.documentId}");
  //   print("status       : ${documents.status}");
  //   print("type         : restaurant");
  //   print("frontImage   : ${documents.frontImage}");
  //   print("backImage    : ${documents.backImage}");
  //   print("--------------------------------------------------");
  //
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${Constant.baseUrl}documents/driver/upload'),
  //     );
  //
  //     request.fields['userId'] = userId;
  //     request.fields['documentId'] = documents.documentId ?? '';
  //     request.fields['status'] = documents.status ?? '';
  //     request.fields['type'] = 'restaurant';
  //
  //     if (documents.frontImage != null && documents.frontImage!.isNotEmpty) {
  //       request.files.add(await http.MultipartFile.fromPath('frontImage', documents.frontImage!));
  //     }
  //
  //     if (documents.backImage != null && documents.backImage!.isNotEmpty) {
  //       request.files.add(await http.MultipartFile.fromPath('backImage', documents.backImage!));
  //     }
  //
  //     var response = await request.send();
  //     print('uploadDriverDocument Response: ${response.statusCode}');
  //
  //     isAdded = response.statusCode == 200;
  //   } catch (e) {
  //     ShowToastDialog.closeLoader();
  //     print('Error uploading document: $e');
  //   }
  //
  //   return isAdded;
  // }

  // static Future<bool> uploadDriverDocument(Documents documents) async {
  //   String userId = await FireStoreUtils.getCurrentUid();
  //   bool isAdded = false;
  //
  //   try {
  //     // Create multipart request
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${Constant.baseUrl}documents/driver/upload'),
  //     );
  //     // Add fields
  //     request.fields['userId'] = userId;
  //     request.fields['documentId'] = documents.documentId ?? '';
  //     request.fields['status'] = documents.status ?? '';
  //     request.fields['type'] = 'restaurant';
  //     if (documents.frontImage != null && documents.frontImage!.isNotEmpty) {
  //       // Assuming frontImage is a file path or you have a way to get the file
  //       var frontImageFile = await http.MultipartFile.fromPath(
  //         'frontImage',
  //         documents.frontImage!,
  //       );
  //       request.files.add(frontImageFile);
  //     }
  //
  //     if (documents.backImage != null && documents.backImage!.isNotEmpty) {
  //       // Assuming backImage is a file path
  //       var backImageFile = await http.MultipartFile.fromPath(
  //         'backImage',
  //         documents.backImage!,
  //       );
  //       request.files.add(backImageFile);
  //     }
  //     // Send the request
  //     var response = await request.send();
  //     print('uploadDriverDocument: ${response.statusCode}');
  //     if (response.statusCode == 200) {
  //       isAdded = true;
  //     } else {
  //       isAdded = false;
  //       print('Upload failed with status: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     isAdded = false;
  //     print('Error uploading document: $error');
  //   }
  //   return isAdded;
  // }



  static Future<DeliveryCharge?> getDelivery() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/delivery-charge'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return DeliveryCharge.fromJson(jsonData);
      } else {
        print('Failed to load delivery charge: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching delivery charge: $e');
      return null;
    }
  }

  static Future<VendorModel> firebaseCreateNewVendor(VendorModel vendor) async {
    try {
      String vendorId = const Uuid().v4();
      vendor.id = vendorId;
      Map<String, dynamic> requestBody = _convertVendorToJson(vendor);
      log("firebaseCreateNewVendor  ${requestBody}");
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/vendors'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      log(" firebaseCreateNewVendor response ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          if (jsonResponse['data'] != null) {
            VendorModel createdVendor = VendorModel.fromJson(jsonResponse['data']);
            // Constant.userModel!.id = userId;
            Constant.userModel!.vendorID = createdVendor.id ?? vendorId;
            vendor.fcmToken = Constant.userModel!.fcmToken;
            Constant.vendorAdminCommission = createdVendor.adminCommission ?? vendor.adminCommission;
            await updateUser(Constant.userModel!);
            return createdVendor;
          } else {
            // Constant.userModel!.id = userId;
            Constant.userModel!.vendorID = vendorId;
            vendor.fcmToken = Constant.userModel!.fcmToken;
            Constant.vendorAdminCommission = vendor.adminCommission;
            await updateUser(Constant.userModel!);
            return vendor;
          }
        } else {
          throw Exception('API returned unsuccessful response: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to create vendor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating vendor: $e');
      rethrow;
    }
  }

// Helper method to convert VendorModel to JSON with proper GeoPoint handling
// Helper method to convert VendorModel to JSON with proper GeoPoint handling
  static Map<String, dynamic> _convertVendorToJson(VendorModel vendor) {
    // Always create a fresh workingHours array to avoid any reference issues
    List<Map<String, dynamic>> workingHoursArray = _createDefaultWorkingHours();

    // Create a new map instead of using vendor.toJson() directly
    Map<String, dynamic> json = {
      'author': vendor.author,
      'dine_in_active': vendor.dineInActive,
      'openDineTime': vendor.openDineTime,
      'categoryID': vendor.categoryID,
      'id': vendor.id,
      'categoryPhoto': vendor.categoryPhoto,
      'restaurantMenuPhotos': vendor.restaurantMenuPhotos ?? [],
      'subscriptionPlanId': vendor.subscriptionPlanId,
      'subscriptionExpiryDate': vendor.subscriptionExpiryDate,
      'subscription_plan': vendor.subscriptionPlan?.toJson(),
      'subscriptionTotalOrders': vendor.subscriptionTotalOrders,
      'location': vendor.location,
      'fcmToken': vendor.fcmToken,
      'hidephotos': vendor.hidephotos,
      'reststatus': vendor.reststatus,
      'filters': vendor.filters?.toJson(),
      'workingHours': workingHoursArray, // Use the fresh array
    };

    // Handle the 'g' field separately with proper GeoPoint serialization
    if (vendor.g != null) {
      json['g'] = {
        'geohash': vendor.g!.geohash,
        'geopoint': {
          'latitude': vendor.g!.geopoint?.latitude,
          'longitude': vendor.g!.geopoint?.longitude,
          '_latitude': vendor.g!.geopoint?.latitude,
          '_longitude': vendor.g!.geopoint?.longitude,
        }
      };
    }

    // Add any other vendor fields you need
    if (vendor.title != null) json['title'] = vendor.title;
    if (vendor.description != null) json['description'] = vendor.description;
    if (vendor.phonenumber != null) json['phonenumber'] = vendor.phonenumber;
    if (vendor.latitude != null) json['latitude'] = vendor.latitude;
    if (vendor.longitude != null) json['longitude'] = vendor.longitude;

    // Limit photos array to prevent database overflow
    json['photos'] = _limitArrayLength(vendor.photos, 5) ?? [];

    if (vendor.photo != null) json['photo'] = vendor.photo;
    if (vendor.zoneId != null) json['zoneId'] = vendor.zoneId;
    if (vendor.isSelfDelivery != null) json['isSelfDelivery'] = vendor.isSelfDelivery;
    if (vendor.adminCommission != null) json['adminCommission'] = vendor.adminCommission?.toJson();
    if (vendor.deliveryCharge != null) json['deliveryCharge'] = vendor.deliveryCharge?.toJson();

    // Final validation
    _validateJsonBeforeSending(json);

    return json;
  }

// Validate the JSON structure before sending
  static void _validateJsonBeforeSending(Map<String, dynamic> json) {
    print("=== VALIDATION: workingHours type: ${json['workingHours']?.runtimeType}");
    print("=== VALIDATION: workingHours is List: ${json['workingHours'] is List}");

    // Convert to JSON string and back to verify it survives encoding
    String testJson = jsonEncode(json);
    Map<String, dynamic> decoded = jsonDecode(testJson);
    print("=== VALIDATION: After encode/decode, workingHours type: ${decoded['workingHours']?.runtimeType}");
    print("=== VALIDATION: After encode/decode, workingHours is List: ${decoded['workingHours'] is List}");

    if (decoded['workingHours'] is! List) {
      print("=== WARNING: workingHours did not survive JSON encoding as List!");
    }
  }

// Helper method to create default working hours
  static List<Map<String, dynamic>> _createDefaultWorkingHours() {
    return [
      {'day': 'Monday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
      {'day': 'Tuesday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
      {'day': 'Wednesday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
      {'day': 'Thursday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
      {'day': 'Friday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
      {'day': 'Saturday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
      {'day': 'Sunday', 'timeslot': [{'to': '23:59', 'from': '00:00'}]},
    ];
  }

// Helper method to limit array length
  static List<dynamic>? _limitArrayLength(List<dynamic>? array, int maxLength) {
    if (array == null) return null;
    if (array.length <= maxLength) return array;
    return array.sublist(0, maxLength);
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    try {
      print(' updateVendor ${Constant.baseUrl}restaurant/vendors/${vendor.id}');
      print(' updateVendor ${vendor.toJson()}');
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}restaurant/vendors/${vendor.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(vendor.toJson()),
      );
      log("updateVendor ${response.body} ");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Constant.vendorAdminCommission = vendor.adminCommission;
          if (responseData['data'] != null) {
            return VendorModel.fromJson(responseData['data']);
          } else {
            return vendor;
          }
        } else {
          throw Exception('API returned success: false: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to update vendor: ${response.statusCode}');
      }
    } catch (error) {
      log("Failed to update vendor: $error");
      return null;
    }
  }
  final loginController = Get.find<LoginController>(); // Finds existing instance

   Future<bool?> deleteUser() async {
    try {
      String userId = await getCurrentUid();
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}restaurant/user_delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
        }),
      );
      if (response.statusCode == 200) {
        loginController.logoutFunction();
        return true;
      } else {
        log('Delete user API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, s) {
      log('FireStoreUtils.deleteUser $e $s');
      return false;
    }
  }

  static Future<Url> uploadChatImageToFireStorage(
      File image, BuildContext context) async {
    ShowToastDialog.showLoader("Please wait");
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(
        mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(
      BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef =
          FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      File thumbnail = await VideoCompress.getFileThumbnail(
        video.path,
        quality: 75, // 0 - 100
        position: -1, // Get the first frame
      );
      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef =
          FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnail.readAsBytesSync(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(
          videoUrl: Url(
              url: videoUrl.toString(),
              mime: metaData.contentType ?? 'video',
              videoThumbnail: thumbnailUrl),
          thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadImageOfStory(
      File image, BuildContext context, String extansion) async {
    final data = await image.readAsBytes();
    final mime = lookupMimeType('', headerBytes: data);

    Reference upload = FirebaseStorage.instance.ref().child(
          'Story/images/${image.path.split('/').last}',
        );
    UploadTask uploadTask =
        upload.putFile(image, SettableMetadata(contentType: mime));
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    ShowToastDialog.closeLoader();
    return downloadUrl.toString();
  }

  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }
  static Future<String?> uploadVideoStory(
      File video, BuildContext context) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('Story/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    ShowToastDialog.closeLoader();
    return downloadUrl.toString();
  }
  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload =
        FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }
  static Future<StoryModel?> getStory(String vendorId) async {
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/stories/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If API returns the story data
          if (responseData['data'] != null) {
            return StoryModel.fromJson(responseData['data']);
          } else {
            return null; // No story found
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 404) {
        // Story not found
        return null;
      } else {
        throw Exception('Failed to load story: ${response.statusCode}');
      }
    } catch (error) {
      log("Error fetching story: $error");
      return null;
    }
  }
  static Future<void> addOrUpdateStory(StoryModel storyModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/stories'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(storyModel.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Successfully added/updated
          return;
        } else {
          throw Exception('API returned success: false: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to add/update story: ${response.statusCode}');
      }
    } catch (error) {
      log("Failed to add/update story: $error");
      throw error; // Re-throw to maintain similar behavior to Firebase version
    }
  }
  static Future<void> removeStory(String vendorId) async {
    try {
      // Make API call
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}restaurant/stories/$vendorId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return;
        } else {
          throw Exception('API returned success: false: ${responseData['message']}');
        }
      } else if (response.statusCode == 404) {
        // Story not found - this might be acceptable depending on requirements
        log("Story not found for vendor: $vendorId");
        return;
      } else {
        throw Exception('Failed to delete story: ${response.statusCode}');
      }
    } catch (error) {
      log("Failed to delete story: $error");
      throw error; // Re-throw to maintain similar behavior to Firebase version
    }
  }
  static Future<WithdrawMethodModel?> getWithdrawMethod() async {
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/withdraw-method?userId=${getCurrentUid()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];

          if (data.isNotEmpty) {
            WithdrawMethodModel withdrawMethodModel = WithdrawMethodModel.fromJson(data.first);
            return withdrawMethodModel;
          } else {
            return null; // No withdraw method found
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load withdraw method: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }
  static Future<WithdrawMethodModel?> setWithdrawMethod(
      WithdrawMethodModel withdrawMethodModel) async {
    try {
      String userId = await FireStoreUtils.getCurrentUid();
      // Prepare the data
      if (withdrawMethodModel.id == null) {
        withdrawMethodModel.id = const Uuid().v4();
        withdrawMethodModel.userId = userId;
      }
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/withdraw-method'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(withdrawMethodModel.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            WithdrawMethodModel updatedModel = WithdrawMethodModel.fromJson(responseData['data']);
            return updatedModel;
          } else {
            return withdrawMethodModel;
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to set withdraw method: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }
  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/email-templates/$type'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            EmailTemplateModel emailTemplateModel = EmailTemplateModel.fromJson(responseData['data']);
            return emailTemplateModel;
          } else {
            return null; // No email template found
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load email template: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      return null;
    }
  }
  static sendPayoutMail(
      {required String amount, required String payoutrequestid}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(Constant.payoutRequest);
    String body = emailTemplateModel!.subject.toString();
    body = body.replaceAll("{userid}", Constant.userModel!.id.toString());
    String newString = emailTemplateModel.message.toString();
    newString =
        newString.replaceAll("{username}", Constant.userModel!.fullName());
    newString =
        newString.replaceAll("{userid}", Constant.userModel!.id.toString());
    newString =
        newString.replaceAll("{amount}", Constant.amountShow(amount: amount));
    newString =
        newString.replaceAll("{payoutrequestid}", payoutrequestid.toString());
    newString = newString.replaceAll("{usercontactinfo}",
        "${Constant.userModel!.email}\n${Constant.userModel!.phoneNumber}");
    await Constant.sendMail(
        subject: body,
        isAdmin: emailTemplateModel.isSendToAdmin,
        body: newString,
        recipients: [Constant.userModel!.email]);
  }
  static Future<NotificationModel?> getNotificationContent(String type) async {
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/notifications/$type'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If API returns the notification data
          if (responseData['data'] != null) {
            print("------>");
            print(responseData['data']);

            NotificationModel notificationModel =
            NotificationModel.fromJson(responseData['data']);
            return notificationModel;
          } else {
            // No notification found - return default
            return NotificationModel(
              id: "",
              message: "Notification setup is pending",
              subject: "setup notification",
              type: type,
            );
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 404) {
        // Notification not found - return default
        return NotificationModel(
          id: "",
          message: "Notification setup is pending",
          subject: "setup notification",
          type: type,
        );
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (error) {
      log("Error fetching notification: $error");
      // Return default notification on error
      return NotificationModel(
        id: "",
        message: "Notification setup is pending",
        subject: "setup notification",
        type: type,
      );
    }
  }



  static Future<bool?> setProduct(ProductModel productModel) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/products'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(productModel.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return true;
        } else {
          log("Failed to add product: API returned success false - ${responseData['message']}");
          return false;
        }
      } else {
        log("Failed to add product: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      log("Failed to add product: $error");
      return false;
    }
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String userID) async {
    Reference upload =
        FirebaseStorage.instance.ref().child('images/$userID.png');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }
  static Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    List<SubscriptionPlanModel> subscriptionPlanModels = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}subscriptions/plans'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];

          if (data.isNotEmpty) {
            for (var element in data) {
              SubscriptionPlanModel subscriptionPlanModel =
              SubscriptionPlanModel.fromJson(element);

              if (subscriptionPlanModel.isEnable == true &&
                  subscriptionPlanModel.id != Constant.commissionSubscriptionID) {
                subscriptionPlanModels.add(subscriptionPlanModel);
              }
            }

            // Sort by place ascending (to match Firebase orderBy behavior)
            subscriptionPlanModels.sort((a, b) {
              if (a.place == null && b.place == null) return 0;
              if (a.place == null) return 1;
              if (b.place == null) return -1;
              return a.place!.compareTo(b.place!);
            });
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load subscription plans: ${response.statusCode}');
      }
    } catch (error) {
      log("Error fetching subscription plans: $error");
    }
    return subscriptionPlanModels;
  }
  static Future<SubscriptionPlanModel?> getSubscriptionPlanById(
      {required String planId}) async {
    try {
      if (planId.isEmpty) {
        return null;
      }

      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}subscriptions/plans/$planId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If API returns the plan data
          if (responseData['data'] != null) {
            SubscriptionPlanModel subscriptionPlanModel =
            SubscriptionPlanModel.fromJson(responseData['data']);
            return subscriptionPlanModel;
          } else {
            return null; // No plan found
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 404) {
        // Plan not found
        return null;
      } else {
        throw Exception('Failed to load subscription plan: ${response.statusCode}');
      }
    } catch (error) {
      log("Error fetching subscription plan: $error");
      return null;
    }
  }
  static Future<SubscriptionPlanModel> setSubscriptionPlan(
      SubscriptionPlanModel subscriptionPlanModel) async {
    try {
      if (subscriptionPlanModel.id?.isEmpty == true) {
        subscriptionPlanModel.id = const Uuid().v4();
      }
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}subscriptions/plans'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(subscriptionPlanModel.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            return SubscriptionPlanModel.fromJson(responseData['data']);
          } else {
            return subscriptionPlanModel;
          }
        } else {
          throw Exception('API returned success: false: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to set subscription plan: ${response.statusCode}');
      }
    } catch (error) {
      log("Failed to set subscription plan: $error");
      throw error;
    }
  }

  static Future<bool?> setSubscriptionTransaction(
      SubscriptionHistoryModel subscriptionPlan) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}subscriptions/transactions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(subscriptionPlan.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return true; // Successfully added
        } else {
          log("Failed to add subscription transaction: API returned success false");
          return false;
        }
      } else {
        log("Failed to add subscription transaction: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      log("Failed to add subscription transaction: $error");
      return false;
    }
  }
  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}subscriptions/history?user_id=${getCurrentUid()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];

          if (data.isNotEmpty) {
            for (var element in data) {
              SubscriptionHistoryModel subscriptionHistoryModel =
              SubscriptionHistoryModel.fromJson(element);
              subscriptionHistoryList.add(subscriptionHistoryModel);
            }

            // Sort by createdAt descending (to match Firebase orderBy behavior)
            subscriptionHistoryList.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load subscription history: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
    }
    return subscriptionHistoryList;
  }
  static Future<AdvertisementModel> firebaseCreateAdvertisement(
      AdvertisementModel model) async {
    try {
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}advertisements'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(model.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (responseData['data'] != null) {
            return AdvertisementModel.fromJson(responseData['data']);
          } else {
            return model;
          }
        } else {
          log('API returned success: false for create advertisement');
          throw Exception('Failed to create advertisement: ${responseData['message']}');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create advertisement: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      throw Exception('Failed to create advertisement: $error');
    }
  }

  static Future<AdvertisementModel> removeAdvertisement(
      AdvertisementModel model) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constant.baseUrl}advertisements/${model.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return model;
        } else {
          log('API returned success: false for delete advertisement');
          throw Exception('Failed to delete advertisement: ${responseData['message']}');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete advertisement: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      throw Exception('Failed to delete advertisement: $error');
    }
  }
  static Future<AdvertisementModel> pauseAndResumeAdvertisement(
      AdvertisementModel model) async {
    try {
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}advertisements/${model.id}/pause-resume'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(model.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If the API returns the updated advertisement data, use it
          if (responseData['data'] != null) {
            return AdvertisementModel.fromJson(responseData['data']);
          } else {
            return model;
          }
        } else {
          log('API returned success: false for pause/resume advertisement ');
          throw Exception('Failed to pause/resume advertisement: ${responseData['message']}');
        }
      } else {
        log('HTTP Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to pause/resume advertisement: ${response.statusCode}');
      }
    } catch (error) {
      log(error.toString());
      throw Exception('Failed to pause/resume advertisement: $error');
    }
  }

  static Future<List<RatingModel>> getOrderReviewsByVenderId({
    required String venderId
  }) async {
    List<RatingModel> ratingModelList = [];
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/reviews/vendor/$venderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> reviewsData = jsonResponse['data'];
          print("======>");
          print(reviewsData.length);
          for (final reviewData in reviewsData) {
            ratingModelList.add(RatingModel.fromJson(reviewData));
          }
        } else {
          print("No reviews found or API returned error");
        }
      } else {
        print("Failed to fetch reviews: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print("Error fetching reviews: $error");
    }

    return ratingModelList;
  }

  static Future<List<UserModel>> getAvalibleDrivers({String? zoneId}) async {
    List<UserModel> driverList = [];
    try {
      String? userId = await getFirebaseId();
      log("getAvalibleDrivers :: 22  $userId");
      // Make API call
      String url = "";
      if(zoneId==null){
        url = '${Constant.baseUrl}drivers/available';
      }else{
        url = '${Constant.baseUrl}drivers/available?zoneId=$zoneId';
      }
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      log("getAvalibleDrivers ${response.body} ");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            for (var element in data) {
              driverList.add(UserModel.fromJson(element));
            }
            // Sort by createdAt descending (to match Firebase orderBy behavior)
            driverList.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load available drivers: ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return driverList;
  }
  static Future<List<UserModel>> getAllDrivers() async {
    List<UserModel> driverList = [];
    try {
      // Make API call
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}drivers/all?vendorID=${Constant.userModel?.vendorID}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            for (var element in data) {
              driverList.add(UserModel.fromJson(element));
            }
            // Sort by createdAt descending (to match Firebase orderBy behavior)
            driverList.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });
          }
        } else {
          throw Exception('API returned success: false');
        }
      } else {
        throw Exception('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return driverList;
  }

  static Future<void> updateProductIsAvailable(String productId, bool isAvailable) async {
    try {
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}restaurant/products/$productId/availability'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'isAvailable': isAvailable,
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Product availability updated successfully');
      } else {
        print("Failed to update product availability: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to update product availability');
      }
    } catch (error) {
      print("Failed to update product availability: $error");
      throw error;
    }
  }


  static Future<void> updateCategoryIsActive(String categoryId, bool isActive) async {
    try {
      print("updateCategoryIsActive ${isActive}");
      String url  = '${Constant.baseUrl}restaurant/vendor-categories/$categoryId/active';
          // 'restaurant/categories/$categoryId/products-availability'
      // ;
      print("updateCategoryIsActive $url vendorID ${Constant.userModel!.vendorID}  isAvailable ${isActive ? 1 : 0}");
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          // 'vendorID': Constant.userModel!.vendorID, // Assuming you have vendorID in user model
          'isActive': isActive , // Convert bool to int (1 for true, 0 for false)
        }),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Category availability updated successfully');
      } else {
        print("Failed to update category availability: ${response.statusCode} - ${response.body}");
        throw Exception('Failed to update category availability');
      }
    } catch (error) {
      print("Failed to update category availability: $error");
      throw error;
    }
  }


  static Future<void> setAllProductsAvailabilityForCategory(
      String categoryId,
      bool isAvailable
      ) async {
    try {
      final url = Uri.parse('${Constant.baseUrl}restaurant/categories/$categoryId/products-availability');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "vendorID": Constant.userModel!.vendorID,
          "isAvailable": isAvailable ? 1 : 0, // Convert bool to int
        }),
      );

      if (response.statusCode == 200) {
        print('Products availability updated successfully');
      } else {
        print('Failed to update products availability: ${response.statusCode}');
        throw Exception('Failed to update products availability');
      }
    } catch (e) {
      print('Error updating products availability: $e');
      throw e;
    }
  }
}
