import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/Home_screen/home_screen.dart';
import 'package:jippymart_restaurant/app/dine_in_order_screen/dine_in_order_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/product_list_screen.dart';
import 'package:jippymart_restaurant/app/profile_screen/profile_screen.dart';
import 'package:jippymart_restaurant/app/wallet_screen/wallet_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/app_update_controller.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';

class DashBoardController extends GetxController with WidgetsBindingObserver {
  RxInt selectedIndex = 0.obs;
  RxList<Widget> pageList = <Widget>[].obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getVendor();
    setPage();
    _checkMandatoryUpdate();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkMandatoryUpdate();
  }

  void _checkMandatoryUpdate() {
    try {
      final appUpdate = Get.find<AppUpdateController>();
      appUpdate.checkMandatoryUpdateForLoggedInUser();
    } catch (_) {}
  }

  setPage() {
    pageList.value =
    // = Constant.isDineInEnable &&
    //         Constant.userModel?.subscriptionPlan?.features?.dineIn != false
    //     ? [
    //         const HomeScreen(),
    //         const DineInOrderScreen(),
    //         const ProductListScreen(),
    // //  const WalletScreen(),
    //         const ProfileScreen(),
    //       ]
    //     :
    [
            const HomeScreen(),
            const ProductListScreen(),
            const ProfileScreen(),
          ];
  }

  getVendor() async {
    print("getVendorgetVendor  ${Constant.userModel?.vendorID.toString()??''}");
    if (Constant.userModel?.vendorID != null) {
      await FireStoreUtils.getVendorById(
              Constant.userModel?.vendorID.toString()??'')
          .then(
        (value) {
          if (value != null) {
            Constant.vendorAdminCommission = value.adminCommission;
            vendorModel.value = value;
            if (value.isOpen != null && value.reststatus != value.isOpen) {
              value.reststatus = value.isOpen;
            }
          }
        },
      );
    }
  }
  Future<void> updateRestStatus(bool status) async {
    vendorModel.value.reststatus = status;
    vendorModel.value.isOpen = status; // Ensure isOpen is updated
    await FireStoreUtils.updateVendor(vendorModel.value);
    vendorModel.refresh();
  }
  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
}
