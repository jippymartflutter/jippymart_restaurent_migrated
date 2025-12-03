import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isFetchingOrders = false.obs;

  Rx<TextEditingController> estimatedTimeController =
      TextEditingController().obs;

  RxInt selectedTabIndex = 0.obs;

  Timer? _orderPollingTimer;
  bool _isPollingActive = false;
  int _previousNewOrderCount = 0;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  @override
  void onClose() {
    _orderPollingTimer?.cancel();
    _orderPollingTimer = null;
    _isPollingActive = false;
    estimatedTimeController.value.dispose();
    super.onClose();
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
    try {
      String userId = await FireStoreUtils.getCurrentUid();
      if (userId.isEmpty) {
        print("⚠️ getUserProfile: User ID is empty, cannot fetch profile");
        isLoading.value = false;
        return;
      }
      await FireStoreUtils.getUserProfile(userId).then(
        (value) {
          if (value != null) {
            userModel.value = value;
            Constant.userModel = userModel.value;
            // Only proceed if we have a valid user model with vendor ID
            if (userModel.value.vendorID != null && userModel.value.vendorID!.isNotEmpty) {
              FireStoreUtils.getVendorById(userModel.value.vendorID!).then(
                (vender) {
                  if (vender?.id != null) {
                    vendermodel.value = vender!;
                  }
                },
              ).catchError((error) {
                print("⚠️ Error fetching vendor: $error");
              });
              // Start fetching orders and polling once vendor ID is available
              getOrder().catchError((error) {
                print("⚠️ Error fetching orders: $error");
              });
              _startOrderPolling();
            }
          } else {
            print("⚠️ getUserProfile: User profile not found (404 or null response)");
          }
        },
      ).catchError((error) {
        print("⚠️ Error in getUserProfile: $error");
      });
    } catch (e) {
      print("⚠️ Exception in getUserProfile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Start periodic polling for orders
  void _startOrderPolling() {
    if (_isPollingActive) return;
    
    _isPollingActive = true;
    // Poll every 10 seconds for new orders
    _orderPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isPollingActive || Constant.userModel?.vendorID == null) {
        timer.cancel();
        return;
      }
      // Only poll if not currently fetching to avoid overlapping requests
      if (!isFetchingOrders.value) {
        getOrder(silent: true);
      }
    });
    print('🔄 Started order polling (every 10 seconds)');
  }

  // Stop polling (useful when app goes to background)
  void stopOrderPolling() {
    _isPollingActive = false;
    _orderPollingTimer?.cancel();
    _orderPollingTimer = null;
    print('⏹️ Stopped order polling');
  }

  // Resume polling
  void resumeOrderPolling() {
    if (Constant.userModel?.vendorID != null && !_isPollingActive) {
      _startOrderPolling();
    }
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


  Future<void> getOrder({bool silent = false}) async {
    // Prevent multiple simultaneous requests
    if (isFetchingOrders.value && silent) {
      return;
    }
    if (Constant.userModel?.vendorID == null || Constant.userModel!.vendorID!.isEmpty) {
      print('⚠️ Vendor ID not available, skipping order fetch');
      return;
    }
    String? url = '${Constant.baseUrl}orders/vendor/${Constant.userModel?.vendorID}';
    print("getOrdergetOrder ${url}");
    if (!silent) {
      print('🔄 Fetching orders for vendor: ${Constant.userModel?.vendorID}');
    }
    isFetchingOrders.value = true;
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Order fetch request timed out');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          List<OrderModel> allOrderTemp = [];
          int successCount = 0;
          int errorCount = 0;
          
          for (var element in jsonResponse['data']) {
            try {
              OrderModel orderModel = OrderModel.fromJson(element);
              orderModel.id = element['id']; // Ensure ID is set
              allOrderTemp.add(orderModel);
              successCount++;
            } catch (e) {
              errorCount++;
              if (!silent) {
                print('❌ Error parsing order ${element['id']}: $e');
              }
            }
          }

          if (!silent) {
            print('📊 Order processing summary: $successCount successful, $errorCount failed');
          }

          // Store previous count before updating to detect new orders
          int previousNewOrderCount = _previousNewOrderCount;
          
          // Update reactive lists
          allOrderList.clear();
          allOrderList.addAll(allOrderTemp);

          newOrderList.value = allOrderList
              .where((p0) => p0.status == Constant.orderPlaced || 
                      p0.status?.toLowerCase() == "pending")
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

          if (!silent) {
            print('✅ Filtered orders - New: ${newOrderList.length}, Accepted: ${acceptedOrderList.length}, Completed: ${completedOrderList.length}, Rejected: ${rejectedOrderList.length}, Cancelled: ${cancelledOrderList.length}');
          }

          update();

          // Detect and notify about new orders
          if (newOrderList.length > previousNewOrderCount && previousNewOrderCount > 0) {
            int newOrdersCount = newOrderList.length - previousNewOrderCount;
            print('🔔 $newOrdersCount new order(s) detected!');
            await AudioPlayerService.playSound(true);
          } else if (newOrderList.isNotEmpty && previousNewOrderCount == 0 && !silent) {
            // First time loading with new orders
            print('🔔 Initial load: ${newOrderList.length} new order(s) found');
            await AudioPlayerService.playSound(true);
          }
          // Update previous count for next comparison
          _previousNewOrderCount = newOrderList.length;
        } else {
          if (!silent) {
            print('⚠️ API returned success=false: ${jsonResponse['message'] ?? 'Unknown error'}');
          }
        }
      } else {
        if (!silent) {
          print('❌ Failed to fetch orders: ${response.statusCode}');
        }
      }
    } on TimeoutException catch (e) {
      if (!silent) {
        print('⏱️ Order fetch timeout: $e');
      }
    } catch (e, stackTrace) {
      if (!silent) {
        print('❌ Error fetching orders: $e');
        print('Stack trace: $stackTrace');
      }
    } finally {
      isFetchingOrders.value = false;
    }
  }


  // Refresh method for pull-to-refresh functionality
  Future<void> refreshApp() async {
    isLoading.value = true;
    
    // Fetch orders immediately without waiting for full profile reload
    if (Constant.userModel?.vendorID != null) {
      await getOrder(silent: false);
    }
    
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
