import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/product_screens/add_from_catalog_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/edit_product_screen.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';

/// Add Product: catalog flow when adding; edit form when [product] is not null (tap product in list to edit).
class AddProductScreen extends StatelessWidget {
  final ProductModel? product;

  const AddProductScreen({super.key, this.product});

  @override
  Widget build(BuildContext context) {
    // Use constructor product first, then route/Get arguments
    ProductModel? productToEdit = product;
    if (productToEdit == null) {
      final args = ModalRoute.of(context)?.settings.arguments ?? Get.arguments;
      if (args != null && args is Map) {
        final p = args['productModel'] ?? args['product'];
        if (p != null) {
          productToEdit = p is ProductModel ? p : (p is Map ? ProductModel.fromJson(Map<String, dynamic>.from(p)) : null);
        }
      }
    }

    if (productToEdit != null) {
      return EditProductScreen(product: productToEdit);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.orange,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppThemeData.grey50),
        title: Text(
          "Add Product".tr,
          style: const TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
        ),
      ),
      body: const AddFromCatalogBody(),
    );
  }
}
