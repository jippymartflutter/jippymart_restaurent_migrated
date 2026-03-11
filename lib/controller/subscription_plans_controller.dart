import 'package:get/get.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/service/subscription_api_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

/// GetX controller for subscription plans screen.
/// Resolves zone from restaurant (vendor) details, then user, then preferences.
class SubscriptionPlansController extends GetxController {
  final RxList<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onReady() {
    fetchPlans();
    super.onReady();
  }

  /// Resolves zone_id in order: dashboard vendor → user model → fetch vendor by vendorID → preferences.
  Future<String> _resolveZoneId() async {
    // 1. From dashboard's restaurant (vendor) – already loaded when user is in app
    if (Get.isRegistered<DashBoardController>()) {
      try {
        final dashboard = Get.find<DashBoardController>();
        final zoneId = dashboard.vendorModel.value.zoneId;
        if (zoneId != null && zoneId.toString().trim().isNotEmpty) {
          return zoneId.toString().trim();
        }
      } catch (_) {}
    }

    // 2. From current user (login API often returns zoneId)
    final userZone = Constant.userModel?.zoneId?.toString().trim();
    if (userZone != null && userZone.isNotEmpty) {
      return userZone;
    }

    // 3. Fetch vendor by vendorID to get zone from restaurant details
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

    // 4. From preferences (saved at login)
    return Preferences.getString(Preferences.zoneIdKey, defaultValue: '').trim();
  }

  /// Fetches plans from API. Use for initial load and pull-to-refresh.
  Future<void> fetchPlans() async {
    isLoading.value = true;
    errorMessage.value = '';

    final zoneId = await _resolveZoneId();
    final response = await SubscriptionApiService.getSubscriptionPlans(zoneId: zoneId);

    isLoading.value = false;

    if (response == null) {
      errorMessage.value = 'Unable to load plans. Please try again.';
      plans.clear();
      return;
    }

    if (!response.success) {
      errorMessage.value = response.message.isNotEmpty
          ? response.message
          : 'Unable to load plans.';
      plans.clear();
      return;
    }

    plans.assignAll(response.data);
    errorMessage.value = '';
  }

  bool get hasError => errorMessage.value.isNotEmpty;
  bool get hasPlans => plans.isNotEmpty;
}
