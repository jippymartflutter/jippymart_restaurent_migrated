import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/constant/collection_name.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> estimatedTimeController =
      TextEditingController().obs;

  RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  RxList<OrderModel> allOrderList = <OrderModel>[].obs;
  RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledOrderList = <OrderModel>[].obs;

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendermodel = VendorModel().obs;

  getUserProfile() async {
    String userId = await FireStoreUtils.getCurrentUid();
    await FireStoreUtils.getUserProfile(userId).then(
      (value) {
        if (value != null) {
          userModel.value = value;
          Constant.userModel = userModel.value;
        }
      },
    );
    if (userModel.value.vendorID != null ||
        userModel.value.vendorID!.isNotEmpty) {
      await FireStoreUtils.getVendorById(userModel.value.vendorID!).then(
        (vender) {
          if (vender?.id != null) {
            vendermodel.value = vender!;
          }
        },
      );
    }
    await getOrder();
    isLoading.value = false;
  }

  RxList<UserModel> driverUserList = <UserModel>[].obs;
  Rx<UserModel> selectDriverUser = UserModel().obs;
  getAllDriverList() async {
    await FireStoreUtils.getAvalibleDrivers().then(
      (value) {
        if (value.isNotEmpty == true) {
          driverUserList.value = value;
        }
      },
    );
    isLoading.value = false;
  }
  // getOrder() async {
  //   print('🔄 Setting up order listener for vendor: ${Constant.userModel?.vendorID}');
  //
  //   FireStoreUtils.fireStore
  //       .collection(CollectionName.restaurantOrders)
  //       .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .listen(
  //         (event) async {
  //       // Clear cache by checking metadata
  //       if (event.metadata.hasPendingWrites) {
  //         print('📝 Local changes detected, skipping...');
  //         return;
  //       }
  //
  //       print('📦 Received ${event.docs.length} orders from Firebase');
  //       allOrderList.clear();
  //
  //       for (var element in event.docs) {
  //         OrderModel orderModel = OrderModel.fromJson(element.data());
  //         orderModel.id = element.id;
  //
  //         // Skip if this is from cache and we want fresh data only
  //         if (element.metadata.isFromCache) {
  //           print('⚡ Skipping cached data');
  //           continue;
  //         }
  //
  //         allOrderList.add(orderModel);
  //         print('📋 Order ${orderModel.id}: Status = "${orderModel.status}"');
  //       }
  //
  //       // Your existing filtering logic...
  //       newOrderList.value = allOrderList
  //           .where((p0) => p0.status == Constant.orderPlaced || p0.status == "pending")
  //           .toList();
  //             acceptedOrderList.value = allOrderList
  //                 .where((p0) =>
  //                     p0.status == Constant.orderAccepted ||
  //                     p0.status == Constant.driverPending ||
  //                     p0.status == Constant.driverRejected ||
  //                     p0.status == Constant.orderShipped ||
  //                     p0.status == Constant.orderInTransit)
  //                 .toList();
  //             completedOrderList.value = allOrderList
  //                 .where((p0) => p0.status == Constant.orderCompleted)
  //                 .toList();
  //             rejectedOrderList.value = allOrderList
  //                 .where((p0) => p0.status == Constant.orderRejected)
  //                 .toList();
  //             cancelledOrderList.value = allOrderList
  //                 .where((p0) => p0.status == Constant.orderCancelled)
  //                 .toList();
  //       update();
  //       if (newOrderList.isNotEmpty == true) {
  //         print('🔔 Playing notification sound for new orders');
  //         await AudioPlayerService.playSound(true);
  //       }
  //     },
  //   );
  // }
  getOrder() async {
    print('🔄 Setting up order listener for vendor: ${Constant.userModel?.vendorID}');
    FireStoreUtils.fireStore
        .collection(CollectionName.restaurantOrders)
        .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (event) async {
        print('📦 Received ${event.docs.length} orders from Firebase');
        allOrderList.clear();

        // First, collect all orders
        for (var element in event.docs) {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          orderModel.id = element.id; // Ensure document ID is set
          allOrderList.add(orderModel);
          print('📋 Order ${orderModel.id}: Status = "${orderModel.status}"');
        }
        // Then filter them into different categories
        newOrderList.value = allOrderList
            .where((p0) => p0.status == Constant.orderPlaced || p0.status == "pending")
            .toList();
        log(newOrderList.length.toString(),name: "  resturantopen ");
        acceptedOrderList.value = allOrderList
            .where((p0) =>
                p0.status == Constant.orderAccepted ||
                p0.status == Constant.driverPending ||
                p0.status == Constant.driverRejected ||
                p0.status == Constant.orderShipped ||
                p0.status == Constant.orderInTransit)
            .toList();
        completedOrderList.value = allOrderList
            .where((p0) => p0.status == Constant.orderCompleted)
            .toList();
        rejectedOrderList.value = allOrderList
            .where((p0) => p0.status == Constant.orderRejected)
            .toList();
        cancelledOrderList.value = allOrderList
            .where((p0) => p0.status == Constant.orderCancelled)
            .toList();
        print('✅ Filtered orders - New: ${newOrderList.length}, Accepted: ${acceptedOrderList.length}, Completed: ${completedOrderList.length}, Rejected: ${rejectedOrderList.length}, Cancelled: ${cancelledOrderList.length}');
        update();
        if (newOrderList.isNotEmpty == true) {
          print('🔔 Playing notification sound for new orders');
          await AudioPlayerService.playSound(true);
        }
      },
    );
  }

  // Refresh method for pull-to-refresh functionality
  Future<void> refreshApp() async {
    isLoading.value = true;
    await getUserProfile();

    // Also refresh the dashboard controller's vendor data to update restaurant status
    try {
      DashBoardController dashBoardController = Get.find<DashBoardController>();
      await dashBoardController.getVendor();
    } catch (e) {
      // If dashboard controller is not found, ignore the error
      print('Dashboard controller not found: $e');
    }

    isLoading.value = false;
  }
}
