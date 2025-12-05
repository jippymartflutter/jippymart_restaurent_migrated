// Helper method to build price display

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/add_product_screen.dart';
import 'package:jippymart_restaurant/app/verification_screen/verification_screen.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';

import '../../models/product_model.dart';

class ProductToggles extends StatelessWidget {
  final bool isPublished;
  final bool isAvailable;
  final ValueChanged<bool> onPublishChanged;
  final ValueChanged<bool> onAvailableChanged;

  const ProductToggles({
    required this.isPublished,
    required this.isAvailable,
    required this.onPublishChanged,
    required this.onAvailableChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 350;
    return isSmall
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _toggleRow('Publish', isPublished, onPublishChanged),
        _toggleRow('Available', isAvailable, onAvailableChanged),
      ],
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _toggleRow('Publish', isPublished, onPublishChanged),
        SizedBox(width: 12),
        _toggleRow('Available', isAvailable, onAvailableChanged),
      ],
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        IgnorePointer(
          ignoring: false,
          child: Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: Color(0xFF229954),
            ),
          ),
        ),
      ],
    );
  }
}

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  // Helper method for safe double parsing
  double _safeParseDouble(String value) {
    if (value.isEmpty) return 0.0;
    try {
      return double.tryParse(value) ?? 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Helper method to build price display
  Widget _buildPriceDisplay(String price, String disPrice, DarkThemeProvider themeChange) {
    // Debug prints to see what's happening
    print("🔍 Price Display - Raw Price: '$price', Raw DisPrice: '$disPrice'");
    double parsedPrice = _safeParseDouble(price);
    double parsedDisPrice = _safeParseDouble(disPrice);
    print("🔍 Price Display - Parsed Price: $parsedPrice, Parsed DisPrice: $parsedDisPrice");
    // Check if we should show discounted price
    bool shouldShowDiscounted = parsedDisPrice > 0 && parsedDisPrice < parsedPrice;
    if (!shouldShowDiscounted) {
      return Text(
        Constant.amountShow(amount: parsedPrice.toString()),
        style: TextStyle(
          fontSize: 16,
          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          fontFamily: AppThemeData.semiBold,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      // Show both discounted price and original price
      return Row(
        children: [
          Text(
            Constant.amountShow(amount: parsedDisPrice.toString()),
            style: TextStyle(
              fontSize: 16,
              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
              fontFamily: AppThemeData.semiBold,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            Constant.amountShow(amount: parsedPrice.toString()),
            style: TextStyle(
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
              decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
              fontFamily: AppThemeData.semiBold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ProductListController>(
        init: ProductListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: ColorConst.orange,
              centerTitle: false,
              title: Text(
                "Manage Productsdd".tr,
                style: TextStyle(
                    color: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey50,
                    fontSize: 18,
                    fontFamily: AppThemeData.medium),
              ),
              actions: [
                (Constant.isRestaurantVerification == true &&
                    controller.userModel.value.isDocumentVerify ==
                        false) ||
                    (controller.userModel.value.vendorID == null ||
                        controller.userModel.value.vendorID!.isEmpty)
                    ? const SizedBox()
                    : InkWell(
                  onTap: () {
                    Get.to(const AddProductScreen())!.then(
                          (value) {
                        if (value == true) {
                          controller.getProduct();
                        }
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey50,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Add".tr,
                          style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey50,
                              fontSize: 18,
                              fontFamily: AppThemeData.medium),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Constant.isRestaurantVerification == true &&
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
                      final result = await Get.to(const AddRestaurantScreen());
                      if (result == true) {
                        await controller.getUserProfile();
                      }
                    },
                  ),
                ],
              ),
            )
                : controller.productList.isEmpty
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
                        "assets/icons/ic_knife_fork.svg",
                        colorFilter: ColorFilter.mode(
                            themeChange.getThem()
                                ? AppThemeData.grey400
                                : AppThemeData.grey500,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    "No Products Available".tr,
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
                    "Your menu is currently empty. Create your first product to start showcasing your offerings."
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
                    title: "Add Product".tr,
                    width: 55,
                    height: 5.5,
                    color: AppThemeData.secondary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      Get.to(const AddProductScreen())!
                          .then(
                            (value) {
                          if (value == true) {
                            controller.getProduct();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            )
                : Column(
              children: [
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categoryList.length + 1,
                    itemBuilder: (context, index) {
                      final isAll = index == 0;
                      final isSelected = isAll
                          ? controller.selectedCategory.value == null
                          : controller.selectedCategory.value?.id == controller.categoryList[index - 1].id;
                      if (isAll) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: ChoiceChip(
                            label: Text('All'),
                            selected: isSelected,
                            onSelected: (_) {
                              controller.selectedCategory.value = null;
                            },
                            selectedColor: AppThemeData.secondary300,
                            backgroundColor: AppThemeData.grey200,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppThemeData.grey900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      final category = controller.categoryList[index - 1];
                      final isActive = category.isActive ?? true;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        child: Opacity(
                          opacity: isActive ? 1.0 : 0.4,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ChoiceChip(
                                label: Text(category.title ?? ''),
                                selected: isSelected,
                                onSelected: isActive
                                    ? (_) {
                                  controller.selectedCategory.value = category;
                                }
                                    : null,
                                selectedColor: AppThemeData.secondary300,
                                backgroundColor: AppThemeData.grey200,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppThemeData.grey900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Switch(
                                value: isActive,
                                onChanged: (_) => controller.toggleCategoryActive(index -1,),
                                activeColor: AppThemeData.secondary300,
                                thumbColor: MaterialStatePropertyAll(Colors.white),
                                trackColor: MaterialStatePropertyAll(Color(0xFFE74C3C)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.filteredProductList.length,
                    itemBuilder: (context, index) {
                      final product = controller.filteredProductList[index];
                      print("🛒 Product: ${product.name} - Price: ${product.price}, DisPrice: ${product.disPrice}");

                      // FIXED: Simplified price extraction logic
                      String price = "0.0";
                      String disPrice = "0.0";

                      // Check if product has variants/attributes
                      bool hasVariants = product.itemAttribute != null &&
                          product.itemAttribute!.variants != null &&
                          product.itemAttribute!.variants!.isNotEmpty;

                      if (hasVariants) {
                        // Handle products with variants
                        List<String> selectedVariants = [];
                        if (product.itemAttribute!.attributes != null &&
                            product.itemAttribute!.attributes!.isNotEmpty) {
                          for (var element in product.itemAttribute!.attributes!) {
                            if (element.attributeOptions != null &&
                                element.attributeOptions!.isNotEmpty) {
                              selectedVariants.add(element.attributeOptions![0]);
                            }
                          }
                        }

                        if (selectedVariants.isNotEmpty) {
                          final variantSku = selectedVariants.join('-');
                          final matchingVariant = product.itemAttribute!.variants!
                              .firstWhere((element) => element.variantSku == variantSku,
                              orElse: () => Variants());

                          if (matchingVariant.variantPrice != null &&
                              matchingVariant.variantPrice!.isNotEmpty) {
                            price = matchingVariant.variantPrice!;
                            disPrice = '0';
                          }
                        }
                      } else {
                        // Use direct product prices - FIXED: Ensure we use actual product prices
                        price = product.price?.toString() ?? "0.0";
                        disPrice = product.disPrice?.toString() ?? "0.0";

                        // Debug: Check if we're getting the right prices
                        print("💰 Direct prices - Price: $price, DisPrice: $disPrice");
                        print("💰 Product price field: ${product.price}, disPrice field: ${product.disPrice}");
                      }

                      // If price is still 0.0, try to get from product directly as fallback
                      if (price == "0.0" || price.isEmpty) {
                        price = product.price?.toString() ?? "0.0";
                        disPrice = product.disPrice?.toString() ?? "0.0";
                        print("🔄 Fallback to direct prices - Price: $price, DisPrice: $disPrice");
                      }

                      bool isDisplayItemAlert = false;

                      return InkWell(
                        onTap: product.isAvailable == false
                            ? null
                            : () {
                          Get.to(const AddProductScreen(),
                              arguments: {
                                "productModel": product
                              })!
                              .then(
                                (value) {
                              if (value == true) {
                                controller.getProduct();
                              }
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Opacity(
                            opacity: product.isAvailable == false ? 0.5 : 1.0,
                            child: Container(
                              decoration: ShapeDecoration(
                                color: product.isAvailable == false
                                    ? Colors.grey[300]
                                    : themeChange.getThem()
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
                                        ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                                          child: Stack(
                                            children: [
                                              NetworkImageWidget(
                                                imageUrl: product.photo.toString(),
                                                fit: BoxFit.cover,
                                                height: Responsive.height(12, context),
                                                width: Responsive.width(24, context),
                                              ),
                                              Container(
                                                height: Responsive.height(12, context),
                                                width: Responsive.width(24, context),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: const Alignment(-0.00, -1.00),
                                                    end: const Alignment(0, 1),
                                                    colors: [
                                                      Colors.black.withOpacity(0),
                                                      const Color(0xFF111827)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name.toString(),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                  fontFamily: AppThemeData.semiBold,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              // Use the fixed price display method
                                              _buildPriceDisplay(price, disPrice, themeChange),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/icons/ic_star.svg",
                                                    colorFilter: const ColorFilter.mode(AppThemeData.warning300, BlendMode.srcIn),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${Constant.calculateReview(reviewCount: product.reviewsCount!.toStringAsFixed(0), reviewSum: product.reviewsSum.toString())} (${product.reviewsCount!.toStringAsFixed(0)})",
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                      fontFamily: AppThemeData.regular,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                product.description.toString(),
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                  fontFamily: AppThemeData.regular,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Color(0xFFC0392B)),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Delete Product?'),
                                                content: Text('Are you sure you want to delete this product?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(),
                                                    child: Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      controller.deleteProduct(index);
                                                    },
                                                    child: Text('Delete', style: TextStyle(color: Color(0xFFC0392B))),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ProductToggles(
                                      isPublished: product.publish ?? false,
                                      isAvailable: product.isAvailable ?? true,
                                      onPublishChanged: (val) => controller.updateList(product.id!, product.publish!),
                                      onAvailableChanged: (val) => controller.updateAvailableStatus(product.id!, product.isAvailable ?? true),
                                    ),
                                    Visibility(
                                      visible: isDisplayItemAlert,
                                      child: Text(
                                        "This product will not be displayed to customers due to your current subscription limitations.".tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                                            fontSize: 12,
                                            fontFamily: AppThemeData.regular),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}