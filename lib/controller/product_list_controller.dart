// import 'package:get/get.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/models/product_model.dart';
// import 'package:jippymart_restaurant/models/user_model.dart';
// import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/config/app_config.dart';
//
// class ProductListController extends GetxController {
//   @override
//   void onInit() {
//     super.onInit();
//     // Load profile then products; categories are refreshed after productList is set (inside getProduct).
//     getUserProfile();
//   }
//
//   Rx<UserModel> userModel = UserModel().obs;
//   RxBool isLoading = true.obs;
//
//   getUserProfile() async {
//     String userId = await FireStoreUtils.getCurrentUid();
//     await FireStoreUtils.getUserProfile(userId).then(
//       (value) {
//         if (value != null) {
//           Constant.userModel = value;
//           userModel.value = value;
//         }
//       },
//     );
//     await getProduct();
//     isLoading.value = false;
//   }
//
//   RxList<ProductModel> productList = <ProductModel>[].obs;
//   RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
//   Rx<VendorCategoryModel?> selectedCategory = Rx<VendorCategoryModel?>(null);
//   Future<void> getProduct() async {
//     await FireStoreUtils.getProduct().then(
//       (value) {
//         if (value != null) {
//           productList.value = value;
//         }
//       },
//     );
//     await refreshCategoriesWithProducts();
//   }
//   Future<void> refreshCategoriesWithProducts() async {
//     if (productList.isEmpty) return;
//
//     final allProductCategoryIds = productList
//         .map((p) => p.categoryID?.toString())
//         .whereType<String>()
//         .where((s) => s.isNotEmpty)
//         .toSet();
//     final categories = await FireStoreUtils.getVendorCategoryById();
//     if (categories != null && categories.isNotEmpty) {
//       if (allProductCategoryIds.isEmpty) {
//         categoryList.value = List.from(categories)
//           ..sort((a, b) => (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
//       } else {
//         final matched = categories
//             .where((cat) {
//               final catId = cat.id?.toString() ?? '';
//               return catId.isNotEmpty && allProductCategoryIds.contains(catId);
//             })
//             .toList();
//         matched.sort((a, b) => (a.title ?? '').toLowerCase().compareTo((b.title ?? '').toLowerCase()));
//         categoryList.value = matched;
//       }
//       return;
//     }
//
//     if (allProductCategoryIds.isNotEmpty) {
//       categoryList.value = allProductCategoryIds.map((id) => VendorCategoryModel(
//         id: id,
//         title: 'Category',
//         isActive: true,
//       )).toList()..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
//     }
//   }
//
//   Future<void> getCategories() async {
//     await refreshCategoriesWithProducts();
//   }
//
//   updateList(String productId, bool isPublish) async {
//     int mainIndex = productList.indexWhere((p) => p.id == productId);
//     if (mainIndex != -1) {
//       ProductModel productModel = productList[mainIndex];
//       productModel.publish = !isPublish;
//       productList[mainIndex] = productModel;
//       update();
//       await FireStoreUtils.setProduct(productModel);
//     }
//   }
//
//   updateAvailableStatus(String productId, bool isAvailable) async {
//     int mainIndex = productList.indexWhere((p) => p.id == productId);
//     if (mainIndex != -1) {
//       ProductModel productModel = productList[mainIndex];
//       productModel.isAvailable = !isAvailable;
//       productList[mainIndex] = productModel;
//       update();
//       await FireStoreUtils.updateProductIsAvailable(productModel.id!, productModel.isAvailable!);
//     }
//   }
//
//   Future<void> deleteProduct(int index) async {
//     final product = productList[index];
//     await FireStoreUtils.deleteProduct(product);
//     productList.removeAt(index);
//     update();
//   }
//   List<ProductModel> get filteredProductList {
//     if (selectedCategory.value == null) {
//       return productList;
//     }
//     final selectedId = selectedCategory.value!.id?.toString() ?? '';
//     if (selectedId.isEmpty) return productList;
//     return productList
//         .where((product) => (product.categoryID?.toString() ?? '') == selectedId)
//         .toList();
//   }
//
//
//   Future<void> toggleCategoryActive(int index) async {
//     final category = categoryList[index];
//     final newStatus = !(category.isActive ?? true);
//     final categoryId = category.id;
//     if (AppConfig.enableDebugLogs) {
//       // ignore: avoid_print
//       print("toggleCategoryActive $index");
//     }
//     categoryList[index] = VendorCategoryModel(
//       reviewAttributes: category.reviewAttributes,
//       photo: category.photo,
//       description: category.description,
//       id: category.id,
//       title: category.title,
//       isActive: newStatus,
//     );
//     for (int i = 0; i < productList.length; i++) {
//       if ((productList[i].categoryID?.toString() ?? '') == (categoryId?.toString() ?? '')) {
//         productList[i].isAvailable = newStatus;
//       }
//     }
//     productList.value = List.from(productList);
//     update();
//     await FireStoreUtils.updateCategoryIsActive(category.id!, newStatus);
//     await FireStoreUtils.setAllProductsAvailabilityForCategory(
//       category.id!,
//       newStatus,
//     );
//     FireStoreUtils.invalidateProductCache(Constant.userModel?.vendorID);
//   }
//   // Future<void> toggleCategoryActive(int index) async {
//   //   final category = categoryList[index];
//   //   final newStatus = !(category.isActive ?? true);
//   //   print("toggleCategoryActive ${newStatus} ");
//   //   // Update category in local list immediately
//   //   categoryList[index] = VendorCategoryModel(
//   //     reviewAttributes: category.reviewAttributes,
//   //     photo: category.photo,
//   //     description: category.description,
//   //     id: category.id,
//   //     title: category.title,
//   //     isActive: newStatus,
//   //   );
//   //   // for (var product in productList) {
//   //   //   if (product.categoryID == category.id) {
//   //   //     product.isAvailable = newStatus;
//   //   //   }
//   //   // }
//   //   productList.value = List.from(productList);
//   //   update();
//   //   try {
//   //     // Sync with server
//   //     await FireStoreUtils.updateCategoryIsActive(category.id!, newStatus);
//   //     await FireStoreUtils.setAllProductsAvailabilityForCategory(category.id!, newStatus);
//   //     await Future.delayed(Duration(milliseconds: 500));
//   //     await getProduct();
//   //     getCategories();
//   //   } catch (e) {
//   //     print('Error toggling category active: $e');
//   //     // Revert local changes on error
//   //     categoryList[index] = category;
//   //     await getProduct(); // Refresh to get correct state from server
//   //     getCategories();
//   //     rethrow;
//   //   }
//   // }
// }



import 'package:get/get.dart';
import 'package:jippymart_restaurant/config/app_config.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class ProductListController extends GetxController {
  // ── Observables ────────────────────────────────────────────────────────────
  final Rx<UserModel> userModel = UserModel().obs;
  final RxBool isLoading = true.obs;
  final RxList<ProductModel> productList = <ProductModel>[].obs;
  final RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
  final Rx<VendorCategoryModel?> selectedCategory =
  Rx<VendorCategoryModel?>(null);

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  // ── Computed (no extra storage) ────────────────────────────────────────────
  List<ProductModel> get filteredProductList {
    final catId = selectedCategory.value?.id?.toString() ?? '';
    if (catId.isEmpty) return productList;
    return productList
        .where((p) => (p.categoryID?.toString() ?? '') == catId)
        .toList();
  }

  // ── Data loading ───────────────────────────────────────────────────────────
  Future<void> getUserProfile() async {
    try {
      final uid = await FireStoreUtils.getCurrentUid();
      final profile = await FireStoreUtils.getUserProfile(uid);
      if (profile != null) {
        Constant.userModel = profile;
        userModel.value = profile;
      }
      await getProduct();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProduct() async {
    final value = await FireStoreUtils.getProduct();
    if (value != null) productList.value = value;
    await _syncCategories();
  }

  Future<void> _syncCategories() async {
    if (productList.isEmpty) return;

    final usedIds = productList
        .map((p) => p.categoryID?.toString())
        .whereType<String>()
        .where((s) => s.isNotEmpty)
        .toSet();

    final remote = await FireStoreUtils.getVendorCategoryById();

    if (remote != null && remote.isNotEmpty) {
      final list = usedIds.isEmpty
          ? remote
          : remote.where((c) {
        final id = c.id?.toString() ?? '';
        return id.isNotEmpty && usedIds.contains(id);
      }).toList();
      list.sort((a, b) => (a.title ?? '')
          .toLowerCase()
          .compareTo((b.title ?? '').toLowerCase()));
      categoryList.value = list;
      return;
    }

    // Fallback: synthesise placeholder categories from product data
    if (usedIds.isNotEmpty) {
      categoryList.value = usedIds
          .map((id) =>
          VendorCategoryModel(id: id, title: 'Category', isActive: true))
          .toList()
        ..sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
    }
  }

  // ── Product mutations ──────────────────────────────────────────────────────
  Future<void> updateList(String productId, bool currentPublish) async {
    final idx = productList.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    productList[idx].publish = !currentPublish;
    productList.refresh();
    await FireStoreUtils.setProduct(productList[idx]);
  }

  Future<void> updateAvailableStatus(
      String productId, bool currentAvailable) async {
    final idx = productList.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    final toggled = !currentAvailable;
    productList[idx].isAvailable = toggled;
    productList.refresh();
    await FireStoreUtils.updateProductIsAvailable(productId, toggled);
  }

  Future<void> deleteProduct(int index) async {
    final product = productList[index];
    await FireStoreUtils.deleteProduct(product);
    productList.removeAt(index);
  }

  // ── Category mutations ─────────────────────────────────────────────────────
  Future<void> toggleCategoryActive(int index) async {
    final cat = categoryList[index];
    final newStatus = !(cat.isActive ?? true);
    _log('toggleCategoryActive idx=$index newStatus=$newStatus');

    // Optimistic local update
    categoryList[index] = VendorCategoryModel(
      id: cat.id,
      title: cat.title,
      photo: cat.photo,
      description: cat.description,
      reviewAttributes: cat.reviewAttributes,
      isActive: newStatus,
    );
    final catId = cat.id?.toString() ?? '';
    for (int i = 0; i < productList.length; i++) {
      if ((productList[i].categoryID?.toString() ?? '') == catId) {
        productList[i].isAvailable = newStatus;
      }
    }
    productList.refresh();

    // Persist both changes in parallel
    await Future.wait([
      FireStoreUtils.updateCategoryIsActive(cat.id!, newStatus),
      FireStoreUtils.setAllProductsAvailabilityForCategory(cat.id!, newStatus),
    ]);
    FireStoreUtils.invalidateProductCache(Constant.userModel?.vendorID);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _log(String msg) {
    if (AppConfig.enableDebugLogs) {
      // ignore: avoid_print
      print('ProductListController.$msg');
    }
  }
}