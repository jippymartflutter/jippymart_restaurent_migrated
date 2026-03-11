import 'package:get/get.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/service/food_api_service.dart' show FoodApiService, BulkStoreResponse;
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/pricing_calculator.dart';

class AddFromCatalogController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isLoadingProducts = false.obs;
  RxBool isSaving = false.obs;

  RxList<VendorCategoryModel> categoryList = <VendorCategoryModel>[].obs;
  Rx<VendorCategoryModel?> selectedCategory = Rx<VendorCategoryModel?>(null);

  RxList<MasterProductModel> masterProducts = <MasterProductModel>[].obs;
  RxInt currentPage = 1.obs;
  RxInt lastPage = 1.obs;
  RxInt totalProducts = 0.obs;
  static const int perPage = 10;
  RxString searchQuery = ''.obs;

  /// Selected products keyed by master product id. Value holds form data for store.
  final selectedProducts = <String, SelectedProductModel>{}.obs;

  /// Pricing params (from vendor profile or defaults)
  RxBool hasSubscription = false.obs;
  RxString planType = 'commission'.obs;
  RxInt applyPercentage = 30.obs;
  RxBool gstAgreed = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      final list = await FireStoreUtils.getVendorCategoryById();
      if (list != null && list.isNotEmpty) {
        categoryList.value = list;
      } else {
        categoryList.clear();
      }
    } catch (e) {
      categoryList.clear();
    }
    isLoading.value = false;
  }

  Future<void> selectCategory(VendorCategoryModel? category) async {
    selectedCategory.value = category;
    if (category == null || category.id == null || category.id!.isEmpty) {
      masterProducts.clear();
      selectedProducts.clear();
      return;
    }
    currentPage.value = 1;
    await loadMasterProducts();
  }

  Future<void> loadMasterProducts({bool append = false}) async {
    final cat = selectedCategory.value;
    if (cat?.id == null) return;
    if (!append) isLoadingProducts.value = true;
    try {
      final res = await FoodApiService.getMasterProductsByCategory(
        cat!.id!,
        page: currentPage.value,
        perPage: perPage,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      if (res != null) {
        if (!append) masterProducts.assignAll(res.products);
        if (res.pagination != null) {
          lastPage.value = res.pagination!.lastPage;
          totalProducts.value = res.pagination!.total;
        }
      }
    } catch (_) {}
    isLoadingProducts.value = false;
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }

  Future<void> searchProducts() async {
    currentPage.value = 1;
    await loadMasterProducts();
  }

  void goToPage(int page) {
    if (page < 1 || page > lastPage.value) return;
    currentPage.value = page;
    loadMasterProducts();
  }

  bool isSelected(String masterProductId) => selectedProducts.containsKey(masterProductId);

  void toggleSelection(MasterProductModel product) {
    if (product.id == null) return;
    final id = product.id!;
    if (selectedProducts.containsKey(id)) {
      selectedProducts.remove(id);
      return;
    }
    double merchant = 0;
    double online = 0;
    double discount = 0;
    bool publish = true;
    bool available = true;
    List<AddonItem> addons = [];
    List<String> days = [];
    Map<String, List<TimeRangeItem>> timings = {};
    List<OptionItem> options = [];

    if (product.isExisting == true) {
      merchant = double.tryParse(product.vendorMerchantPrice ?? '') ?? (product.suggestedPrice ?? 0);
      online = double.tryParse(product.vendorPrice ?? '') ?? merchant;
      discount = double.tryParse(product.vendorDisPrice ?? '') ?? 0;
      publish = product.vendorPublish ?? true;
      available = product.vendorIsAvailable ?? true;
      if (product.vendorAddOnsTitle != null && product.vendorAddOnsPrice != null) {
        for (var i = 0; i < product.vendorAddOnsTitle!.length; i++) {
          if (i < product.vendorAddOnsPrice!.length) {
            addons.add(AddonItem(title: product.vendorAddOnsTitle![i], price: product.vendorAddOnsPrice![i]));
          }
        }
      }
      if (product.vendorAvailableDays != null) days = List.from(product.vendorAvailableDays!);
      if (product.vendorAvailableTimings != null) {
        for (final t in product.vendorAvailableTimings!) {
          if (t.day != null && t.timeslot != null) {
            timings[t.day!] = t.timeslot!.map((s) => TimeRangeItem(from: s.from ?? '', to: s.to ?? '')).toList();
          }
        }
      }
      if (product.vendorOptions != null) {
        for (final o in product.vendorOptions!) {
          options.add(OptionItem(id: o.id ?? '', title: o.title ?? '', price: o.price ?? '0', isAvailable: o.isAvailable ?? true));
        }
      }
    } else {
      merchant = product.suggestedPrice ?? 0;
      online = PricingCalculator.calculateOnlinePrice(
        merchantPrice: merchant,
        hasSubscription: hasSubscription.value,
        planType: planType.value,
        applyPercentage: applyPercentage.value,
        gstAgreed: gstAgreed.value,
      );
      if (product.options != null && product.options!.isNotEmpty) {
        for (final o in product.options!) {
          options.add(OptionItem(
            id: o.id ?? '',
            title: o.title ?? '',
            price: (o.price ?? 0).toString(),
            originalPrice: (o.price ?? 0).toString(),
            isAvailable: true,
          ));
        }
      }
    }

    selectedProducts[id] = SelectedProductModel(
      masterProductId: id,
      vendorProductId: product.vendorProductId,
      merchantPrice: merchant,
      onlinePrice: online,
      discountPrice: discount,
      publish: publish,
      isAvailable: available,
      addons: addons,
      availableDays: days,
      availableTimings: timings,
      options: options,
    );
  }

  void updateMerchantPrice(String masterProductId, double value) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.merchantPrice = value;
    sel.onlinePrice = PricingCalculator.calculateOnlinePrice(
      merchantPrice: value,
      hasSubscription: hasSubscription.value,
      planType: planType.value,
      applyPercentage: applyPercentage.value,
      gstAgreed: gstAgreed.value,
    );
    selectedProducts.refresh();
  }

  void updateOnlinePrice(String masterProductId, double value) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.onlinePrice = value;
    selectedProducts.refresh();
  }

  void updateDiscountPrice(String masterProductId, double value) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.discountPrice = value;
    selectedProducts.refresh();
  }

  void setPublish(String masterProductId, bool value) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.publish = value;
    selectedProducts.refresh();
  }

  void setAvailable(String masterProductId, bool value) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.isAvailable = value;
    selectedProducts.refresh();
  }

  void setAddons(String masterProductId, List<AddonItem> addons) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.addons = addons;
    selectedProducts.refresh();
  }

  void setAvailableDays(String masterProductId, List<String> days) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.availableDays = days;
    selectedProducts.refresh();
  }

  void setAvailableTimings(String masterProductId, Map<String, List<TimeRangeItem>> timings) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.availableTimings = timings;
    selectedProducts.refresh();
  }

  void setOptions(String masterProductId, List<OptionItem> options) {
    final sel = selectedProducts[masterProductId];
    if (sel == null) return;
    sel.options = options;
    selectedProducts.refresh();
  }

  String? validateForSave() {
    if (selectedProducts.isEmpty) return 'Please select at least one product.';
    for (final e in selectedProducts.entries) {
      if (e.value.merchantPrice <= 0) return 'Merchant price must be greater than 0 for "${e.key}".';
      if (e.value.discountPrice > e.value.onlinePrice) return 'Discount price cannot be greater than online price.';
    }
    return null;
  }

  Future<bool> save() async {
    final err = validateForSave();
    if (err != null) return false;
    isSaving.value = true;
    try {
      final list = selectedProducts.values.toList();
      final res = await FoodApiService.bulkStoreProducts(list);
      isSaving.value = false;
      if (res.success) {
        return true;
      }
      return false;
    } catch (_) {
      isSaving.value = false;
      return false;
    }
  }

  BulkStoreResponse? lastStoreResponse;

  Future<bool> saveAndCaptureResponse() async {
    final err = validateForSave();
    if (err != null) {
      lastStoreResponse = BulkStoreResponse(success: false, message: err, imported: 0, errors: null, statusCode: 0);
      return false;
    }
    isSaving.value = true;
    lastStoreResponse = null;
    try {
      final list = selectedProducts.values.toList();
      final res = await FoodApiService.bulkStoreProducts(list);
      lastStoreResponse = res;
      isSaving.value = false;
      return res.success;
    } catch (e) {
      lastStoreResponse = BulkStoreResponse(success: false, message: e.toString(), imported: 0, errors: null, statusCode: 0);
      isSaving.value = false;
      return false;
    }
  }
}
