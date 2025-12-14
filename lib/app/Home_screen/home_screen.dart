import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bottom_picker/resources/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/const/image_const.dart';
import 'package:jippymart_restaurant/utils/const/text_style_const.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:jippymart_restaurant/app/chat_screens/chat_screen.dart';
import 'package:jippymart_restaurant/app/chat_screens/restaurant_inbox_screen.dart';
import 'package:jippymart_restaurant/app/product_rating_view_screen/product_rating_view_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/send_notification.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/models/cart_product_model.dart';
import 'package:jippymart_restaurant/models/order_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/models/wallet_transaction_model.dart';
import 'package:jippymart_restaurant/service/audio_player_service.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/widget/my_separator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import '../../themes/round_button_fill.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late HomeController controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Get.isRegistered<HomeController>()) {
      controller = Get.find<HomeController>();
      controller.resumeOrderPolling();
    } else {
      controller = Get.put(HomeController());
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Resume polling when app comes to foreground
      controller.resumeOrderPolling();
      // Refresh orders when app comes back
      controller.getOrder(silent: false);
    } else if (state == AppLifecycleState.paused) {
      // Optional: Stop polling when app goes to background to save resources
      // controller.stopOrderPolling();
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: controller,
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader()
              : DefaultTabController(
                  length: 5,
                  child: Scaffold(
                    appBar: AppBar(
                      backgroundColor:ColorConst.orange,
                      // AppThemeData.secondary300,
                      centerTitle: false,
                      title: Row(
                        children: [
                          InkWell(
                            // onTap:()
                            // {
                            //   DashBoardController dashBoardController =
                            //       Get.find<DashBoardController>();
                            //   if (Constant.isDineInEnable &&
                            //       Constant.userModel!.subscriptionPlan?.features
                            //               ?.dineIn !=
                            //           false) {
                            //     dashBoardController.selectedIndex.value = 4;
                            //   } else {
                            //     dashBoardController.selectedIndex.value = 3;
                            //   }
                            // },
                            child: ClipOval(
                              child: NetworkImageWidget(
                                imageUrl: controller
                                    .userModel.value.profilePictureURL
                                    .toString(),
                                height: 42,
                                width: 42,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 270,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Welcome to ".tr,
                                        style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey50,
                                          fontSize: 13,
                                          fontFamily: AppThemeData.medium,
                                        ),
                                      ),
                                      TextSpan(
                                        text: controller.vendermodel.value.title ?? 'Restaurant',
                                        style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey50,
                                          fontSize: 18, // Adjustable size for restaurant name
                                          fontFamily: AppThemeData.bold,
                                        ),
                                      ),
                                    ],
                                  ),maxLines: 1,
                                ),
                              ),
                              Text(
                                "${controller.userModel.value.fullName()}".tr,
                                style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey50,
                                    fontSize: 16,
                                    fontFamily: AppThemeData.semiBold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      bottom: TabBar(
                        onTap: (value) {
                          controller.selectedTabIndex.value = value;
                        },
                        tabAlignment: TabAlignment.start,
                        labelStyle:
                            const TextStyle(fontFamily: AppThemeData.semiBold),
                        labelColor: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey50,
                        unselectedLabelStyle:
                            const TextStyle(fontFamily: AppThemeData.medium),
                        unselectedLabelColor: Color(0xFFD5DBDB),
                        indicatorColor: AppThemeData.secondary300,
                        isScrollable: true,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(
                            text: "New".tr,
                          ),
                          Tab(
                            text: "Accepted".tr,
                          ),
                          Tab(
                            text: "Completed".tr,
                          ),
                          Tab(
                            text: "Rejected".tr,
                          ),
                          Tab(
                            text: "Cancelled".tr,
                          ),
                        ],
                      ),
                      actions: [
                        Visibility(
                          // visible: controller.userModel.value.subscriptionPlan
                          //         ?.features?.chat !=
                          //     false,
                          visible: false,
                          child: InkWell(
                            onTap: () async {
                              Get.to(const RestaurantInboxScreen());
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: SvgPicture.asset(
                                "assets/icons/ic_chat.svg",
                                color: themeChange.getThem()
                                    ? AppThemeData.grey900
                                    : AppThemeData.grey50,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    body: Constant.isRestaurantVerification == true &&
                            controller.userModel.value.isDocumentVerify == false
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey700
                                        : AppThemeData.grey200,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(120),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: SvgPicture.asset(
                                        "assets/icons/ic_document.svg"),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Text(
                                  "Document Verification in Pending".tr,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey100
                                          : AppThemeData.grey800,
                                      fontSize: 22,
                                      fontFamily: AppThemeData.semiBold),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Your documents are being reviewed. We will notify you once the verification is complete."
                                      .tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey500,
                                      fontSize: 16,
                                      fontFamily: AppThemeData.bold),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                RoundedButtonFill(
                                  title: "View Status".tr,
                                  width: 55,
                                  height: 5.5,
                                  color: AppThemeData.secondary300,
                                  textColor: AppThemeData.grey50,
                                  onPress: () async {
                                    Get.to(const VerificationScreen());
                                  },
                                ),
                              ],
                            ),
                          )
                        : controller.userModel.value.vendorID == null ||
                                controller.userModel.value.vendorID!.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey700
                                            : AppThemeData.grey200,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(120),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: SvgPicture.asset(
                                            "assets/icons/ic_building_two.svg"),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Text(
                                      "Add Your First Restaurant".tr,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey100
                                              : AppThemeData.grey800,
                                          fontSize: 22,
                                          fontFamily: AppThemeData.semiBold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Get started by adding your restaurant details to manage your menu, orders, and reservations."
                                          .tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey500,
                                          fontSize: 16,
                                          fontFamily: AppThemeData.bold),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    RoundedButtonFill(
                                      title: "Add Restaurant".tr,
                                      width: 55,
                                      height: 5.5,
                                      color: AppThemeData.secondary300,
                                      textColor: AppThemeData.grey50,
                                      onPress: () async {
                                        Get.to(const AddRestaurantScreen())
                                            ?.then((v) {
                                          if (v == true) {
                                            controller.getUserProfile();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                child: TabBarView(
                                  children: [
                                    RefreshIndicator(
                                      onRefresh: () async {
                                        await controller.refreshApp();
                                      },
                                      child: controller.newOrderList.isEmpty
                                          ? SingleChildScrollView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                child: Constant.showEmptyView(
                                                    message: "New Orders Not found".tr),
                                              ),
                                            )
                                          : ListView.builder(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount:
                                                  controller.newOrderList.length,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = controller
                                                    .newOrderList[index];
                                                return newOrderWidget(
                                                    themeChange,
                                                    context,
                                                    orderModel,
                                                    controller);
                                              },
                                            ),
                                    ),
                                    RefreshIndicator(
                                      onRefresh: () async {
                                        await controller.refreshApp();
                                      },
                                      child: controller.acceptedOrderList.isEmpty
                                          ? SingleChildScrollView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                child: Constant.showEmptyView(
                                                    message: "Accepted Orders Not found".tr),
                                              ),
                                            )
                                          : ListView.builder(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: controller
                                                  .acceptedOrderList.length,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = controller
                                                    .acceptedOrderList[index];
                                                return acceptedWidget(
                                                    themeChange,
                                                    context,
                                                    orderModel,
                                                    controller);
                                              },
                                            ),
                                    ),
                                    RefreshIndicator(
                                      onRefresh: () async {
                                        await controller.refreshApp();
                                      },
                                      child: controller.completedOrderList.isEmpty
                                          ? SingleChildScrollView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                child: Constant.showEmptyView(
                                                    message: "Completed Orders Not found".tr),
                                              ),
                                            )
                                          : ListView.builder(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: controller
                                                  .completedOrderList.length,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = controller
                                                    .completedOrderList[index];
                                                return completedAndRejectedWidget(
                                                    themeChange,
                                                    context,
                                                    orderModel,
                                                    controller);
                                              },
                                            ),
                                    ),
                                    RefreshIndicator(
                                      onRefresh: () async {
                                        await controller.refreshApp();
                                      },
                                      child: controller.rejectedOrderList.isEmpty
                                          ? SingleChildScrollView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                child: Constant.showEmptyView(
                                                    message: "Rejected Orders Not found".tr),
                                              ),
                                            )
                                          : ListView.builder(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: controller
                                                  .rejectedOrderList.length,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = controller
                                                    .rejectedOrderList[index];
                                                return completedAndRejectedWidget(
                                                    themeChange,
                                                    context,
                                                    orderModel,
                                                    controller
                                                  ,);
                                              },
                                            ),
                                    ),
                                    RefreshIndicator(
                                      onRefresh: () async {
                                        await controller.refreshApp();
                                      },
                                      child: controller.cancelledOrderList.isEmpty
                                          ? SingleChildScrollView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height: MediaQuery.of(context).size.height * 0.6,
                                                child: Constant.showEmptyView(
                                                    message: "Cancelled Orders Not found".tr),
                                              ),
                                            )
                                          : ListView.builder(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: controller
                                                  .cancelledOrderList.length,
                                              itemBuilder: (context, index) {
                                                OrderModel orderModel = controller
                                                    .cancelledOrderList[index];
                                                return completedAndRejectedWidget(
                                                    themeChange,
                                                    context,
                                                    orderModel,
                                                    controller);
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
                    floatingActionButton:GestureDetector(
                      onTap: () async {
                        const String phoneNumber = '+916301931498';
                        const String message =
                            "I'm interested to upgrade my plan to premium services";
                        final Uri whatsappUrl = Uri.parse(
                            'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
                        try {
                          if (await canLaunchUrl(whatsappUrl)) {
                            await launchUrl(whatsappUrl,
                                mode: LaunchMode.externalApplication);
                          } else {
                            final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
                            if (await canLaunchUrl(phoneUrl)) {
                              await launchUrl(phoneUrl,
                                  mode: LaunchMode.externalApplication);
                            }
                          }
                        } catch (e) {
                          debugPrint('Error launching WhatsApp: $e');
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.all(20),padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorConst.lightBlue,borderRadius: BorderRadius.circular(40),
                        ),
                        height: 70,
                        width: double.infinity,
                        child: Row(children: [
                          SizedBox(width: 10,),
                          GestureDetector(
                            onTap: () async {
                              const String phoneNumber = '+916301931498';
                              const String message =
                                  "I'm interested to upgrade my plan to premium services";
                              final Uri whatsappUrl = Uri.parse(
                                  'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
                              try {
                                if (await canLaunchUrl(whatsappUrl)) {
                                  await launchUrl(whatsappUrl,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  final Uri phoneUrl = Uri.parse('tel:$phoneNumber');
                                  if (await canLaunchUrl(phoneUrl)) {
                                    await launchUrl(phoneUrl,
                                        mode: LaunchMode.externalApplication);
                                  }
                                }
                              } catch (e) {
                                debugPrint('Error launching WhatsApp: $e');
                              }
                            },
                            child: SvgPicture.asset(
                              ImageConst.whatsApp,
                            ),
                          ),
                          SizedBox(width: 10,),
                          SizedBox(
                            width: 240,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyleConst.blackMedium15,
                                children: [
                                  const TextSpan(
                                    text: "Upgrade to our ₹499 or ₹999 Plan and unlock  ",
                                  ),
                                  TextSpan(
                                    text: "premium features",
                                    style: TextStyleConst.blueMedium15,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],),
                      ),
                    ),
                  ),
                );
        });
  }

  newOrderWidget(themeChange, BuildContext context, OrderModel orderModel,
      HomeController controller) {
    // ignore: unused_local_variable
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double taxAmount = 0.0;
    double specialDiscount = 0.0;
    double adminCommission = 0.0;
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
    totalAmount = subTotal -
        double.parse(orderModel.discount.toString()) -
        specialDiscount +
        taxAmount;
    if (orderModel.adminCommissionType == 'Percent') {
      double basePrice =
          subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = double.parse(orderModel.adminCommission!);
    }

    return InkWell(
      //
      onTap: () {}, // disables tap on the card
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: themeChange.getThem()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: NetworkImageWidget(
                        imageUrl:
                            orderModel.author!.profilePictureURL.toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderModel.author!.fullName().toString().tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          orderModel.takeAway == true
                              ? Text(
                                  "Take Away".tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                )
                              : Text(
                                  orderModel.address!.getFullAddress().tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MySeparator(
                      color: themeChange.getThem()
                          ? AppThemeData.grey700
                          : AppThemeData.grey200),
                ),

                //change section
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: orderModel.products!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CartProductModel product = orderModel.products![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${product.quantity}x ${product.name}".tr,
                                style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  double.parse(product.discountPrice ?? "0.0") <= 0
                                      ? Constant.amountShow(
                                          amount:
                                              (double.parse(product.price.toString()) *
                                                      double.parse(product
                                                          .quantity
                                                          .toString()))
                                                  .toString())
                                      : Constant.amountShow(
                                              amount: (double.parse(product
                                                          .discountPrice
                                                          .toString()) *
                                                      double.parse(product
                                                          .quantity
                                                          .toString()))
                                                  .toString())
                                          .tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey100
                                        : AppThemeData.grey800,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppThemeData.semiBold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.to(const ProductRatingViewScreen(),
                                        arguments: {
                                          "orderModel": orderModel,
                                          "productId": product.id
                                        });
                                  },
                                  child: Text(
                                    "View Ratings".tr,
                                    style: TextStyle(
                                      color: themeChange.getThem()
                                          ? AppThemeData.secondary300
                                          : AppThemeData.secondary300,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      fontFamily: AppThemeData.semiBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        product.variantInfo == null ||
                                product.variantInfo!.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Variants".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300
                                            : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: List.generate(
                                        product.variantInfo!.variantOptions!
                                            .length,
                                        (i) {
                                          return Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey800
                                                  : AppThemeData.grey100,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 5),
                                              child: Text(
                                                "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey500
                                                      : AppThemeData.grey400,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                        product.extras == null || product.extras!.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Addons".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey300
                                                : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(
                                            amount: (double.parse(product
                                                        .extrasPrice
                                                        .toString()) *
                                                    double.parse(product
                                                        .quantity
                                                        .toString()))
                                                .toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem()
                                              ? AppThemeData.secondary300
                                              : AppThemeData.secondary300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      product.extras!.length,
                                      (i) {
                                        return Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey800
                                                : AppThemeData.grey100,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 5),
                                            child: Text(
                                              product.extras![i].toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey500
                                                    : AppThemeData.grey400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: MySeparator(
                          color: themeChange.getThem()
                              ? AppThemeData.grey700
                              : AppThemeData.grey200),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Order Date".tr,
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    Text(
                      Constant.timestampToDateTime(orderModel.createdAt!),
                      style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: Text(
                //         "Total Amount".tr,
                //         style: TextStyle(
                //           color: themeChange.getThem()
                //               ? AppThemeData.grey300
                //               : AppThemeData.grey600,
                //           fontSize: 16,
                //           fontWeight: FontWeight.w400,
                //           fontFamily: AppThemeData.regular,
                //         ),
                //       ),
                //     ),
                //     Text(
                //       Constant.amountShow(amount: totalAmount.toString()).tr,
                //       style: TextStyle(
                //         color: themeChange.getThem()
                //             ? AppThemeData.grey100
                //             : AppThemeData.grey800,
                //         fontSize: 16,
                //         fontWeight: FontWeight.w500,
                //         fontFamily: AppThemeData.semiBold,
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox.shrink(),
                Visibility(
                  visible: Constant.adminCommission?.isEnabled == true,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Admin Commissions".tr,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: adminCommission.toString())}"
                                .tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.danger300
                                  : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // orderModel.scheduleTime == null
                //     ? const SizedBox()
                //     : Row(
                //         children: [
                //           Expanded(
                //             child: Text(
                //               "Schedule Time".tr,
                //               style: TextStyle(
                //                 color: themeChange.getThem()
                //                     ? AppThemeData.grey300
                //                     : AppThemeData.grey600,
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w400,
                //                 fontFamily: AppThemeData.regular,
                //               ),
                //             ),
                //           ),
                //           Text(
                //             Constant.timestampToDateTime(
                //                     orderModel.scheduleTime!)
                //                 .tr,
                //             style: TextStyle(
                //               color: themeChange.getThem()
                //                   ? AppThemeData.secondary300
                //                   : AppThemeData.secondary300,
                //               fontSize: 16,
                //               fontWeight: FontWeight.w500,
                //               fontFamily: AppThemeData.semiBold,
                //             ),
                //           ),
                //         ],
                //       ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.notes == null || orderModel.notes!.isEmpty
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return viewRemarkDialog(
                                  controller, themeChange, orderModel);
                            },
                          );
                        },
                        child: Text(
                          "View Remarks".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            decoration: TextDecoration.underline,
                            color: themeChange.getThem()
                                ? AppThemeData.secondary300
                                : AppThemeData.secondary300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Reject".tr,
                          color: AppThemeData.new_primary,
                          textColor: AppThemeData.grey50,
                          height: 5,
                          onPress: () async {
                            ShowToastDialog.showLoader('Please wait...'.tr);
                            await AudioPlayerService.playSound(false);
                            orderModel.status = Constant.orderRejected;
                            await FireStoreUtils.updateOrder(orderModel);
                            print("Rejecttr ${  orderModel.author?.fcmToken.toString()}   ${orderModel.toJson()}");
                            if (orderModel.author?.fcmToken != null &&
                                orderModel.author!.fcmToken!.isNotEmpty) {
                              SendNotification.sendFcmMessage(
                                Constant.restaurantRejected,
                                orderModel.author?.fcmToken.toString() ??'',
                                {
                                  'orderId': orderModel.id ?? '',
                                  'status': Constant.orderRejected,
                                },
                              );
                            }
                            if (orderModel.paymentMethod!.toLowerCase() !=
                                'cod') {
                              double finalAmount = (subTotal +
                                      double.parse(
                                          orderModel.discount.toString()) +
                                      specialDiscount +
                                      double.parse(taxAmount.toString())) +
                                  double.parse(
                                      orderModel.deliveryCharge.toString()) +
                                  double.parse(orderModel.tipAmount.toString());
                              WalletTransactionModel historyModel =
                                  WalletTransactionModel(
                                      amount: finalAmount,
                                      id: const Uuid().v4(),
                                      orderId: orderModel.id,
                                      userId: orderModel.author!.id,
                                      date: Timestamp.now(),
                                      isTopup: true,
                                      paymentMethod: "Wallet",
                                      paymentStatus: "success",
                                      note: "Order Refund success",
                                      transactionUser: "user");
                              await FireStoreUtils.setWalletTransaction(historyModel);
                              // await FireStoreUtils.fireStore
                              //     .collection(CollectionName.wallet)
                              //     .doc(historyModel.id)
                              //     .set(historyModel.toJson());
                              await FireStoreUtils.updateUserWallet(
                                  amount: finalAmount.toString(),
                                  userId: orderModel.author?.firebaseId.toString()??''
                              );
                            }

                            ShowToastDialog.closeLoader();
                            controller.getOrder();
                            Get.back();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Constant.isSelfDeliveryFeature == true &&
                                  controller.vendermodel.value.isSelfDelivery ==
                                      true &&
                                  orderModel.takeAway == false
                              ? RoundedButtonFill(
                                  title: "Self Delivery".tr,
                                  height: 5,
                                  color: AppThemeData.success400,
                                  textColor: AppThemeData.grey50,
                                  onPress: () async {
                                    if ((Constant.isSubscriptionModelApplied ==
                                                true ||
                                            Constant.adminCommission
                                                    ?.isEnabled ==
                                                true) &&
                                        controller.vendermodel.value
                                                .subscriptionPlan !=
                                            null) {
                                      if (controller.vendermodel.value
                                                  .subscriptionTotalOrders ==
                                              '0' ||
                                          controller.vendermodel.value
                                                  .subscriptionTotalOrders ==
                                              null) {
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast(
                                            "You have reached the maximum order capacity for your current plan. Upgrade your subscription to continue accepting orders seamlessly!."
                                                .tr);
                                        return;
                                      }
                                    }

                                    if (orderModel.scheduleTime != null) {
                                      if (DateTime.now().isAtSameMomentOrAfter(
                                          Constant.checkScheduleTime(
                                              scheduleDate: orderModel
                                                  .scheduleTime!
                                                  .toDate()))) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return estimatedTimeDialog(
                                                controller,
                                                themeChange,
                                                orderModel,
                                                context);
                                          },
                                        );
                                      } else {
                                        ShowToastDialog.showToast(
                                            "${"You can accept order on".tr} ${Constant.timestampToDateTime(Timestamp.fromDate(Constant.checkScheduleTime(scheduleDate: orderModel.scheduleTime!.toDate())))}.");
                                      }
                                    } else {
                                      controller.driverUserList.clear();
                                      controller.selectDriverUser.value =
                                          UserModel();

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return estimatedTimeDialog(controller,
                                              themeChange, orderModel, context);
                                        },
                                      );
                                    }
                                  },
                                )
                              : RoundedButtonFill(
                                  title: "Accept".tr,
                                  height: 5,
                                  color: AppThemeData.new_green_tog,
                                  textColor: AppThemeData.grey50,
                                  onPress: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return estimatedTimeDialog(controller,
                                              themeChange, orderModel, context);
                                        },
                                      );
                                    // }
                                  },
                                ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  acceptedWidget(themeChange, BuildContext context, OrderModel orderModel,
      HomeController controller) {
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double taxAmount = 0.0;
    double specialDiscount = 0.0;
    double adminCommission = 0.0;
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

    totalAmount = subTotal -
        double.parse(orderModel.discount.toString()) -
        specialDiscount +
        taxAmount;

    if (orderModel.adminCommissionType == 'Percent') {
      double basePrice =
          subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = double.parse(orderModel.adminCommission!);
    }
print("acceptedWidget ${orderModel.vendorID}");
    return InkWell(
      // onTap: () async {
      //   Get.to(const OrderDetailsScreen(),
      //       arguments: {"orderModel": orderModel});
      // },
      onTap: () {}, // disables tap on the card
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: themeChange.getThem()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: NetworkImageWidget(
                        imageUrl:
                            orderModel.author?.profilePictureURL.toString() ?? '',
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderModel.author?.fullName().toString().tr ??'',
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          orderModel.takeAway == true
                              ? Text(
                                  "Take Away".tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                )
                              : Text(
                                  orderModel.address!.getFullAddress().tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MySeparator(
                      color: themeChange.getThem()
                          ? AppThemeData.grey700
                          : AppThemeData.grey200),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderModel.products!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CartProductModel product = orderModel.products![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${product.quantity}x ${product.name}".tr,
                                style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Text(
                              double.parse(product.discountPrice ?? "0.0") <= 0
                                  ? Constant.amountShow(
                                      amount: (double.parse(
                                                  product.price.toString()) *
                                              double.parse(
                                                  product.quantity.toString()))
                                          .toString())
                                  : Constant.amountShow(
                                          amount: (double.parse(product
                                                      .discountPrice
                                                      .toString()) *
                                                  double.parse(product.quantity
                                                      .toString()))
                                              .toString())
                                      .tr,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppThemeData.semiBold,
                              ),
                            ),
                          ],
                        ),
                        product.variantInfo == null ||
                                product.variantInfo!.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Variants".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300
                                            : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: List.generate(
                                        product.variantInfo!.variantOptions!
                                            .length,
                                        (i) {
                                          return Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey800
                                                  : AppThemeData.grey100,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 5),
                                              child: Text(
                                                "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey500
                                                      : AppThemeData.grey400,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                        product.extras == null || product.extras!.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Addons".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey300
                                                : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(
                                            amount: (double.parse(product
                                                        .extrasPrice
                                                        .toString()) *
                                                    double.parse(product
                                                        .quantity
                                                        .toString()))
                                                .toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem()
                                              ? AppThemeData.secondary300
                                              : AppThemeData.secondary300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      product.extras!.length,
                                      (i) {
                                        return Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey800
                                                : AppThemeData.grey100,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 5),
                                            child: Text(
                                              product.extras![i].toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey500
                                                    : AppThemeData.grey400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Order Date".tr,
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    // Text(
                    //   orderModel.id.toString(),
                    //   style: TextStyle(
                    //     color: themeChange.getThem()
                    //         ? AppThemeData.grey100
                    //         : AppThemeData.grey800,
                    //     fontSize: 14,
                    //     fontWeight: FontWeight.w500,
                    //     fontFamily: AppThemeData.semiBold,
                    //   ),
                    // ),
                    Text(
                      Constant.timestampToDateTime(orderModel.createdAt??''),
                      style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox.shrink(),
                Visibility(
                  visible: Constant.adminCommission?.isEnabled == true,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Admin Commissions".tr,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: adminCommission.toString())}"
                                .tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.danger300
                                  : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // orderModel.scheduleTime == null
                //     ? const SizedBox()
                //     : Row(
                //         children: [
                //           Expanded(
                //             child: Text(
                //               "Schedule Time".tr,
                //               style: TextStyle(
                //                 color: themeChange.getThem()
                //                     ? AppThemeData.grey300
                //                     : AppThemeData.grey600,
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w400,
                //                 fontFamily: AppThemeData.regular,
                //               ),
                //             ),
                //           ),
                //           Text(
                //             Constant.timestampToDateTime(
                //                     orderModel.scheduleTime!)
                //                 .tr,
                //             style: TextStyle(
                //               color: themeChange.getThem()
                //                   ? AppThemeData.secondary300
                //                   : AppThemeData.secondary300,
                //               fontSize: 16,
                //               fontWeight: FontWeight.w500,
                //               fontFamily: AppThemeData.semiBold,
                //             ),
                //           ),
                //         ],
                //       ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.notes == null || orderModel.notes!.isEmpty
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return viewRemarkDialog(
                                  controller, themeChange, orderModel);
                            },
                          );
                        },
                        child: Text(
                          "View Remarks".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            decoration: TextDecoration.underline,
                            color: themeChange.getThem()
                                ? AppThemeData.secondary300
                                : AppThemeData.secondary300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Cancel Order".tr,
                          color: AppThemeData.new_primary,
                          textColor: AppThemeData.grey50,
                          height: 5,
                          onPress: () async {
                            String userId = await FireStoreUtils.getCurrentUid();
                            ShowToastDialog.showLoader('Please wait...'.tr);
                            await AudioPlayerService.playSound(false);
                            orderModel.status = Constant.orderCancelled;
                            if (orderModel.driverID != null) {
                              UserModel? driverModel =
                                  await FireStoreUtils.getUserById(
                                      orderModel.driverID ?? '');
                              if(driverModel!=null){
                                driverModel.orderRequestData
                                    ?.remove(orderModel.id);
                                driverModel.inProgressOrderID
                                    ?.remove(orderModel.id);
                                await FireStoreUtils.updateDriverUser(
                                    driverModel);
                                if (driverModel.fcmToken != null &&
                                    driverModel.fcmToken!.isNotEmpty) {
                                  SendNotification.sendFcmMessage(
                                      Constant.driverCancelled,
                                      driverModel.fcmToken.toString(),
                                      {'title': 'Cancelled Order'});
                                }
                              }
                            }
                            await FireStoreUtils.updateOrder(orderModel);
                            // Notify customer on order cancel
                            if (orderModel.author?.fcmToken != null &&
                                orderModel.author!.fcmToken!.isNotEmpty) {
                              SendNotification.sendFcmMessage(
                                Constant.restaurantCancelled,
                                orderModel.author!.fcmToken.toString(),
                                {
                                  'orderId': orderModel.id ?? '',
                                  'status': Constant.orderCancelled,
                                },
                              );
                            }

                            if (orderModel.paymentMethod!.toLowerCase() !=
                                'cod') {
                              double finalAmount = (subTotal +
                                      double.parse(
                                          orderModel.discount.toString()) +
                                      specialDiscount +
                                      double.parse(taxAmount.toString())) +
                                  double.parse(
                                      orderModel.deliveryCharge.toString()) +
                                  double.parse(orderModel.tipAmount.toString());

                              WalletTransactionModel historyModel =
                                  WalletTransactionModel(
                                      amount: finalAmount,
                                      id: const Uuid().v4(),
                                      orderId: orderModel.id,
                                      userId: orderModel.author!.id,
                                      date: Timestamp.now(),
                                      isTopup: true,
                                      paymentMethod: "Wallet",
                                      paymentStatus: "success",
                                      note: "Order Refund success",
                                      transactionUser: "user");
                              await FireStoreUtils.setWalletTransaction(historyModel);
                              // await FireStoreUtils.fireStore
                              //     .collection(CollectionName.wallet)
                              //     .doc(historyModel.id)
                              //     .set(historyModel.toJson());
                              await FireStoreUtils.updateUserWallet(
                                  amount: finalAmount.toString(),
                                  userId: orderModel.author!.id.toString());
                            }

                            double taxAmountData =
                                double.parse(taxAmount.toString());

                            double finalAmount = 0;
                            if (orderModel.adminCommission != '0' &&
                                orderModel.adminCommission != '' &&
                                orderModel.adminCommission != null) {
                              finalAmount = (subTotal /
                                      (1 +
                                          (double.parse(
                                                  orderModel.adminCommission!) /
                                              100))) -
                                  double.parse(orderModel.discount.toString()) -
                                  specialDiscount;
                            } else {
                              finalAmount = subTotal -
                                  double.parse(orderModel.discount.toString()) -
                                  specialDiscount;
                            }
                            WalletTransactionModel historyTaxModel =
                                WalletTransactionModel(
                                    amount: taxAmountData,
                                    id: const Uuid().v4(),
                                    orderId: orderModel.id,
                                    userId:userId,
                                    date: Timestamp.now(),
                                    isTopup: false,
                                    paymentMethod: "tax",
                                    paymentStatus: "success",
                                    note: "Tax Amount Refund",
                                    transactionUser: "vendor");

                            WalletTransactionModel historyModel =
                                WalletTransactionModel(
                                    amount: finalAmount,
                                    id: const Uuid().v4(),
                                    orderId: orderModel.id,
                                    userId:userId,
                                    date: Timestamp.now(),
                                    isTopup: false,
                                    paymentMethod: "Wallet",
                                    paymentStatus: "success",
                                    note: "Order Amount Refund",
                                    transactionUser: "vendor");
                            await FireStoreUtils.setWalletTransaction(historyTaxModel);
                            // await FireStoreUtils.fireStore
                            //     .collection(CollectionName.wallet)
                            //     .doc(historyTaxModel.id)
                            //     .set(historyTaxModel.toJson());
                            await FireStoreUtils.setWalletTransaction(historyModel);
                            // await FireStoreUtils.fireStore
                            //     .collection(CollectionName.wallet)
                            //     .doc(historyModel.id)
                            //     .set(historyModel.toJson());
                            double finalAmountdata = finalAmount + taxAmount;
                            await FireStoreUtils.updateUserWallet(
                                amount: (-finalAmountdata).toString(),
                                userId:
                                    FireStoreUtils.getCurrentUid().toString());
                            await controller.getOrder();
                            Get.back();
                            ShowToastDialog.closeLoader();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: orderModel.takeAway == true
                            ? RoundedButtonFill(
                                title: "Delivered".tr,
                                color: AppThemeData.primary300,
                                textColor: AppThemeData.grey50,
                                height: 5,
                                onPress: () async {
                                  ShowToastDialog.showLoader(
                                      'Please wait...'.tr);
                                  await AudioPlayerService.playSound(false);
                                  orderModel.status = Constant.orderCompleted;
                                  await FireStoreUtils.updateOrder(orderModel);
                                  await FireStoreUtils
                                      .restaurantVendorWalletSet(orderModel);
                                  if (orderModel.author?.fcmToken != null &&
                                      orderModel.author!.fcmToken!.isNotEmpty) {
                                    SendNotification.sendFcmMessage(
                                        Constant.takeawayCompleted,
                                        orderModel.author!.fcmToken.toString(),
                                        {});
                                  }

                                  ShowToastDialog.closeLoader();
                                },
                              )
                            : RoundedButtonFill(
                                title: orderModel.status.toString(),
                                color: AppThemeData.new_green_tog,
                                textColor: AppThemeData.grey50,
                                height: 5,
                                onPress: () async {},
                              ),
                      ),
                      ///// Chat button option
                      Visibility(
                        visible: false,
                        // visible: controller.userModel.value.subscriptionPlan
                        //         ?.features?.chat !=
                        //     false,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            InkWell(
                              onTap: () async {
                                ShowToastDialog.showLoader("Please wait".tr);

                                UserModel? customer =
                                    await FireStoreUtils.getUserById(
                                        orderModel.authorID.toString());
                                UserModel? restaurantUser =
                                    await FireStoreUtils.getUserProfile(
                                        orderModel.vendor!.author.toString());
                                VendorModel? vendorModel =
                                    await FireStoreUtils.getVendorById(
                                        orderModel.vendorID.toString());
                                ShowToastDialog.closeLoader();

                                Get.to(const ChatScreen(), arguments: {
                                  "customerName": '${customer!.fullName()}',
                                  "restaurantName": vendorModel!.title,
                                  "orderId": orderModel.id,
                                  "restaurantId": restaurantUser!.id,
                                  "customerId": customer.id,
                                  "customerProfileImage":
                                      customer.profilePictureURL,
                                  "restaurantProfileImage": vendorModel.photo,
                                  "token": restaurantUser.fcmToken,
                                  "chatType": "customer",
                                });
                              },
                              child: Container(
                                  decoration: ShapeDecoration(
                                    color: AppThemeData.secondary50,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset(
                                        "assets/icons/ic_message.svg"),
                                  )),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  completedAndRejectedWidget(themeChange, BuildContext context,
      OrderModel orderModel, HomeController controller) {
    // ignore: unused_local_variable
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double taxAmount = 0.0;
    double specialDiscount = 0.0;
    double adminCommission = 0.0;

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

    totalAmount = subTotal -
        double.parse(orderModel.discount.toString()) -
        specialDiscount +
        taxAmount;

    if (orderModel.adminCommissionType == 'Percent') {
      double basePrice =
          subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = double.parse(orderModel.adminCommission!);
    }

    return InkWell(
      // onTap: () async {
      //   Get.to(const OrderDetailsScreen(),
      //       arguments: {"orderModel": orderModel});
      // },
      onTap: () {}, // disables tap on the card
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: themeChange.getThem()
                ? AppThemeData.grey900
                : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: NetworkImageWidget(
                        imageUrl:
                            orderModel.author!.profilePictureURL.toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderModel.author!.fullName().toString().tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          orderModel.takeAway == true
                              ? Text(
                                  "Take Away".tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                )
                              : Text(
                                  orderModel.address!.getFullAddress().tr,
                                  style: TextStyle(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey400
                                        : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MySeparator(
                      color: themeChange.getThem()
                          ? AppThemeData.grey700
                          : AppThemeData.grey200),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderModel.products!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CartProductModel product = orderModel.products![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${product.quantity}x ${product.name}".tr,
                                style: TextStyle(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Text(
                              double.parse(product.discountPrice ?? "0.0") <= 0
                                  ? Constant.amountShow(
                                      amount: (double.parse(
                                                  product.price.toString()) *
                                              double.parse(
                                                  product.quantity.toString()))
                                          .toString())
                                  : Constant.amountShow(
                                          amount: (double.parse(product
                                                      .discountPrice
                                                      .toString()) *
                                                  double.parse(product.quantity
                                                      .toString()))
                                              .toString())
                                      .tr,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppThemeData.semiBold,
                              ),
                            ),
                          ],
                        ),
                        product.variantInfo == null ||
                                product.variantInfo!.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Variants".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey300
                                            : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: List.generate(
                                        product.variantInfo!.variantOptions!
                                            .length,
                                        (i) {
                                          return Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey800
                                                  : AppThemeData.grey100,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 5),
                                              child: Text(
                                                "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey500
                                                      : AppThemeData.grey400,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                        product.extras == null || product.extras!.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Addons".tr,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey300
                                                : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(
                                            amount: (double.parse(product
                                                        .extrasPrice
                                                        .toString()) *
                                                    double.parse(product
                                                        .quantity
                                                        .toString()))
                                                .toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem()
                                              ? AppThemeData.secondary300
                                              : AppThemeData.secondary300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      product.extras!.length,
                                      (i) {
                                        return Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey800
                                                : AppThemeData.grey100,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 5),
                                            child: Text(
                                              product.extras![i].toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey500
                                                    : AppThemeData.grey400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Order Date".tr,
                        style: TextStyle(
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    Text(
                      Constant.timestampToDateTime(orderModel.createdAt!),
                      style: TextStyle(
                        color: themeChange.getThem()
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                SizedBox.shrink(),
                Visibility(
                  visible: Constant.adminCommission?.isEnabled == true,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Admin Commissions".tr,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey300
                                    : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: adminCommission.toString())}"
                                .tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.danger300
                                  : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                // orderModel.scheduleTime == null
                //     ? const SizedBox()
                //     : Row(
                //         children: [
                //           Expanded(
                //             child: Text(
                //               "Schedule Time".tr,
                //               style: TextStyle(
                //                 color: themeChange.getThem()
                //                     ? AppThemeData.grey300
                //                     : AppThemeData.grey600,
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.w400,
                //                 fontFamily: AppThemeData.regular,
                //               ),
                //             ),
                //           ),
                //           Text(
                //             Constant.timestampToDateTime(
                //                     orderModel.scheduleTime!)
                //                 .tr,
                //             style: TextStyle(
                //               color: themeChange.getThem()
                //                   ? AppThemeData.secondary300
                //                   : AppThemeData.secondary300,
                //               fontSize: 16,
                //               fontWeight: FontWeight.w500,
                //               fontFamily: AppThemeData.semiBold,
                //             ),
                //           ),
                //         ],
                //       ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.notes == null || orderModel.notes!.isEmpty
                    ? const SizedBox()
                    : InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return viewRemarkDialog(
                                  controller, themeChange, orderModel);
                            },
                          );
                        },
                        child: Text(
                          "View Remarks".tr,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            decoration: TextDecoration.underline,
                            color: themeChange.getThem()
                                ? AppThemeData.secondary300
                                : AppThemeData.secondary300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RoundedButtonFill(
                    title: orderModel.status.toString(),
                    color: orderModel.status == Constant.orderRejected
                        ? AppThemeData.danger300
                        : AppThemeData.secondary300,
                    textColor: AppThemeData.grey50,
                    height: 5,
                    onPress: () async {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showListOfDeliverymenDialog(
      HomeController controller, themeChange, OrderModel orderModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      "Select the delivery man".tr,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey100
                            : AppThemeData.grey800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  TextButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Add Delivery Man'.tr,
                        style: TextStyle(
                            color: AppThemeData.secondary300,
                            fontFamily: AppThemeData.medium),
                      ),
                    ),
                    onPressed: () {
                      // Get.to(AddDriverScreen())?.then((value) async {
                      //   if (value == true) {
                      //     Get.back();
                      //     ShowToastDialog.showToastDuration(
                      //         "Please ensure that the deliveryman is signed in and has an active status to assign the delivery."
                      //             .tr,
                      //         duration: Duration(seconds: 4));
                      //   }
                      // });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownSearch<UserModel>(
                    popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelStyle: TextStyle(
                                fontFamily: AppThemeData.medium, fontSize: 15),
                            labelText: "Search Delivery Man".tr,
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.search),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                        itemBuilder:
                            (context, UserModel driver, bool isSelected) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    "${driver.firstName} ${driver.lastName}",
                                    style: TextStyle(
                                      fontFamily: AppThemeData.medium,
                                      fontSize: 14,
                                      // Change this to match your theme
                                    ),
                                  ),
                                ),
                                if (Constant.singleOrderReceive == true)
                                  Expanded(
                                    flex: 1,
                                    child: driver.inProgressOrderID?.isEmpty ==
                                            true
                                        ? Text(
                                            'Assign'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 12,
                                              color: AppThemeData.secondary300,
                                              // Change this to match your theme
                                            ),
                                          )
                                        : Text(
                                            'Occupied'.tr,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 12,
                                              color: AppThemeData.danger300,
                                              // Change this to match your theme
                                            ),
                                          ),
                                  ),
                              ],
                            ),
                          );
                        }),
                    items: controller.driverUserList,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      baseStyle: TextStyle(
                        fontFamily: AppThemeData.medium,
                        fontSize: 16,
                      ),
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Select Delivery Man".tr,
                        labelStyle: TextStyle(
                          fontFamily: AppThemeData.medium,
                          fontSize: 15, // Light grey label text
                        ),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                    itemAsString: (UserModel? user) => user?.id != null
                        ? "${user?.firstName} ${user?.lastName}"
                        : "Select Delivery Man".tr,
                    onChanged: (value) {
                      if (Constant.singleOrderReceive == true) {
                        if (value?.inProgressOrderID?.isEmpty == true) {
                          controller.selectDriverUser.value = value!;
                        } else {
                          ShowToastDialog.showToast(
                              "This delivery man is already assigned. Kindly select a different one."
                                  .tr);
                          controller.selectDriverUser.value = UserModel();
                        }
                      } else {
                        controller.selectDriverUser.value = value!;
                      }
                    },
                    selectedItem: controller.selectDriverUser.value,
                  ),
                )),
            SizedBox(height: 20),
            PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: themeChange.getThem()
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
                height: 3.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Cancel".tr,
                          color: themeChange.getThem()
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          textColor: themeChange.getThem()
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                          onPress: () async {
                            Get.back();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Order Assign".tr,
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () async {
                            if (controller.selectDriverUser.value.id != null &&
                                controller.selectDriverUser.value.id != '') {
                              Get.back();
                              ShowToastDialog.showLoader('Please wait...'.tr);
                              await AudioPlayerService.playSound(false);
                              if ((Constant.isSubscriptionModelApplied ==
                                          true ||
                                      Constant.adminCommission?.isEnabled ==
                                          true) &&
                                  controller
                                          .vendermodel.value.subscriptionPlan !=
                                      null) {
                                if (controller.vendermodel.value
                                            .subscriptionTotalOrders !=
                                        '-1' &&
                                    controller.vendermodel.value
                                            .subscriptionTotalOrders !=
                                        null) {
                                  controller.vendermodel.value
                                      .subscriptionTotalOrders = (int.parse(
                                              controller.vendermodel.value
                                                  .subscriptionTotalOrders!) -
                                          1)
                                      .toString();
                                  await FireStoreUtils.updateVendor(
                                      controller.vendermodel.value);
                                }
                              }
                              orderModel.notes = "";
                              orderModel.driverID =
                                  controller.selectDriverUser.value.id;
                              orderModel.driver =
                                  controller.selectDriverUser.value;
                              orderModel.status = Constant.orderInTransit;
                              controller
                                  .selectDriverUser.value.inProgressOrderID!
                                  .add(orderModel.id);
                              await FireStoreUtils.updateOrder(orderModel);
                              await FireStoreUtils.updateDriverUser(
                                  controller.selectDriverUser.value);
                              await FireStoreUtils.restaurantVendorWalletSet(
                                  orderModel);
                              if (orderModel.author?.fcmToken != null &&
                                  orderModel.author!.fcmToken!.isNotEmpty) {
                                SendNotification.sendFcmMessage(
                                    Constant.restaurantAccepted,
                                    orderModel.author!.fcmToken.toString(), {});
                              }
                              if (orderModel.driver?.fcmToken != null &&
                                  orderModel.driver!.fcmToken!.isNotEmpty) {
                                SendNotification.sendFcmMessage(
                                    Constant.newDeliveryOrder,
                                    orderModel.driver?.fcmToken.toString() ??'', {});
                              }
                              ShowToastDialog.closeLoader();
                            } else {
                              ShowToastDialog.showToast(
                                  "Please select the delivery man".tr);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> _showDurationPicker(BuildContext context, HomeController controller) async {
    // Get current duration if exists
    Duration initialDuration = const Duration(minutes: 10);
    if (controller.estimatedTimeController.value.text.isNotEmpty) {
      final timeText = controller.estimatedTimeController.value.text.trim();
      // Check if it's in "X minutes" format
      if (timeText.toLowerCase().contains('minutes') || timeText.toLowerCase().contains('minute')) {
        final minutesMatch = RegExp(r'(\d+)\s*(?:minutes?|min)', caseSensitive: false).firstMatch(timeText);
        if (minutesMatch != null) {
          final minutes = int.tryParse(minutesMatch.group(1) ?? '') ?? 10;
          initialDuration = Duration(minutes: minutes.clamp(1, 2400));
        }
      } else {
        // Parse "hours:minutes" format (e.g., "1:30" = 90 minutes)
        final parts = timeText.split(':');
        if (parts.length == 2) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          final totalMinutes = (hours * 60) + minutes;
          initialDuration = Duration(minutes: totalMinutes.clamp(1, 2400)); // Max 40 hours
        } else {
          // Fallback: try parsing as just minutes
          final minutes = int.tryParse(timeText) ?? 10;
          initialDuration = Duration(minutes: minutes.clamp(1, 2400));
        }
      }
    }

    final duration = await showModalBottomSheet<Duration>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DurationPickerBottomSheet(
        initialDuration: initialDuration,
      ),
    );

    if (duration != null) {
      _updateDuration(duration, controller);
    }
  }

  void _updateDuration(Duration duration, HomeController controller) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final mins = duration.inMinutes.remainder(60);
    final totalMinutes = duration.inMinutes;
    
    // If less than 1 hour, show as "X minutes", otherwise show as "H:MM"
    if (hours == 0) {
      controller.estimatedTimeController.value.text = '$totalMinutes minutes';
    } else {
      controller.estimatedTimeController.value.text = '$hours:${twoDigits(mins)}';
    }
    print("${controller.estimatedTimeController.value.text} _updateDuration");
    controller.estimatedTimeController.refresh();
  }
  // void _updateDuration(Duration duration,  HomeController controller, ) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final hours = twoDigits(duration.inHours);
  //   final minutes = twoDigits(duration.inMinutes.remainder(60));
  //
  //   controller.estimatedTimeController.value.text = '$hours:$minutes';
  //   controller.estimatedTimeController.refresh();
  // }
  estimatedTimeDialog(HomeController controller, themeChange,
      OrderModel orderModel, BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                "Estimate time to prepare".tr,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: themeChange.getThem()
                      ? AppThemeData.grey100
                      : AppThemeData.grey800,
                  fontSize: 18,
                ),
              ),
            ),
            PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: themeChange.getThem()
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
                height: 3.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async => _showDurationPicker(context,controller),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Estimated Time',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Obx(() => Text(
                                      controller.estimatedTimeController.value.text.isEmpty
                                          ? 'Select duration'
                                          : controller.estimatedTimeController.value.text,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: controller.estimatedTimeController.value.text.isEmpty
                                            ? Colors.grey.shade500
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              Obx(() => controller.estimatedTimeController.value.text.isNotEmpty
                                  ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey.shade500, size: 20),
                                onPressed: () {
                                  controller.estimatedTimeController.value.text = '';
                                  controller.estimatedTimeController.refresh();
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 40),
                              )
                                  : Icon(
                                Icons.arrow_drop_down_rounded,
                                color: Colors.grey.shade500,
                                size: 24,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // TextFieldWidget(
    //                 title: 'Estimated time to Prepare'.tr,
    //                 inputFormatters: [MaskedInputFormatter('##:##')],
    //                 controller: controller.estimatedTimeController.value,
    //                 hintText: '00:00'.tr,
    //                 textInputType: TextInputType.number,
    //                 prefix: const Icon(Icons.alarm),
    //               ),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Cancel".tr,
                          color: themeChange.getThem()
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          textColor: themeChange.getThem()
                              ? AppThemeData.grey100
                              : AppThemeData.grey800,
                          onPress: () async {
                            Get.back();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: RoundedButtonFill(
                          title: "Shipped order".tr,
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () async {
                            if (controller.estimatedTimeController.value.text.isNotEmpty) {
                              if ((Constant.isSubscriptionModelApplied == true ||
                                  Constant.adminCommission?.isEnabled == true) &&
                                  controller.vendermodel.value.subscriptionPlan != null) {
                                if (controller.vendermodel.value.subscriptionTotalOrders != '-1' &&
                                    controller.vendermodel.value.subscriptionTotalOrders != null) {
                                  controller.vendermodel.value.subscriptionTotalOrders = (int.parse(
                                      controller.vendermodel.value.subscriptionTotalOrders!) -
                                      1).toString();
                                  await FireStoreUtils.updateVendor(controller.vendermodel.value);
                                }
                              }
                              if (Constant.isSelfDeliveryFeature == true &&
                                  controller.vendermodel.value.isSelfDelivery == true &&
                                  orderModel.takeAway == false) {
                                ShowToastDialog.showLoader('Please wait...'.tr);
                                await controller.getAllDriverList();
                                ShowToastDialog.closeLoader();
                                orderModel.estimatedTimeToPrepare = controller.estimatedTimeController.value.text;
                                Get.back();
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return showListOfDeliverymenDialog(controller, themeChange, orderModel);
                                  },
                                );
                              } else {
                                ShowToastDialog.showLoader('Please wait...'.tr);
                                orderModel.estimatedTimeToPrepare = controller.estimatedTimeController.value.text;
                                orderModel.status = Constant.orderAccepted;
                                // Play sound (quick operation)
                                await AudioPlayerService.playSound(false);
                                // Get driver radius in parallel with other operations
                                double radius = Constant.driverSearchRadius ?? 5.0;
                                Future<void> radiusFuture = Future.value();
                                if (Constant.driverSearchRadius == null) {
                                  String getUrl = '${Constant.baseUrl}restaurant/GetDriverNearBy';
                                  print("getUrl $getUrl ");
                                  radiusFuture = http.get(
                                    Uri.parse(getUrl),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                  ).then((response) {
                                    if (response.statusCode == 200) {
                                      final data = json.decode(response.body);
                                      if (data['success'] == true) {
                                        radius = double.tryParse(data['data']['driverRadios'].toString()) ?? 5.0;
                                        print("GetDriverNearByGetDriverNearBy ${radius} ");
                                        Constant.driverSearchRadius = radius;
                                      }
                                    } else {
                                      radius = 5.0;
                                      Constant.driverSearchRadius = radius;
                                    }
                                  }).catchError((e) {
                                    print('Error fetching driver radius: $e');
                                    radius = 5.0;
                                    Constant.driverSearchRadius = radius;
                                  });
                                }
                                final orderUpdateFuture = FireStoreUtils.updateOrder(orderModel);
                                final walletUpdateFuture = FireStoreUtils.restaurantVendorWalletSet(orderModel);
                                await Future.wait([radiusFuture, orderUpdateFuture, walletUpdateFuture]);
                                await controller.getOrder(silent: false);
                                // After refreshing orders, check if there are any remaining pending orders
                                // If not, stop the notification sound
                                if (controller.newOrderList.isEmpty) {
                                  await AudioPlayerService.playSound(false);
                                  print("No pending orders remaining - stopped notification sound");
                                }
                                final double restaurantLat = controller.vendermodel.value.latitude ?? 0.0;
                                final double restaurantLng = controller.vendermodel.value.longitude ?? 0.0;
                                List<UserModel> allDrivers = await FireStoreUtils.getAvalibleDrivers();
                                List<UserModel> eligibleDrivers = allDrivers.where((driver) {
                                  if (driver.location == null ||
                                      driver.location!.latitude == null ||
                                      driver.location!.longitude == null) {
                                    print("Driver ${driver.firebaseId} filtered: No location data");
                                    return false;
                                  }
                                  final double driverLat = driver.location?.latitude??0;
                                  final double driverLng = driver.location?.longitude??0;
                                  double distance = Geolocator.distanceBetween(
                                      restaurantLat, restaurantLng, driverLat, driverLng) /
                                      1000;
                                  bool isEligible = distance <= radius;
                                  if (!isEligible) {
                                    print("Driver ${driver.firebaseId} (${driver.firstName} ${driver.lastName}) filtered: Distance ${distance.toStringAsFixed(2)}km exceeds radius ${radius}km");
                                  }
                                  return isEligible;
                                }).toList();
                                print("Total drivers: ${allDrivers.length}, Eligible drivers: ${eligibleDrivers.length}, Radius: ${radius}km");
                                if (eligibleDrivers.isNotEmpty) {
                                  // Update drivers sequentially with delays to avoid rate limiting
                                  for (var driver in eligibleDrivers) {
                                    print("driverfcmtoken ${driver.fcmToken} ${driver.email}");
                                    driver.orderRequestData ??= [];
                                    if (!driver.orderRequestData!.contains(orderModel.id)) {
                                      driver.orderRequestData!.add(orderModel.id);
                                      await FireStoreUtils.updateDriverUser(driver);
                                      SendNotification.sendFcmMessage(
                                          Constant.restaurantAccepted,
                                          driver.fcmToken.toString(), {},);
                                      await Future.delayed(const Duration(milliseconds: 100));
                                    }
                                  }
                                }
                                // Send notification (non-blocking, don't wait for it)
                                if (orderModel.author?.fcmToken != null &&
                                    orderModel.author!.fcmToken!.isNotEmpty) {
                                  SendNotification.sendFcmMessage(
                                    Constant.restaurantAccepted,
                                    orderModel.author!.fcmToken.toString(),
                                    {},
                                  );
                                }
                                ShowToastDialog.closeLoader();
                                Get.back();
                              }
                            } else {
                              ShowToastDialog.showToast("Please enter estimated time".tr);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  viewRemarkDialog(
      HomeController controller, themeChange, OrderModel orderModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  orderModel.notes.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem()
                        ? AppThemeData.grey100
                        : AppThemeData.grey800,
                    fontSize: 18,
                  ),
                ),
              ),
              RoundedButtonFill(
                title: "Cancel".tr,
                color: themeChange.getThem()
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
                textColor: themeChange.getThem()
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
                onPress: () async {
                  Get.back();
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class DurationPickerBottomSheet extends StatefulWidget {
  final Duration initialDuration;
  const DurationPickerBottomSheet({
    super.key,
    required this.initialDuration,
  });

  @override
  State<DurationPickerBottomSheet> createState() => _DurationPickerBottomSheetState();
}

class _DurationPickerBottomSheetState extends State<DurationPickerBottomSheet> {
  late Duration _selectedDuration;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Select Duration',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Minutes Picker
            // SizedBox(
            //   height: 200,
            //   child: ListWheelScrollView(
            //     itemExtent: 50,
            //     diameterRatio: 1.5,
            //     onSelectedItemChanged: (index) {
            //       setState(() {
            //         _selectedDuration = Duration(minutes: index + 1); // 1 to 40 minutes
            //       });
            //     },
            //     children: List.generate(40, (index) { // Only 40 minutes
            //       final minutes = index + 1;
            //       return Center(
            //         child: Text(
            //           '$minutes ${minutes == 1 ? 'minute' : 'minutes'}',
            //           style: TextStyle(
            //             fontSize: 20,
            //             color: minutes == _selectedDuration.inMinutes
            //                 ? Theme.of(context).primaryColor
            //                 : Colors.grey.shade600,
            //             fontWeight: minutes == _selectedDuration.inMinutes
            //                 ? FontWeight.w600
            //                 : FontWeight.normal,
            //           ),
            //         ),
            //       );
            //     }),
            //   ),
            // ),

            // Selected Duration Display
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedDuration.inMinutes} minutes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Select Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15, 20, 25, 30, 35, 40].map((minutes) {
                  return FilterChip(
                    label: Text('$minutes min'),
                    selected: _selectedDuration.inMinutes == minutes,
                    onSelected: (selected) {
                      setState(() {
                        _selectedDuration = Duration(minutes: minutes);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, _selectedDuration,),
                      style: FilledButton.styleFrom(backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16,),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}