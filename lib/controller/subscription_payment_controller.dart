import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/payment_model/razorpay_model.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/service/subscription_purchase_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

import '../models/user_model.dart';
import '../models/vendor_model.dart';

/// Handles Razorpay payment for subscription plans and sends data to subscription_history.
class SubscriptionPaymentController extends GetxController {
  late Razorpay _razorPay;

  final RxBool isProcessing = false.obs;

  RazorPayModel? _razorPayModel;
  SubscriptionPlanModel? _currentPlan;
  String? _currentZoneId;

  @override
  void onInit() {
    super.onInit();
    _razorPay = Razorpay();
    _razorPay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorPay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorPay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorPay.clear();
    super.onClose();
  }

  /// Public entry point from UI.
  Future<void> startRazorpayPayment(SubscriptionPlanModel plan) async {
    if (isProcessing.value) return;

    final user = Constant.userModel;
    if (user == null || user.id == null) {
      ShowToastDialog.showToast('User not found. Please login again.'.tr);
      return;
    }

    final int amount = int.tryParse(plan.price) ?? 0;
    // If free plan (0 price), just create history entry without payment.
    if (amount <= 0) {
      final zoneId = await _resolveZoneId();
      final success = await SubscriptionPurchaseService.createSubscriptionHistory(
        plan: plan,
        userId: user.id!,
        zoneId: zoneId,
        paymentType: 'free',
        expiryDate: _computeExpiry(plan),
      );
      if (success) {
        ShowToastDialog.showToast('Plan activated successfully.'.tr);
      } else {
        ShowToastDialog.showToast('Unable to activate plan. Please try again.'.tr);
      }
      return;
    }

    try {
      isProcessing.value = true;
      _currentPlan = plan;
      _currentZoneId = await _resolveZoneId();

      await _loadRazorPaySettingsIfNeeded();
      if (_razorPayModel == null ||
          _razorPayModel!.razorpayKey == null ||
          _razorPayModel!.razorpayKey!.isEmpty) {
        ShowToastDialog.showToast(
            'Razorpay is not configured. Please contact admin.'.tr);
        isProcessing.value = false;
        return;
      }

      // Client-only checkout (no backend order_id) to avoid 404 issues.
      final options = {
        'key': _razorPayModel!.razorpayKey,
        'amount': amount * 100, // in paise
        'name': 'Jippymart Restaurant',
        'description': plan.name,
        'prefill': {
          'name': user.fullName(),
          'email': user.email ?? '',
          'contact': user.phoneNumber ?? '',
        },
        'theme': {
          'color': '#6839FF',
        },
      };

      debugPrint('Opening Razorpay with options: $options');
      _razorPay.open(options);
    } catch (e, st) {
      debugPrint('startRazorpayPayment error: $e $st');
      ShowToastDialog.showToast(
        'Unable to start payment: ${e.toString()}',
      );
      isProcessing.value = false;
    }
  }

  Future<void> _loadRazorPaySettingsIfNeeded() async {
    if (_razorPayModel != null) return;
    try {
      // Use same endpoint as wallet payment methods: /settings/payment
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}settings/payment'),
        headers: const {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final Map<String, dynamic> paymentData = data['data'] as Map<String, dynamic>;
        if (paymentData.containsKey('razorpaySettings')) {
          _razorPayModel = RazorPayModel.fromJson(
            Map<String, dynamic>.from(paymentData['razorpaySettings'] as Map),
          );
        }
      } else {
        debugPrint('Failed to load payment methods: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _loadRazorPaySettingsIfNeeded: $e');
    }
  }

  /// Same zone resolution as SubscriptionPlansController.
  Future<String> _resolveZoneId() async {
    // 1. From dashboard's restaurant (vendor)
    if (Get.isRegistered<DashBoardController>()) {
      try {
        final dashboard = Get.find<DashBoardController>();
        final zoneId = dashboard.vendorModel.value.zoneId;
        if (zoneId != null && zoneId.toString().trim().isNotEmpty) {
          return zoneId.toString().trim();
        }
      } catch (_) {}
    }

    // 2. From current user
    final userZone = Constant.userModel?.zoneId?.toString().trim();
    if (userZone != null && userZone.isNotEmpty) {
      return userZone;
    }

    // 3. Vendor details by vendorID
    final vendorId = Constant.userModel?.vendorID?.toString().trim();
    if (vendorId != null && vendorId.isNotEmpty) {
      try {
        final vendor = await FireStoreUtils.getVendorById(vendorId);
        final zoneId = vendor?.zoneId?.toString().trim();
        if (zoneId != null && zoneId.isNotEmpty) {
          return zoneId;
        }
      } catch (_) {}
    }

    // 4. From preferences fallback using vendor model key
    return Preferences.getString(
      VendorModel.zoneIdPrefKey,
      defaultValue: '',
    ).trim();
  }

  DateTime? _computeExpiry(SubscriptionPlanModel plan) {
    final days = int.tryParse(plan.expiryDay);
    if (days == null || days <= 0) return null;
    return DateTime.now().add(Duration(days: days));
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final user = Constant.userModel;
      final plan = _currentPlan;
      final zoneId = _currentZoneId ?? await _resolveZoneId();

      if (user == null || user.id == null || plan == null) {
        ShowToastDialog.showToast('Payment succeeded, but user/plan not found.'.tr);
        isProcessing.value = false;
        return;
      }

      final ok = await SubscriptionPurchaseService.createSubscriptionHistory(
        plan: plan,
        userId: user.id!,
        zoneId: zoneId,
        paymentType: 'razorpay',
        expiryDate: _computeExpiry(plan),
      );

      if (ok) {
        ShowToastDialog.showToast('Payment successful! Your subscription plan starts today.'.tr);
      } else {
        ShowToastDialog.showToast('Payment successful but failed to save subscription. Please contact support.'.tr);
      }
    } finally {
      isProcessing.value = false;
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ShowToastDialog.showToast('Payment processing via external wallet.'.tr);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isProcessing.value = false;
    ShowToastDialog.showToast('Payment failed. Please try again.'.tr);
  }
}

