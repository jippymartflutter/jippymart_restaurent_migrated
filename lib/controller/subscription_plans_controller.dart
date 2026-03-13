import 'package:get/get.dart';

import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/service/subscription_api_service.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

import '../models/vendor_model.dart';

/// GetX controller for subscription plans screen.
/// Resolves zone from restaurant (vendor) details, then preferences.
class SubscriptionPlansController extends GetxController {
  final RxList<SubscriptionPlanModel> plans = <SubscriptionPlanModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onReady() {
    fetchPlans();
    super.onReady();
  }

  /// Resolves `zoneId` in order:
  /// 1. From current dashboard vendor (`VendorModel.zoneId`)
  /// 2. From persisted preferences (`VendorModel.zoneIdPrefKey`)
  Future<String> _resolveZoneId() async {
    // 1) Try from in‑memory dashboard vendor
    try {
      final dashboard = Get.find<DashBoardController>();
      final vendor = dashboard.vendorModel.value;
      final zoneId = vendor.zoneId;
      if (zoneId != null && zoneId.trim().isNotEmpty) {
        return zoneId.trim();
      }
    } catch (_) {
      // Ignore and fall back to preferences
    }

    // 2) Fallback: previously stored zone id (if any)
    final prefZoneId =
        await Preferences.getString(VendorModel.zoneIdPrefKey) ?? '';
    return prefZoneId.trim();
  }

  /// Fetches plans from API. Use for initial load and pull-to-refresh.
  Future<void> fetchPlans({bool forceRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    final zoneId = await _resolveZoneId();
    if (zoneId.isEmpty) {
      isLoading.value = false;
      plans.clear();
      errorMessage.value = 'Unable to determine your zone. Please try again.';
      return;
    }

    final response = await SubscriptionApiService.getSubscriptionPlans(
      zoneId: zoneId,
      forceRefresh: forceRefresh,
    );

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
