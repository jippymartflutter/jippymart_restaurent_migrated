import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/add_from_catalog_controller.dart';
import 'package:jippymart_restaurant/models/master_product_model.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';

/// Reusable catalog flow body: category → master products → select → save.
/// Used by both AddFromCatalogScreen and AddProductScreen.
class AddFromCatalogBody extends StatelessWidget {
  const AddFromCatalogBody({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<AddFromCatalogController>(
      init: AddFromCatalogController(),
      builder: (c) {
        if (c.isLoading.value) return Constant.loader();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Category'.tr, style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                  const SizedBox(height: 6),
                  DropdownSearch<VendorCategoryModel>(
                    items: c.categoryList,
                    itemAsString: (VendorCategoryModel item) => item.title ?? '',
                    selectedItem: c.selectedCategory.value,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Select category'.tr,
                        filled: true,
                        fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    onChanged: (v) => c.selectCategory(v),
                    popupProps: PopupProps.menu(showSearchBox: true),
                  ),
                  if (c.selectedCategory.value != null) ...[
                    const SizedBox(height: 8),
                    TextFieldWidget(
                      title: 'Search products'.tr,
                      hintText: 'Product name...'.tr,
                      onchange: (v) => c.setSearch(v),
                    ),
                    Row(
                      children: [
                        Expanded(child: RoundedButtonFill(title: 'Search'.tr, color: ColorConst.orange, width: 40, height: 5, textColor: AppThemeData.grey50, onPress: () => c.searchProducts())),
                        const SizedBox(width: 8),
                        Expanded(child: RoundedButtonFill(title: 'Load'.tr, color: AppThemeData.secondary300, width: 40, height: 5, textColor: AppThemeData.grey50, onPress: () => c.loadMasterProducts())),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (c.selectedCategory.value == null)
              Expanded(child: Center(child: Text('Select a category to load products.'.tr, style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600))))
            else
              Expanded(
                child: c.isLoadingProducts.value
                    ? Constant.loader()
                    : c.masterProducts.isEmpty
                        ? Center(child: Text('No products in this category.'.tr, style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: c.masterProducts.length,
                            itemBuilder: (context, index) => _ProductCard(themeChange: themeChange, product: c.masterProducts[index], controller: c),
                          ),
              ),
            AddFromCatalogBody._buildPagination(c, themeChange),
            AddFromCatalogBody._buildBottomBar(context, c, themeChange),
          ],
        );
      },
    );
  }

  static Widget _buildPagination(AddFromCatalogController c, DarkThemeProvider themeChange) {
    if (c.lastPage.value <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: c.currentPage.value > 1 ? () => c.goToPage(c.currentPage.value - 1) : null,
          ),
          Text('${c.currentPage.value} / ${c.lastPage.value}', style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: c.currentPage.value < c.lastPage.value ? () => c.goToPage(c.currentPage.value + 1) : null,
          ),
        ],
      ),
    );
  }

  static Widget _buildBottomBar(BuildContext context, AddFromCatalogController c, DarkThemeProvider themeChange) {
    final count = c.selectedProducts.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50),
      child: SafeArea(
        child: Row(
          children: [
            Text('$count selected'.tr, style: TextStyle(fontFamily: AppThemeData.semiBold, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
            const SizedBox(width: 16),
            Expanded(
              child: RoundedButtonFill(
                title: 'Save'.tr,
                color: ColorConst.orange,
                width: 60,
                height: 5.5,
                textColor: AppThemeData.grey50,
                onPress: () async {
                        if (count == 0) return;
                        final err = c.validateForSave();
                        if (err != null) {
                          ShowToastDialog.showToast(err);
                          return;
                        }
                        ShowToastDialog.showLoader('Saving...'.tr);
                        final ok = await c.saveAndCaptureResponse();
                        ShowToastDialog.closeLoader();
                        if (ok) {
                          ShowToastDialog.showToast(c.lastStoreResponse?.message ?? 'Successfully imported.'.tr);
                          Get.back(result: true);
                        } else {
                          final msg = c.lastStoreResponse?.message ?? 'Save failed.'.tr;
                          final errors = c.lastStoreResponse?.errors;
                          String show = msg;
                          if (errors != null && errors.isNotEmpty) {
                            final first = errors.entries.first;
                            show = '${first.value is List ? (first.value as List).join(' ') : first.value}';
                          }
                          ShowToastDialog.showToast(show);
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddFromCatalogScreen extends StatelessWidget {
  const AddFromCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.orange,
        title: Text('Add from catalog'.tr, style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium)),
        iconTheme: const IconThemeData(color: AppThemeData.grey50),
      ),
      body: const AddFromCatalogBody(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final DarkThemeProvider themeChange;
  final MasterProductModel product;
  final AddFromCatalogController controller;

  const _ProductCard({required this.themeChange, required this.product, required this.controller});

  @override
  Widget build(BuildContext context) {
    final id = product.id ?? '';
    final isSelected = controller.isSelected(id);
    final sel = controller.selectedProducts[id];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageWidget(
                    imageUrl: product.photo ?? '',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.isExisting == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Chip(label: Text('Already added'.tr, style: const TextStyle(fontSize: 11)), backgroundColor: AppThemeData.success400.withValues(alpha: 0.3)),
                        ),
                      Text(product.name ?? '', style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 16, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900)),
                      if (product.description != null && product.description!.isNotEmpty)
                        Text(product.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => controller.toggleSelection(product),
                  activeColor: ColorConst.orange,
                ),
              ],
            ),
            if (isSelected && sel != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _PriceField(
                      label: 'Your price'.tr,
                      value: sel.merchantPrice,
                      onChanged: (v) => controller.updateMerchantPrice(id, v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Expanded(
                  //   child: _PriceField(
                  //     label: 'Online price'.tr,
                  //     value: sel.onlinePrice,
                  //     onChanged: (v) => controller.updateOnlinePrice(id, v),
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  // Expanded(
                  //   child: _PriceField(
                  //     label: 'Discount'.tr,
                  //     value: sel.discountPrice,
                  //     onChanged: (v) => controller.updateDiscountPrice(id, v),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Publish'.tr, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)),
                  CupertinoSwitch(value: sel.publish, onChanged: (v) => controller.setPublish(id, v), activeColor: ColorConst.orange),
                  const SizedBox(width: 16),
                  Text('Available'.tr, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600)),
                  CupertinoSwitch(value: sel.isAvailable, onChanged: (v) => controller.setAvailable(id, v), activeColor: ColorConst.orange),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showOptionsSheet(context, controller, id, sel, themeChange),
                    icon: const Icon(Icons.tune, size: 18),
                    label: Text('Options'.tr),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAvailabilitySheet(context, controller, id, sel, themeChange),
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text('Availability'.tr),
                  ),
                ],
              ),
              if (sel.addons.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Add-ons: ${sel.addons.length}'.tr, style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _PriceField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        TextFormField(
          key: ValueKey('$label-$value'),
          initialValue: value.toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
          onChanged: (t) {
            final v = double.tryParse(t);
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

void _showOptionsSheet(BuildContext context, AddFromCatalogController c, String masterId, SelectedProductModel sel, DarkThemeProvider themeChange) {
  final options = List<OptionItem>.from(sel.options);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scroll) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Product options'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (_, index) {
                      final o = options[index];
                      return ListTile(
                        title: Text(o.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: o.price,
                                keyboardType: TextInputType.number,
                                onChanged: (v) => options[index] = OptionItem(id: o.id, title: o.title, price: v, originalPrice: o.originalPrice, isAvailable: o.isAvailable),
                              ),
                            ),
                            Checkbox(
                              value: o.isAvailable,
                              onChanged: (v) {
                                options[index] = OptionItem(id: o.id, title: o.title, price: o.price, originalPrice: o.originalPrice, isAvailable: v ?? true);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                RoundedButtonFill(
                  title: 'Done'.tr,
                  color: ColorConst.orange,
                  width: 50,
                  height: 5,
                  textColor: AppThemeData.grey50,
                  onPress: () {
                    c.setOptions(masterId, options);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void _showAvailabilitySheet(BuildContext context, AddFromCatalogController c, String masterId, SelectedProductModel sel, DarkThemeProvider themeChange) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  var selectedDays = List<String>.from(sel.availableDays);
  var timings = <String, List<TimeRangeItem>>{};
  for (final e in sel.availableTimings.entries) {
    timings[e.key] = List.from(e.value);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scroll) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Available days & times'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: days.map((d) {
                    final checked = selectedDays.contains(d);
                    return FilterChip(
                      label: Text(d),
                      selected: checked,
                      onSelected: (v) {
                        if (v) {
                          selectedDays.add(d);
                          if (!timings.containsKey(d)) timings[d] = [TimeRangeItem(from: '09:00', to: '22:00')];
                        } else {
                          selectedDays.remove(d);
                          timings.remove(d);
                        }
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: selectedDays.map((d) {
                      final slots = timings[d] ?? [TimeRangeItem(from: '09:00', to: '22:00')];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...slots.asMap().entries.map((e) => Row(
                              children: [
                                SizedBox(width: 70, child: TextFormField(initialValue: e.value.from, decoration: const InputDecoration(labelText: 'From'), onChanged: (v) => slots[e.key] = TimeRangeItem(from: v, to: slots[e.key].to))),
                                const SizedBox(width: 8),
                                SizedBox(width: 70, child: TextFormField(initialValue: e.value.to, decoration: const InputDecoration(labelText: 'To'), onChanged: (v) => slots[e.key] = TimeRangeItem(from: slots[e.key].from, to: v))),
                              ],
                            )),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                RoundedButtonFill(
                  title: 'Done'.tr,
                  color: ColorConst.orange,
                  width: 50,
                  height: 5,
                  textColor: AppThemeData.grey50,
                  onPress: () {
                    c.setAvailableDays(masterId, selectedDays);
                    c.setAvailableTimings(masterId, timings);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
