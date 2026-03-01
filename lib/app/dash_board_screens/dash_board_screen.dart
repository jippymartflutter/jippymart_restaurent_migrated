import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/dash_board_controller.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:jippymart_restaurant/utils/const/image_const.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    // IMPORTANT: create controllers only once (avoid duplicate onInit/network calls)
    final controller = Get.put(DashBoardController());
    final productListController = Get.put(ProductListController());

    return Obx(() {
      return WillPopScope(
            onWillPop: () async {
              if (controller.selectedIndex.value != 0) {
                controller.selectedIndex.value = 0;
                return false;
              } else {
                final now = DateTime.now();
                if (controller.currentBackPressTime == null ||
                    now.difference(controller.currentBackPressTime!) > const Duration(seconds: 2)) {
                  controller.currentBackPressTime = now;
                  ShowToastDialog.showToast("Double press to exit".tr);
                  return false;
                }
                return true;
              }
            },
            child: PopScope(
              canPop: controller.canPopNow.value,
              onPopInvoked: (didPop) {
                // No-op, handled by WillPopScope
              },
              child: Scaffold(
                body: SafeArea(
                  child: Column(
                    children: [
                      Builder(
                        builder: (context) => Obx(() => SwitchListTile(
                          title: Text(controller.vendorModel.value.isOpen == true
                              ? 'Restaurant Open'
                              : 'Restaurant Closed'),
                          value: controller.vendorModel.value.isOpen ?? false,
                          onChanged: (val) async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(val ? 'Open Restaurant?' : 'Close Restaurant?'),
                                content: Text(val
                                    ? 'Are you sure you want to open the restaurant and start accepting orders?'
                                    : 'Are you sure you want to close the restaurant and stop accepting orders?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Yes', style: TextStyle(color: AppThemeData.new_primary),),

                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              controller.updateRestStatus(val);
                            }
                          },
                          thumbColor: MaterialStatePropertyAll(Colors.white),
                          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFF138D75);
                            }
                            return Color(0xFFC0392B);
                          }),
                        )),
                      ),
                      Expanded(
                        child: Obx(() => IndexedStack(
                          index: controller.selectedIndex.value,
                          children: controller.pageList,
                        )),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: true,
                  showSelectedLabels: true,
                  selectedFontSize: 12,
                  selectedLabelStyle:
                      const TextStyle(fontFamily: AppThemeData.bold),
                  unselectedLabelStyle:
                      const TextStyle(fontFamily: AppThemeData.bold),
                  currentIndex: controller.selectedIndex.value,
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.grey900
                      : AppThemeData.grey50,
                  selectedItemColor: themeChange.getThem()
                      ? ColorConst.orange
                      : ColorConst.orange,
                  unselectedItemColor: themeChange.getThem()
                      ? AppThemeData.grey300
                      : AppThemeData.grey600,
                  onTap: (int index) {
                    controller.selectedIndex.value = index;

                    if(index==1){
                      if(productListController.productList.isEmpty){
                        productListController.getUserProfile();
                        productListController.getProduct();
                      }
                    }
                  },
                  items: Constant.isDineInEnable
                      ? [
                          navigationBarItem(
                            themeChange,
                            index: 0,
                            assetIcon: ImageConst.homeIcon,
                            label: 'Home'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 1,
                            assetIcon: "assets/icons/ic_dinein.svg",
                            label: 'Dine in'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 2,
                            assetIcon: ImageConst.products,
                            label: 'Manage Inventory'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 3,

                            /*assetIcon: "assets/icons/ic_wallet.svg",
                            label: 'Wallet'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 4,*/

                            assetIcon: ImageConst.profile,
                            label: 'Profile'.tr,
                            controller: controller,
                          ),
                        ]
                      : [
                          navigationBarItem(
                            themeChange,
                            index: 0,
                            assetIcon: ImageConst.homeIcon,
                            label: 'Home'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 1,
                            assetIcon:  ImageConst.products,
                            label: 'Manage Inventory'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 2,

                            /*
                            assetIcon: "assets/icons/ic_wallet.svg",
                            label: 'Wallet'.tr,
                            controller: controller,
                          ),
                          navigationBarItem(
                            themeChange,
                            index: 3,

                             */
                            assetIcon:  ImageConst.profile,
                            label: 'Profile'.tr,
                            controller: controller,
                          ),
                        ],
                ),
              ),
            ),
          );
    });
  }

  BottomNavigationBarItem navigationBarItem(themeChange,
      {required int index,
      required String label,
      required String assetIcon,
      required DashBoardController controller}) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SvgPicture.asset(
          assetIcon,
          height: 22,
          width: 22,
          color: controller.selectedIndex.value == index
              ? themeChange.getThem()
                  ? ColorConst.orange
                  : ColorConst.orange
              : themeChange.getThem()
                  ? AppThemeData.grey300
                  : AppThemeData.grey600,
        ),
      ),
      label: label,
    );
  }
}
