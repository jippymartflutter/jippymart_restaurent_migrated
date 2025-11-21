import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/Home_screen/home_screen.dart';
import 'package:jippymart_restaurant/app/dine_in_order_screen/dine_in_order_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/product_list_screen.dart';
import 'package:jippymart_restaurant/app/profile_screen/profile_screen.dart';
import 'package:jippymart_restaurant/app/wallet_screen/wallet_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxList<Widget> pageList = <Widget>[].obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getVendor();
    setPage();
    super.onInit();
  }

  setPage() {
    pageList.value = Constant.isDineInEnable &&
            Constant.userModel?.subscriptionPlan?.features?.dineIn != false
        ? [
            const HomeScreen(),
            const DineInOrderScreen(),
            const ProductListScreen(),
    //  const WalletScreen(),
            const ProfileScreen(),
          ]
        : [
            const HomeScreen(),
            const ProductListScreen(),
      //const WalletScreen(),
            const ProfileScreen(),
          ];
  }

  getVendor() async {
    if (Constant.userModel?.vendorID != null) {
      await FireStoreUtils.getVendorById(
              Constant.userModel!.vendorID.toString())
          .then(
        (value) {
          if (value != null) {
            Constant.vendorAdminCommission = value.adminCommission;
            vendorModel.value = value;
            // Ensure reststatus and isOpen are synchronized
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
