// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/app/Home_screen/home_screen.dart';
// import 'package:jippymart_restaurant/app/dash_board_screens/sales_report_screen.dart';
// import 'package:jippymart_restaurant/app/product_screens/product_list_screen.dart';
// import 'package:jippymart_restaurant/app/profile_screen/profile_screen.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/controller/app_update_controller.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/preferences.dart';
// import 'package:jippymart_restaurant/config/app_config.dart';
// import 'package:jippymart_restaurant/models/vendor_model.dart';
//
// /// Controller for the main dashboard: vendor state, page list, and app lifecycle.
// class DashBoardController extends GetxController with WidgetsBindingObserver {
//   // ─────────────────────────────────────────────────────────────────────────
//   // State
//   // ─────────────────────────────────────────────────────────────────────────
//
//   static const Duration doublePressExitInterval = Duration(seconds: 2);
//
//   final RxInt selectedIndex = 0.obs;
//   final RxList<Widget> pageList = <Widget>[].obs;
//   final Rx<VendorModel> vendorModel = VendorModel().obs;
//   final RxBool canPopNow = false.obs;
//
//   DateTime? _lastBackPressTime;
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Lifecycle
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void onInit() {
//     super.onInit();
//     WidgetsBinding.instance.addObserver(this);
//     _restoreVendorOpenState();
//     _loadVendor();
//     _buildPageList();
//     _checkMandatoryUpdate();
//   }
//
//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.onClose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkMandatoryUpdate();
//     }
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Vendor
//   // ─────────────────────────────────────────────────────────────────────────
//
//   /// Restores last known open/closed state so the toggle does not flash closed on restart.
//   void _restoreVendorOpenState() {
//     try {
//       final saved = Preferences.getBoolean(Preferences.vendorIsOpenKey);
//       final current = vendorModel.value;
//       vendorModel.value = current.copyWith(isOpen: saved, reststatus: saved);
//       vendorModel.refresh();
//     } catch (_) {}
//   }
//
//   /// Loads vendor from API and updates local state; merges persisted isOpen when API omits it.
//   Future<void> loadVendor() async {
//     final vendorId = Constant.userModel?.vendorID?.toString();
//     if (vendorId == null || vendorId.isEmpty) return;
//
//     if (AppConfig.enableDebugLogs) {
//       // ignore: avoid_print
//       debugPrint('DashBoardController.loadVendor: vendorId=$vendorId');
//     }
//
//     try {
//       final value = await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
//       if (value == null) return;
//
//       Constant.vendorAdminCommission = value.adminCommission;
//       value.id ??= vendorId;
//
//       final isOpen = value.isOpen ??
//           Preferences.getBoolean(Preferences.vendorIsOpenKey);
//       value.isOpen = isOpen;
//       value.reststatus = isOpen;
//       Preferences.setBoolean(Preferences.vendorIsOpenKey, isOpen);
//
//       vendorModel.value = value;
//       vendorModel.refresh();
//     } catch (e) {
//       if (AppConfig.enableDebugLogs) {
//         // ignore: avoid_print
//         debugPrint('DashBoardController.loadVendor error: $e');
//       }
//     }
//   }
//
//   /// Updates restaurant open/closed status on the server and in local state.
//   Future<bool> updateRestStatus(bool status) async {
//     final vendorId = Constant.userModel?.vendorID?.toString();
//     if (vendorId == null || vendorId.isEmpty) {
//       if (AppConfig.enableDebugLogs) {
//         debugPrint('DashBoardController.updateRestStatus: missing vendorId');
//       }
//       return false;
//     }
//
//     try {
//       final latest = await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
//       if (latest == null) {
//         if (AppConfig.enableDebugLogs) {
//           debugPrint('DashBoardController.updateRestStatus: failed to load vendor');
//         }
//         return false;
//       }
//
//       latest.id ??= vendorId;
//       latest.isOpen = status;
//       latest.reststatus = status;
//
//       final updated = await FireStoreUtils.updateVendor(latest);
//       if (updated == null) return false;
//
//       await Preferences.setBoolean(Preferences.vendorIsOpenKey, status);
//       vendorModel.value = updated;
//       vendorModel.refresh();
//       return true;
//     } catch (e) {
//       if (AppConfig.enableDebugLogs) {
//         debugPrint('DashBoardController.updateRestStatus error: $e');
//       }
//       return false;
//     }
//   }
//
//   /// Whether the user should exit the app (double-back).
//   bool get shouldPopNow {
//     if (selectedIndex.value != 0) return false;
//     final now = DateTime.now();
//     if (_lastBackPressTime == null ||
//         now.difference(_lastBackPressTime!) > doublePressExitInterval) {
//       _lastBackPressTime = now;
//       return false;
//     }
//     return true;
//   }
//
//   /// Call when back is pressed; returns true if the app should pop/exit.
//   bool onBackPressed() => shouldPopNow;
//
//   /// Loads vendor from API and updates state. Alias for [loadVendor] for existing callers (e.g. refresh).
//   Future<void> getVendor() => loadVendor();
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // Private
//   // ─────────────────────────────────────────────────────────────────────────
//
//   void _loadVendor() {
//     loadVendor();
//   }
//
//   void _buildPageList() {
//     pageList.value = [
//       const HomeScreen(),
//       const ProductListScreen(),
//       const SalesReportScreen(),
//       const ProfileScreen(),
//     ];
//   }
//
//   void _checkMandatoryUpdate() {
//     try {
//       Get.find<AppUpdateController>().checkMandatoryUpdateForLoggedInUser();
//     } catch (_) {}
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/Home_screen/home_screen.dart';
import 'package:jippymart_restaurant/app/dash_board_screens/sales_report_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/product_list_screen.dart';
import 'package:jippymart_restaurant/app/profile_screen/profile_screen.dart';
import 'package:jippymart_restaurant/config/app_config.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/app_update_controller.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/preferences.dart';

/// Closure duration the restaurant owner selects when closing.
enum RestaurantCloseOption { today, threeDays, sevenDays, untilReopened }

/// Controller for the main dashboard.
///
/// Responsibilities:
///  - Vendor open/closed state (persisted across restarts)
///  - Bottom-nav tab selection
///  - Double-back-to-exit logic
///  - Mandatory update checks on resume
class DashBoardController extends GetxController with WidgetsBindingObserver {
  // ── Constants ──────────────────────────────────────────────────────────────
  static const Duration _exitWindow = Duration(seconds: 2);

  // ── Observables ────────────────────────────────────────────────────────────
  final RxInt selectedIndex = 0.obs;
  final RxList<Widget> pageList = <Widget>[].obs;
  final Rx<VendorModel> vendorModel = VendorModel().obs;

  /// True while a status-update API call is in flight – prevents double-taps.
  final RxBool isUpdatingStatus = false.obs;

  // ── Private state ──────────────────────────────────────────────────────────
  DateTime? _lastBackPress;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _buildPageList();
    _restoreOpenState(); // instant — reads SharedPreferences
    loadVendor(); // async — fetches from Firestore
    _checkUpdate();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkUpdate();
  }

  // ── Pages ──────────────────────────────────────────────────────────────────
  void _buildPageList() {
    pageList.value = const [
      HomeScreen(),
      ProductListScreen(),
      SalesReportScreen(),
      ProfileScreen(),
    ];
  }

  // ── Vendor ─────────────────────────────────────────────────────────────────

  /// Immediately applies the last-persisted open/closed value so the UI
  /// never flashes "Closed" while the network request is in flight.
  void _restoreOpenState() {
    try {
      final saved = Preferences.getBoolean(Preferences.vendorIsOpenKey);
      vendorModel.value =
          vendorModel.value.copyWith(isOpen: saved, reststatus: saved);
    } catch (_) {}
  }

  /// Fetches fresh vendor data from Firestore and merges it with local state.
  Future<void> loadVendor() async {
    final vendorId = Constant.userModel?.vendorID;
    if (vendorId == null || vendorId.isEmpty) return;

    _log('loadVendor id=$vendorId');
    try {
      final fresh =
          await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
      if (fresh == null) return;

      Constant.vendorAdminCommission = fresh.adminCommission;
      fresh.id ??= vendorId;

      // Prefer server value; fall back to persisted pref if server omits it.
      final isOpen =
          fresh.isOpen ?? Preferences.getBoolean(Preferences.vendorIsOpenKey);
      fresh
        ..isOpen = isOpen
        ..reststatus = isOpen;

      await Preferences.setBoolean(Preferences.vendorIsOpenKey, isOpen);

      // Persist vendor's zone id so other features (e.g. subscriptions)
      // can resolve it without reloading the vendor every time.
      final zoneId = fresh.zoneId?.toString().trim();
      if (zoneId != null && zoneId.isNotEmpty) {
        await Preferences.setString(VendorModel.zoneIdPrefKey, zoneId);
      }

      vendorModel
        ..value = fresh
        ..refresh();
    } catch (e) {
      _log('loadVendor error: $e');
    }
  }

  /// Public alias kept for callers such as [HomeController.refreshApp].
  Future<void> getVendor() => loadVendor();

  /// Pushes an open/closed status change to Firestore.
  /// Returns `true` on success, `false` on any failure.
  Future<bool> updateRestStatus(bool open) async {
    if (isUpdatingStatus.value) return false;

    final vendorId = Constant.userModel?.vendorID;
    if (vendorId == null || vendorId.isEmpty) {
      _log('updateRestStatus: no vendorId');
      return false;
    }

    isUpdatingStatus.value = true;
    try {
      // Always fetch latest before writing to avoid overwriting concurrent changes.
      final latest =
      await FireStoreUtils.getVendorById(vendorId, forceRefresh: true);
      if (latest == null) return false;

      latest
        ..id ??= vendorId
        ..isOpen = open
        ..reststatus = open;

      final saved = await FireStoreUtils.updateVendor(latest);
      if (saved == null) return false;

      await Preferences.setBoolean(Preferences.vendorIsOpenKey, open);
      vendorModel
        ..value = saved
        ..refresh();
      return true;
    } catch (e) {
      _log('updateRestStatus error: $e');
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  /// Call from [PopScope.onPopInvokedWithResult].
  /// - On a non-root tab → jumps back to tab 0, returns `false`.
  /// - On tab 0, first press → records timestamp, returns `false` (show hint).
  /// - On tab 0, second press within [_exitWindow] → returns `true` (exit).
  bool onBackPressed() {
    if (selectedIndex.value != 0) {
      selectedIndex.value = 0;
      return false;
    }
    final now = DateTime.now();
    final isSecondPress = _lastBackPress != null &&
        now.difference(_lastBackPress!) <= _exitWindow;
    _lastBackPress = now;
    return isSecondPress;
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  void _checkUpdate() {
    try {
      Get.find<AppUpdateController>().checkMandatoryUpdateForLoggedInUser();
    } catch (_) {}
  }

  void _log(String msg) {
    if (AppConfig.enableDebugLogs) debugPrint('DashBoardController.$msg');
  }
}