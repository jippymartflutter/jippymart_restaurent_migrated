import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:http/http.dart' as http;
class FireStoreUtils {
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<String> getCurrentUid() async{
    return await getFirebaseId()??'';
      // FirebaseAuth.instance.currentUser!.uid;
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
    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }
  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
        Constant.userModel = userModel;
      }
    });
    return userModel;
  }

  static Future<UserModel?> getUserById(String uuid) async {
    UserModel? userModel;
    log("uuid :: $uuid");
    await fireStore
        .collection(CollectionName.users)
        .doc(uuid)
        .get()
        .then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    });
    return userModel;
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
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/updateUser'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: userModel.toJson(),
      );
      if (response.statusCode == 200) {
        Constant.userModel = userModel;
        isUpdate = true;
      } else {
        log("Failed to update user: ${response.statusCode} - ${response.body}");
        isUpdate = false;
      }
    } catch (error) {
      log("Failed to update user: $error");
      isUpdate = false;
    }

    return isUpdate;
  }

  static Future<bool> updateDriverUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore
        .collection(CollectionName.users)
        .doc(userModel.id)
        .set(userModel.toJson())
        .whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
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
      final response = await http.post(
        Uri.parse('${Constant.baseUrl}restaurant/wallet/transaction'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(walletTransactionModel.toJson()),
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
      log("Failed to update user: $error");
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
      log(error.toString());
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
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}restaurant/orders/${orderModel.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orderModel.toJson()),
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
    await fireStore
        .collection(CollectionName.wallet)
        .doc(historyModel.id)
        .set(historyModel.toJson());

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

    await fireStore
        .collection(CollectionName.wallet)
        .doc(historyModel.id)
        .set(historyModel.toJson());
    await fireStore
        .collection(CollectionName.wallet)
        .doc(taxModel.id)
        .set(taxModel.toJson());

    await updateUserWallet(
        amount: (basePrice + taxAmount).toString(),
        userId: orderModel.vendor!.author.toString());
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
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}restaurant/products?vendorID=${Constant.userModel!.vendorID}'),
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

          for (final productData in productsData) {
            ProductModel productModel = ProductModel.fromJson(productData);
            productList.add(productModel);
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
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}restaurant/products/${productModel.id}'),
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
      print("Failed to update product: $error");
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
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future<List<WalletTransactionModel>?> getFilterWalletTransaction(
      Timestamp startTime, Timestamp endTime) async {
    List<WalletTransactionModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('date', isGreaterThanOrEqualTo: startTime)
        .where('date', isLessThanOrEqualTo: endTime)
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel =
            WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future<List<WithdrawalModel>?> getWithdrawHistory() async {
    List<WithdrawalModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.payouts)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID.toString())
        .orderBy('paidDate', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WithdrawalModel walletTransactionModel =
            WithdrawalModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
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
          // Process each payment method
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
      if (vendorId.isNotEmpty) {
        await fireStore
            .collection(CollectionName.vendors)
            .doc(vendorId)
            .get()
            .then((value) {
          if (value.exists) {
            vendorModel = VendorModel.fromJson(value.data()!);
          }
        });
      }
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorModel;
  }

  static Future<List<VendorCategoryModel>?> getVendorCategoryById() async {
    List<VendorCategoryModel> attributeList = [];
    await fireStore
        .collection(CollectionName.vendorCategories)
        .where('publish', isEqualTo: true)
        .get()
        .then(
      (value) {
        for (var element in value.docs) {
          VendorCategoryModel favouriteModel =
              VendorCategoryModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
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
  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(
      String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.vendorCategories)
          .doc(categoryId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(
      String attributeId) async {
    ReviewAttributeModel? vendorCategoryModel;
    try {
      await fireStore
          .collection(CollectionName.reviewAttributes)
          .doc(attributeId)
          .get()
          .then((value) {
        if (value.exists) {
          vendorCategoryModel = ReviewAttributeModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<List<AttributesModel>?> getAttributes() async {
    List<AttributesModel> attributeList = [];
    await fireStore.collection(CollectionName.vendorAttributes).get().then(
      (value) {
        for (var element in value.docs) {
          AttributesModel favouriteModel =
              AttributesModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
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

  static Future<List<DineInBookingModel>> getDineInBooking(
      bool isUpcoming) async {
    List<DineInBookingModel> list = [];

    if (isUpcoming) {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel =
              DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    }

    return list;
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
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.coupons)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> deleteCoupon(CouponModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.coupons)
        .doc(orderModel.id)
        .delete()
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
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
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}documents'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> documentsData = responseData['data'];
          for (var element in documentsData) {
            // Apply filters: type == "restaurant" and enable == 1 (true)
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
    String userId = await FireStoreUtils.getCurrentUid();
    DriverDocumentModel? driverDocumentModel;
    await fireStore
        .collection(CollectionName.documentsVerify)
        .doc(userId)
        .get()
        .then((value) async {
      if (value.exists) {
        driverDocumentModel = DriverDocumentModel.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addAdminInbox(InboxModel inboxModel) async {
    return await fireStore
        .collection(CollectionName.chatAdmin)
        .doc(inboxModel.orderId)
        .set(inboxModel.toJson())
        .then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection("chat_restaurant")
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future addAdminChat(ConversationModel conversationModel) async {
    return await fireStore
        .collection(CollectionName.chatAdmin)
        .doc(conversationModel.orderId)
        .collection("thread")
        .doc(conversationModel.id)
        .set(conversationModel.toJson())
        .then((document) {
      return conversationModel;
    });
  }

  static Future<bool> uploadDriverDocument(Documents documents) async {
    String userId = await FireStoreUtils.getCurrentUid();
    bool isAdded = false;
    DriverDocumentModel driverDocumentModel = DriverDocumentModel();
    List<Documents> documentsList = [];
    await fireStore
        .collection(CollectionName.documentsVerify)
        .doc(userId)
        .get()
        .then((value) async {
      if (value.exists) {
        DriverDocumentModel newDriverDocumentModel =
            DriverDocumentModel.fromJson(value.data()!);
        documentsList = newDriverDocumentModel.documents!;
        var contain = newDriverDocumentModel.documents!
            .where((element) => element.documentId == documents.documentId);
        if (contain.isEmpty) {
          documentsList.add(documents);
          driverDocumentModel.id = userId;
          driverDocumentModel.type = "restaurant";
          driverDocumentModel.documents = documentsList;
        } else {
          var index = newDriverDocumentModel.documents!.indexWhere(
              (element) => element.documentId == documents.documentId);
          driverDocumentModel.id = userId;
          driverDocumentModel.type = "restaurant";
          documentsList.removeAt(index);
          documentsList.insert(index, documents);
          driverDocumentModel.documents = documentsList;
          isAdded = false;
        }
      } else {
        documentsList.add(documents);
        driverDocumentModel.id = userId;
        driverDocumentModel.type = "restaurant";
        driverDocumentModel.documents = documentsList;
      }
    });

    await fireStore
        .collection(CollectionName.documentsVerify)
        .doc(userId)
        .set(driverDocumentModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      isAdded = false;
      log(error.toString());
    });

    return isAdded;
  }

  static Future<DeliveryCharge?> getDelivery() async {
    DeliveryCharge? driverDocumentModel;
    await fireStore
        .collection(CollectionName.settings)
        .doc("DeliveryCharge")
        .get()
        .then((value) async {
      if (value.exists) {
        driverDocumentModel = DeliveryCharge.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future<VendorModel> firebaseCreateNewVendor(VendorModel vendor) async {
    DocumentReference documentReference =
        fireStore.collection(CollectionName.vendors).doc();
    vendor.id = documentReference.id;
    await documentReference.set(vendor.toJson());
    Constant.userModel!.vendorID = documentReference.id;
    vendor.fcmToken = Constant.userModel!.fcmToken;
    Constant.vendorAdminCommission = vendor.adminCommission;
    await FireStoreUtils.updateUser(Constant.userModel!);
    return vendor;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await fireStore
        .collection(CollectionName.vendors)
        .doc(vendor.id)
        .set(vendor.toJson())
        .then((document) {
      Constant.vendorAdminCommission = vendor.adminCommission;
      return vendor;
    });
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      if (Constant.userModel?.vendorID != null &&
          Constant.userModel?.vendorID?.isNotEmpty == true) {
        await fireStore
            .collection(CollectionName.coupons)
            .where('resturant_id', isEqualTo: Constant.userModel!.vendorID)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            await fireStore
                .collection(CollectionName.coupons)
                .doc(doc.reference.id)
                .delete();
          }
        });
        await fireStore
            .collection(CollectionName.foodsReview)
            .where('VendorId', isEqualTo: Constant.userModel!.vendorID)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            await fireStore
                .collection(CollectionName.foodsReview)
                .doc(doc.reference.id)
                .delete();
          }
        });

        await fireStore
            .collection(CollectionName.vendorProducts)
            .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
            .get()
            .then((value) async {
          for (var doc in value.docs) {
            await fireStore
                .collection(CollectionName.favoriteItem)
                .where('product_id', isEqualTo: doc.reference.id)
                .get()
                .then((value0) async {
              for (var element0 in value0.docs) {
                await fireStore
                    .collection(CollectionName.favoriteItem)
                    .doc(element0.reference.path)
                    .delete();
              }
            });
            await fireStore
                .collection(CollectionName.vendorProducts)
                .doc(doc.reference.id)
                .delete();
          }
        });

        await fireStore
            .collection(CollectionName.vendors)
            .doc(Constant.userModel?.vendorID)
            .delete();
      }
      String userId = await FireStoreUtils.getCurrentUid();
      await fireStore
          .collection(CollectionName.users)
          .doc(userId)
          .delete();

      // delete user  from firebase auth
      await FirebaseAuth.instance.currentUser?.delete().then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
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
    DocumentSnapshot<Map<String, dynamic>> userDocument =
        await fireStore.collection(CollectionName.story).doc(vendorId).get();
    if (userDocument.data() != null && userDocument.exists) {
      return StoryModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future addOrUpdateStory(StoryModel storyModel) async {
    await fireStore
        .collection(CollectionName.story)
        .doc(storyModel.vendorID)
        .set(storyModel.toJson());
  }

  static Future removeStory(String vendorId) async {
    await fireStore.collection(CollectionName.story).doc(vendorId).delete();
  }

  static Future<WithdrawMethodModel?> getWithdrawMethod() async {
    WithdrawMethodModel? withdrawMethodModel;
    await fireStore
        .collection(CollectionName.withdrawMethod)
        .where("userId", isEqualTo: getCurrentUid())
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        withdrawMethodModel =
            WithdrawMethodModel.fromJson(value.docs.first.data());
      }
    });
    return withdrawMethodModel;
  }

  static Future<WithdrawMethodModel?> setWithdrawMethod(
      WithdrawMethodModel withdrawMethodModel) async {
    String userId = await FireStoreUtils.getCurrentUid();
    if (withdrawMethodModel.id == null) {
      withdrawMethodModel.id = const Uuid().v4();
      withdrawMethodModel.userId = userId;
    }
    await fireStore
        .collection(CollectionName.withdrawMethod)
        .doc(withdrawMethodModel.id)
        .set(withdrawMethodModel.toJson())
        .then((value) async {});
    return withdrawMethodModel;
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await fireStore
        .collection(CollectionName.emailTemplates)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        emailTemplateModel =
            EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
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
    NotificationModel? notificationModel;
    await fireStore
        .collection(CollectionName.dynamicNotification)
        .where('type', isEqualTo: type)
        .get()
        .then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(
            id: "",
            message: "Notification setup is pending",
            subject: "setup notification",
            type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool?> setBookedOrder(DineInBookingModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.bookedTable)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setProduct(ProductModel orderModel) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.vendorProducts)
        .doc(orderModel.id)
        .set(orderModel.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
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
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .where('isEnable', isEqualTo: true)
        .orderBy('place', descending: false)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionPlanModel subscriptionPlanModel =
              SubscriptionPlanModel.fromJson(element.data());
          if (subscriptionPlanModel.id != Constant.commissionSubscriptionID) {
            subscriptionPlanModels.add(subscriptionPlanModel);
          }
        }
      }
    });
    return subscriptionPlanModels;
  }

  static Future<SubscriptionPlanModel?> getSubscriptionPlanById(
      {required String planId}) async {
    SubscriptionPlanModel? subscriptionPlanModel = SubscriptionPlanModel();
    if (planId.isNotEmpty) {
      await fireStore
          .collection(CollectionName.subscriptionPlans)
          .doc(planId)
          .get()
          .then((value) async {
        if (value.exists) {
          subscriptionPlanModel = SubscriptionPlanModel.fromJson(
              value.data() as Map<String, dynamic>);
        }
      });
    }
    return subscriptionPlanModel;
  }

  static Future<SubscriptionPlanModel> setSubscriptionPlan(
      SubscriptionPlanModel subscriptionPlanModel) async {
    if (subscriptionPlanModel.id?.isEmpty == true) {
      subscriptionPlanModel.id = const Uuid().v4();
    }
    await fireStore
        .collection(CollectionName.subscriptionPlans)
        .doc(subscriptionPlanModel.id)
        .set(subscriptionPlanModel.toJson())
        .then((value) async {});
    return subscriptionPlanModel;
  }

  static Future<bool?> setSubscriptionTransaction(
      SubscriptionHistoryModel subscriptionPlan) async {
    bool isAdded = false;
    await fireStore
        .collection(CollectionName.subscriptionHistory)
        .doc(subscriptionPlan.id)
        .set(subscriptionPlan.toJson())
        .then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    await fireStore
        .collection(CollectionName.subscriptionHistory)
        .where('user_id', isEqualTo: getCurrentUid())
        .orderBy('createdAt', descending: true)
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionHistoryModel subscriptionHistoryModel =
              SubscriptionHistoryModel.fromJson(element.data());
          subscriptionHistoryList.add(subscriptionHistoryModel);
        }
      }
    });
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
          // If the API returns the created advertisement data, use it
          if (responseData['data'] != null) {
            return AdvertisementModel.fromJson(responseData['data']);
          } else {
            // If no data returned, return the original model
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

  static Future<List<UserModel>> getAvalibleDrivers() async {
    List<UserModel> driverList = [];
    try {
      log("getAvalibleDrivers :: 22");
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleDriver)
          .where('active', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            driverList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }

    return driverList;
  }

  static Future<List<UserModel>> getAllDrivers() async {
    List<UserModel> driverList = [];
    try {
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleDriver)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            driverList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
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
      final response = await http.put(
        Uri.parse('${Constant.baseUrl}restaurant/categories/$categoryId/products-availability'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'vendorID': Constant.userModel!.vendorID, // Assuming you have vendorID in user model
          'isAvailable': isActive ? 1 : 0, // Convert bool to int (1 for true, 0 for false)
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

  static Future<void> setAllProductsAvailabilityForCategory(String categoryId, bool isAvailable) async {
    final query = await fireStore
        .collection(CollectionName.vendorProducts)
        .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
        .where('categoryID', isEqualTo: categoryId)
        .get();
    for (var doc in query.docs) {
      await doc.reference.update({'isAvailable': isAvailable});
    }
  }
}
