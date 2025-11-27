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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
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
    if (userModel.value.vendorID != null ) {
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


  Future<void> getOrder() async {
    String? url = '${Constant.baseUrl}orders/vendor/${Constant.userModel?.vendorID}';
    print('🔄 Fetching orders for vendor: ${Constant.userModel?.vendorID}');

    print('getOrder : ${url}');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      log('getOrder : ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          List<OrderModel> allOrderTemp = [];
          int successCount = 0;
          int errorCount = 0;
          for (var element in jsonResponse['data']) {
            try {
              print('🔄 Processing order: ${element['id']}');
              OrderModel orderModel = OrderModel.fromJson(element);
              orderModel.id = element['id']; // Ensure ID is set
              allOrderTemp.add(orderModel);
              successCount++;
              print('✅ Successfully processed order ${orderModel.id}: Status = "${orderModel.status}"');
            } catch (e, stackTrace) {
              errorCount++;
              print('❌ Error parsing order ${element['id']}: $e');
              print('Stack trace: $stackTrace');
              print('Problematic order data: $element');
              // Continue with other orders even if one fails
            }
          }

          print('📊 Order processing summary: $successCount successful, $errorCount failed');

          // Update reactive lists only if we have successful orders
          if (successCount > 0) {
            allOrderList.clear();
            allOrderList.addAll(allOrderTemp);

            newOrderList.value = allOrderList
                .where((p0) => p0.status == Constant.orderPlaced || p0.status?.toLowerCase() == "pending")
                .toList();

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
            if (newOrderList.isNotEmpty) {
              print('🔔 Playing notification sound for new orders');
              await AudioPlayerService.playSound(true);
            }
          } else {
            print('⚠️ No orders were successfully processed');
          }
        } else {
          print('⚠️ API returned success=false');
        }
      } else {
        print('❌ Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching orders: $e');
      print('Stack trace: $stackTrace');
    }
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
