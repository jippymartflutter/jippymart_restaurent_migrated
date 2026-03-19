// import 'dart:io';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:jippymart_restaurant/utils/const/color_const.dart';
// import 'package:provider/provider.dart';
// import 'package:jippymart_restaurant/constant/constant.dart';
// import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
// import 'package:jippymart_restaurant/controller/add_product_controller.dart';
// import 'package:jippymart_restaurant/models/AttributesModel.dart';
// import 'package:jippymart_restaurant/models/product_model.dart';
// import 'package:jippymart_restaurant/models/vendor_category_model.dart';
// import 'package:jippymart_restaurant/themes/app_them_data.dart';
// import 'package:jippymart_restaurant/themes/responsive.dart';
// import 'package:jippymart_restaurant/themes/round_button_fill.dart';
// import 'package:jippymart_restaurant/themes/text_field_widget.dart';
// import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
// import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
// import 'package:jippymart_restaurant/utils/network_image_widget.dart';
// import 'package:jippymart_restaurant/models/selected_product_model.dart';
//
// class EditProductScreen extends StatefulWidget {
//   final ProductModel? product;
//
//   const EditProductScreen({super.key, this.product});
//
//   @override
//   State<EditProductScreen> createState() => _EditProductScreenState();
// }
//
// class _EditProductScreenState extends State<EditProductScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context);
//     return SafeArea(
//       child: GetX<AddProductController>(
//           init: AddProductController(productToEdit: widget.product),
//           builder: (controller) {
//             return controller.isLoading.value
//                 ? Constant.loader()
//                 : SafeArea(
//                   child: Scaffold(
//                       appBar: AppBar(
//                         backgroundColor: AppThemeData.secondary300,
//                         centerTitle: false,
//                         iconTheme: const IconThemeData(color: AppThemeData.grey50),
//                         title: Text(
//                           controller.productModel.value.id == null
//                               ? "Add Product".tr
//                               : "Edit product".tr,
//                           style: TextStyle(
//                               color: themeChange.getThem()
//                                   ? AppThemeData.grey50
//                                   : AppThemeData.grey50,
//                               fontSize: 18,
//                               fontFamily: AppThemeData.medium),
//                         ),
//                       ),
//                       body: SafeArea(
//                         child: Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   decoration: ShapeDecoration(
//                                     color: themeChange.getThem()
//                                         ? AppThemeData.danger600
//                                         : AppThemeData.danger50,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   // child: Padding(
//                                   //   padding: const EdgeInsets.all(8.0),
//                                   //   child: Text(
//                                   //     "Product prices include a 15% admin commission. For instance, a \$100 product will cost \$115 for the customer. 15% will be applied automatically."
//                                   //         .tr,
//                                   //     style: TextStyle(
//                                   //         color: themeChange.getThem()
//                                   //             ? AppThemeData.danger200
//                                   //             : AppThemeData.danger400,
//                                   //         fontSize: 14,
//                                   //         fontFamily: AppThemeData.medium),
//                                   //   ),
//                                   // ),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 DottedBorder(
//                                   borderType: BorderType.RRect,
//                                   radius: const Radius.circular(12),
//                                   dashPattern: const [6, 6, 6, 6],
//                                   color: themeChange.getThem()
//                                       ? AppThemeData.grey700
//                                       : AppThemeData.grey200,
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: themeChange.getThem()
//                                           ? AppThemeData.grey900
//                                           : AppThemeData.grey50,
//                                       borderRadius: const BorderRadius.all(
//                                         Radius.circular(12),
//                                       ),
//                                     ),
//                                     child: SizedBox(
//                                         height: Responsive.height(20, context),
//                                         width: Responsive.width(90, context),
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           mainAxisAlignment: MainAxisAlignment.center,
//                                           children: [
//                                             SvgPicture.asset(
//                                               'assets/icons/ic_folder.svg',
//                                             ),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             Text(
//                                               "Choose a image and upload here".tr,
//                                               style: TextStyle(
//                                                   color: themeChange.getThem()
//                                                       ? AppThemeData.grey100
//                                                       : AppThemeData.grey800,
//                                                   fontFamily: AppThemeData.medium,
//                                                   fontSize: 16),
//                                             ),
//                                             const SizedBox(
//                                               height: 5,
//                                             ),
//                                             Text(
//                                               "JPEG, PNG".tr,
//                                               style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: themeChange.getThem()
//                                                       ? AppThemeData.grey200
//                                                       : AppThemeData.grey700,
//                                                   fontFamily: AppThemeData.regular),
//                                             ),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             RoundedButtonFill(
//                                               title: "Brows Image".tr,
//                                               color: ColorConst.orange,
//                                               width: 30,
//                                               height: 5,
//                                               textColor: AppThemeData.grey50,
//                                               onPress: () async {
//                                                 buildBottomSheet(context, controller);
//                                               },
//                                             ),
//                                           ],
//                                         )),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 controller.images.isEmpty
//                                     ? const SizedBox()
//                                     : SizedBox(
//                                         height: 80,
//                                         child: ListView.builder(
//                                           itemCount: controller.images.length,
//                                           shrinkWrap: true,
//                                           scrollDirection: Axis.horizontal,
//                                           physics:
//                                               const NeverScrollableScrollPhysics(),
//                                           itemBuilder: (context, index) {
//                                             return Padding(
//                                               padding: const EdgeInsets.symmetric(
//                                                   horizontal: 5),
//                                               child: Stack(
//                                                 children: [
//                                                   ClipRRect(
//                                                     borderRadius:
//                                                         const BorderRadius.all(
//                                                             Radius.circular(10)),
//                                                     child: controller.images[index]
//                                                                 .runtimeType ==
//                                                             XFile
//                                                         ? Image.file(
//                                                             File(controller
//                                                                 .images[index].path),
//                                                             fit: BoxFit.cover,
//                                                             width: 80,
//                                                             height: 80,
//                                                           )
//                                                         : NetworkImageWidget(
//                                                             imageUrl: controller
//                                                                 .images[index],
//                                                             fit: BoxFit.cover,
//                                                             width: 80,
//                                                             height: 80,
//                                                           ),
//                                                   ),
//                                                   Positioned(
//                                                     bottom: 0,
//                                                     top: 0,
//                                                     left: 0,
//                                                     right: 0,
//                                                     child: InkWell(
//                                                       onTap: () {
//                                                         controller.images
//                                                             .removeAt(index);
//                                                       },
//                                                       child: const Icon(
//                                                         Icons.remove_circle,
//                                                         size: 28,
//                                                         color: AppThemeData.danger300,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 TextFieldWidget(
//                                   title: 'Product Title'.tr,
//                                   controller: controller.productTitleController.value,
//                                   hintText: 'Enter product title'.tr,
//                                 ),
//                                 Column(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text("Product Categories".tr,
//                                         style: TextStyle(
//                                             fontFamily: AppThemeData.semiBold,
//                                             fontSize: 14,
//                                             color: themeChange.getThem()
//                                                 ? AppThemeData.grey100
//                                                 : AppThemeData.grey800)),
//                                     const SizedBox(
//                                       height: 5,
//                                     ),
//                         SafeArea(
//                           child: DropdownSearch<VendorCategoryModel>(
//                             popupProps: PopupProps.menu(
//                               showSearchBox: true,
//                               searchFieldProps: TextFieldProps(
//                                 decoration: InputDecoration(
//                                   hintText: "Search Category",
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                               ),
//                               itemBuilder: (context, item, isSelected) {
//                                 return ListTile(
//                                   title: Text(item.title ?? ""),
//                                 );
//                               },
//                             ),
//
//                             items: controller.vendorCategoryList,
//
//                             // 🔥 FIX: Show text instead of instance
//                             itemAsString: (VendorCategoryModel item) => item.title ?? "",
//
//                             selectedItem: controller.selectedProductCategory.value.id == null
//                                 ? null
//                                 : controller.selectedProductCategory.value,
//
//                             dropdownDecoratorProps: DropDownDecoratorProps(
//                               dropdownSearchDecoration: InputDecoration(
//                                 hintText: "Select Product Categories",
//                                 filled: true,
//                                 fillColor: themeChange.getThem()
//                                     ? AppThemeData.grey900
//                                     : AppThemeData.grey50,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             ),
//
//                             onChanged: (value) {
//                               controller.selectedProductCategory.value = value!;
//                               controller.update();
//                             },
//                           ),
//                         ),
//
//                         const SizedBox(
//                                       height: 10,
//                                     ),
//                                   ],
//                                 ),
//                                 TextFieldWidget(
//                                   title: 'Product Description'.tr,
//                                   controller:
//                                       controller.productDescriptionController.value,
//                                   hintText: 'Enter short description here....'.tr,
//                                   maxLine: 5,
//                                 ),
//                                 // Text(
//                                 //   "Attributes and Prices".tr,
//                                 //   style: TextStyle(
//                                 //       color: themeChange.getThem()
//                                 //           ? AppThemeData.grey50
//                                 //           : AppThemeData.grey900,
//                                 //       fontFamily: AppThemeData.medium,
//                                 //       fontSize: 18),
//                                 // ),
//                                 // const SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 // Column(
//                                 //   crossAxisAlignment: CrossAxisAlignment.start,
//                                 //   children: [
//                                 //     Text(
//                                 //       "Attributes".tr,
//                                 //       style: TextStyle(
//                                 //         fontFamily: AppThemeData.semiBold,
//                                 //         fontSize: 14,
//                                 //         color: themeChange.getThem()
//                                 //             ? AppThemeData.grey100
//                                 //             : AppThemeData.grey800,
//                                 //       ),
//                                 //     ),
//                                 //     const SizedBox(
//                                 //       height: 5,
//                                 //     ),
//                                 //     DropdownSearch<AttributesModel>.multiSelection(
//                                 //       items: controller.attributesList,
//                                 //       key: controller.myKey1,
//                                 //       dropdownButtonProps: DropdownButtonProps(
//                                 //         focusColor: AppThemeData.secondary300,
//                                 //         color: AppThemeData.secondary300,
//                                 //         icon: const Icon(
//                                 //           Icons.keyboard_arrow_down,
//                                 //           color: AppThemeData.grey800,
//                                 //         ),
//                                 //       ),
//                                 //       dropdownDecoratorProps: DropDownDecoratorProps(
//                                 //         dropdownSearchDecoration: InputDecoration(
//                                 //             contentPadding: const EdgeInsets.only(
//                                 //                 left: 8, right: 8),
//                                 //             disabledBorder: UnderlineInputBorder(
//                                 //               borderRadius: const BorderRadius.all(
//                                 //                   Radius.circular(10)),
//                                 //               borderSide: BorderSide(
//                                 //                   color: themeChange.getThem()
//                                 //                       ? AppThemeData.grey900
//                                 //                       : AppThemeData.grey50,
//                                 //                   width: 1),
//                                 //             ),
//                                 //             focusedBorder: OutlineInputBorder(
//                                 //               borderRadius: const BorderRadius.all(
//                                 //                   Radius.circular(10)),
//                                 //               borderSide: BorderSide(
//                                 //                   color: themeChange.getThem()
//                                 //                       ? AppThemeData.secondary300
//                                 //                       : AppThemeData.secondary300,
//                                 //                   width: 1),
//                                 //             ),
//                                 //             enabledBorder: OutlineInputBorder(
//                                 //               borderRadius: const BorderRadius.all(
//                                 //                   Radius.circular(10)),
//                                 //               borderSide: BorderSide(
//                                 //                   color: themeChange.getThem()
//                                 //                       ? AppThemeData.grey900
//                                 //                       : AppThemeData.grey50,
//                                 //                   width: 1),
//                                 //             ),
//                                 //             errorBorder: OutlineInputBorder(
//                                 //               borderRadius: const BorderRadius.all(
//                                 //                   Radius.circular(10)),
//                                 //               borderSide: BorderSide(
//                                 //                   color: themeChange.getThem()
//                                 //                       ? AppThemeData.grey900
//                                 //                       : AppThemeData.grey50,
//                                 //                   width: 1),
//                                 //             ),
//                                 //             border: OutlineInputBorder(
//                                 //               borderRadius: const BorderRadius.all(
//                                 //                   Radius.circular(10)),
//                                 //               borderSide: BorderSide(
//                                 //                   color: themeChange.getThem()
//                                 //                       ? AppThemeData.grey900
//                                 //                       : AppThemeData.grey50,
//                                 //                   width: 1),
//                                 //             ),
//                                 //             filled: true,
//                                 //             hintStyle: TextStyle(
//                                 //               fontSize: 14,
//                                 //               color: themeChange.getThem()
//                                 //                   ? AppThemeData.grey50
//                                 //                   : AppThemeData.grey900,
//                                 //               fontFamily: AppThemeData.medium,
//                                 //             ),
//                                 //             fillColor: themeChange.getThem()
//                                 //                 ? AppThemeData.grey900
//                                 //                 : AppThemeData.grey50,
//                                 //             hintText: 'Select Attributes'.tr),
//                                 //       ),
//                                 //       compareFn: (i1, i2) => i1.title == i2.title,
//                                 //       popupProps: PopupPropsMultiSelection.menu(
//                                 //         fit: FlexFit.tight,
//                                 //         showSelectedItems: true,
//                                 //         listViewProps: const ListViewProps(
//                                 //             physics: BouncingScrollPhysics(),
//                                 //             padding: EdgeInsets.only(left: 20)),
//                                 //         itemBuilder: (context, item, isSelected) {
//                                 //           return ListTile(
//                                 //             selectedColor: AppThemeData.secondary300,
//                                 //             selected: isSelected,
//                                 //             title: Text(
//                                 //               item.title.toString(),
//                                 //               style: TextStyle(
//                                 //                   color: themeChange.getThem()
//                                 //                       ? AppThemeData.grey50
//                                 //                       : AppThemeData.grey900,
//                                 //                   fontFamily: AppThemeData.medium,
//                                 //                   fontSize: 18),
//                                 //             ),
//                                 //             onTap: () {
//                                 //               controller.myKey1.currentState
//                                 //                   ?.popupValidate([item]);
//                                 //             },
//                                 //           );
//                                 //         },
//                                 //       ),
//                                 //       itemAsString: (AttributesModel u) =>
//                                 //           u.title.toString(),
//                                 //       selectedItems:
//                                 //           controller.selectedAttributesList,
//                                 //       onSaved: (data) {},
//                                 //       onChanged: (data) {
//                                 //         if (controller
//                                 //                 .itemAttributes.value!.attributes !=
//                                 //             null) {
//                                 //           controller.selectedAttributesList.clear();
//                                 //           controller.itemAttributes.value!.attributes!
//                                 //               .clear();
//                                 //           controller.itemAttributes.value!.variants!
//                                 //               .clear();
//                                 //         } else {
//                                 //           controller.itemAttributes.value =
//                                 //               ItemAttribute(
//                                 //                   attributes: [], variants: []);
//                                 //         }
//                                 //         controller.selectedAttributesList
//                                 //             .addAll(data);
//                                 //
//                                 //         for (var element
//                                 //             in controller.selectedAttributesList) {
//                                 //           controller
//                                 //               .addAttribute(element.id.toString());
//                                 //         }
//                                 //         setState(() {});
//                                 //       },
//                                 //     ),
//                                 //     const SizedBox(
//                                 //       height: 10,
//                                 //     ),
//                                 //     controller.itemAttributes.value!.attributes ==
//                                 //                 null ||
//                                 //             controller.itemAttributes.value!
//                                 //                 .attributes!.isEmpty
//                                 //         ? Container()
//                                 //         : Container(
//                                 //             decoration: ShapeDecoration(
//                                 //               color: themeChange.getThem()
//                                 //                   ? AppThemeData.grey900
//                                 //                   : AppThemeData.grey50,
//                                 //               shape: RoundedRectangleBorder(
//                                 //                 borderRadius:
//                                 //                     BorderRadius.circular(12),
//                                 //               ),
//                                 //             ),
//                                 //             child: Padding(
//                                 //               padding: const EdgeInsets.symmetric(
//                                 //                   horizontal: 10, vertical: 10),
//                                 //               child: Column(
//                                 //                 crossAxisAlignment:
//                                 //                     CrossAxisAlignment.start,
//                                 //                 children: [
//                                 //                   Text(
//                                 //                     "Attributes Value".tr,
//                                 //                     style: TextStyle(
//                                 //                       color: themeChange.getThem()
//                                 //                           ? AppThemeData.grey50
//                                 //                           : AppThemeData.grey900,
//                                 //                       fontFamily:
//                                 //                           AppThemeData.semiBold,
//                                 //                       fontSize: 16,
//                                 //                     ),
//                                 //                   ),
//                                 //                   const SizedBox(
//                                 //                     height: 5,
//                                 //                   ),
//                                 //                   ListView.builder(
//                                 //                     itemCount: controller
//                                 //                         .itemAttributes
//                                 //                         .value!
//                                 //                         .attributes!
//                                 //                         .length,
//                                 //                     shrinkWrap: true,
//                                 //                     padding: EdgeInsets.zero,
//                                 //                     physics:
//                                 //                         const NeverScrollableScrollPhysics(),
//                                 //                     itemBuilder: (context, index) {
//                                 //                       String title = "";
//                                 //                       for (var element in controller
//                                 //                           .attributesList) {
//                                 //                         if (controller
//                                 //                                 .itemAttributes
//                                 //                                 .value!
//                                 //                                 .attributes![index]
//                                 //                                 .attributeId ==
//                                 //                             element.id) {
//                                 //                           title = element.title
//                                 //                               .toString();
//                                 //                         }
//                                 //                       }
//                                 //                       return Padding(
//                                 //                         padding:
//                                 //                             const EdgeInsets.all(8.0),
//                                 //                         child: Column(
//                                 //                           crossAxisAlignment:
//                                 //                               CrossAxisAlignment
//                                 //                                   .start,
//                                 //                           children: [
//                                 //                             Row(
//                                 //                               children: [
//                                 //                                 Expanded(
//                                 //                                   child: Text(
//                                 //                                     title,
//                                 //                                     style: TextStyle(
//                                 //                                       color: themeChange.getThem()
//                                 //                                           ? AppThemeData
//                                 //                                               .grey200
//                                 //                                           : AppThemeData
//                                 //                                               .grey700,
//                                 //                                       fontFamily:
//                                 //                                           AppThemeData
//                                 //                                               .medium,
//                                 //                                       fontSize: 16,
//                                 //                                     ),
//                                 //                                   ),
//                                 //                                 ),
//                                 //                                 InkWell(
//                                 //                                   onTap: () {
//                                 //                                     showDialog(
//                                 //                                       context:
//                                 //                                           context,
//                                 //                                       builder:
//                                 //                                           (BuildContext
//                                 //                                               context) {
//                                 //                                         return addAttributeValueDialog(
//                                 //                                             controller,
//                                 //                                             themeChange,
//                                 //                                             index,
//                                 //                                             controller
//                                 //                                                 .itemAttributes
//                                 //                                                 .value!
//                                 //                                                 .attributes![
//                                 //                                                     index]
//                                 //                                                 .attributeId
//                                 //                                                 .toString());
//                                 //                                       },
//                                 //                                     );
//                                 //                                   },
//                                 //                                   child: Icon(
//                                 //                                     Icons.add,
//                                 //                                     color: AppThemeData
//                                 //                                         .secondary300,
//                                 //                                   ),
//                                 //                                 )
//                                 //                               ],
//                                 //                             ),
//                                 //                             Wrap(
//                                 //                               spacing: 4.0,
//                                 //                               runSpacing: 4.0,
//                                 //                               children: List.generate(
//                                 //                                 controller
//                                 //                                     .itemAttributes
//                                 //                                     .value!
//                                 //                                     .attributes![
//                                 //                                         index]
//                                 //                                     .attributeOptions!
//                                 //                                     .length,
//                                 //                                 (i) {
//                                 //                                   return InkWell(
//                                 //                                       onTap: () {
//                                 //                                         controller
//                                 //                                             .itemAttributes
//                                 //                                             .value!
//                                 //                                             .attributes![
//                                 //                                                 index]
//                                 //                                             .attributeOptions!
//                                 //                                             .removeAt(
//                                 //                                                 i);
//                                 //
//                                 //                                         List<List<dynamic>>
//                                 //                                             listArary =
//                                 //                                             [];
//                                 //                                         for (int i =
//                                 //                                                 0;
//                                 //                                             i <
//                                 //                                                 controller
//                                 //                                                     .itemAttributes
//                                 //                                                     .value!
//                                 //                                                     .attributes!
//                                 //                                                     .length;
//                                 //                                             i++) {
//                                 //                                           if (controller
//                                 //                                               .itemAttributes
//                                 //                                               .value!
//                                 //                                               .attributes![
//                                 //                                                   i]
//                                 //                                               .attributeOptions!
//                                 //                                               .isNotEmpty) {
//                                 //                                             listArary.add(controller
//                                 //                                                 .itemAttributes
//                                 //                                                 .value!
//                                 //                                                 .attributes![
//                                 //                                                     i]
//                                 //                                                 .attributeOptions!);
//                                 //                                           }
//                                 //                                         }
//                                 //
//                                 //                                         if (listArary
//                                 //                                             .isNotEmpty) {
//                                 //                                           List<Variants>?
//                                 //                                               variantsTemp =
//                                 //                                               [];
//                                 //                                           List<dynamic>
//                                 //                                               list =
//                                 //                                               getCombination(
//                                 //                                                   listArary);
//                                 //                                           for (var element
//                                 //                                               in list) {
//                                 //                                             bool productIsInList = controller
//                                 //                                                 .itemAttributes
//                                 //                                                 .value!
//                                 //                                                 .variants!
//                                 //                                                 .any((product) =>
//                                 //                                                     product.variantSku ==
//                                 //                                                     element);
//                                 //                                             if (productIsInList) {
//                                 //                                               Variants variant = controller
//                                 //                                                   .itemAttributes
//                                 //                                                   .value!
//                                 //                                                   .variants!
//                                 //                                                   .firstWhere((product) =>
//                                 //                                                       product.variantSku ==
//                                 //                                                       element);
//                                 //                                               Variants variantsModel = Variants(
//                                 //                                                   variantSku:
//                                 //                                                       variant.variantSku,
//                                 //                                                   variantId: variant.variantId,
//                                 //                                                   variantImage: variant.variantImage,
//                                 //                                                   variantPrice: variant.variantPrice,
//                                 //                                                   variantQuantity: variant.variantQuantity);
//                                 //                                               variantsTemp
//                                 //                                                   .add(variantsModel);
//                                 //                                             }
//                                 //                                           }
//                                 //                                           controller
//                                 //                                               .itemAttributes
//                                 //                                               .value!
//                                 //                                               .variants!
//                                 //                                               .clear();
//                                 //                                           controller
//                                 //                                               .itemAttributes
//                                 //                                               .value!
//                                 //                                               .variants!
//                                 //                                               .addAll(
//                                 //                                                   variantsTemp);
//                                 //                                         } else {
//                                 //                                           controller
//                                 //                                               .itemAttributes
//                                 //                                               .value!
//                                 //                                               .variants!
//                                 //                                               .clear();
//                                 //                                         }
//                                 //                                         controller
//                                 //                                             .update();
//                                 //                                         setState(
//                                 //                                             () {});
//                                 //                                       },
//                                 //                                       child: Padding(
//                                 //                                         padding: const EdgeInsets
//                                 //                                             .symmetric(
//                                 //                                             vertical:
//                                 //                                                 10),
//                                 //                                         child: _buildChip(
//                                 //                                             themeChange,
//                                 //                                             controller
//                                 //                                                 .itemAttributes
//                                 //                                                 .value!
//                                 //                                                 .attributes![
//                                 //                                                     index]
//                                 //                                                 .attributeOptions![i],
//                                 //                                             index,
//                                 //                                             i),
//                                 //                                       ));
//                                 //                                 },
//                                 //                               ).toList(),
//                                 //                             ),
//                                 //                           ],
//                                 //                         ),
//                                 //                       );
//                                 //                     },
//                                 //                   ),
//                                 //                   SingleChildScrollView(
//                                 //                     scrollDirection: Axis.horizontal,
//                                 //                     child:
//                                 //                         controller
//                                 //                                 .itemAttributes
//                                 //                                 .value!
//                                 //                                 .variants!
//                                 //                                 .isEmpty
//                                 //                             ? const SizedBox()
//                                 //                             : ClipRRect(
//                                 //                                 borderRadius:
//                                 //                                     const BorderRadius
//                                 //                                         .only(
//                                 //                                         topLeft: Radius
//                                 //                                             .circular(
//                                 //                                                 12),
//                                 //                                         topRight: Radius
//                                 //                                             .circular(
//                                 //                                                 12)),
//                                 //                                 child: DataTable(
//                                 //                                     horizontalMargin:
//                                 //                                         20,
//                                 //                                     columnSpacing: 30,
//                                 //                                     dataRowMaxHeight:
//                                 //                                         70,
//                                 //                                     border:
//                                 //                                         TableBorder
//                                 //                                             .all(
//                                 //                                       color: themeChange.getThem()
//                                 //                                           ? AppThemeData
//                                 //                                               .grey700
//                                 //                                           : AppThemeData
//                                 //                                               .grey200,
//                                 //                                       borderRadius:
//                                 //                                           BorderRadius
//                                 //                                               .circular(
//                                 //                                                   12),
//                                 //                                     ),
//                                 //                                     headingRowColor: WidgetStateColor.resolveWith(
//                                 //                                         (states) => themeChange
//                                 //                                                 .getThem()
//                                 //                                             ? AppThemeData
//                                 //                                                 .surfaceDark
//                                 //                                             : AppThemeData
//                                 //                                                 .surface),
//                                 //                                     columns: [
//                                 //                                       DataColumn(
//                                 //                                         label:
//                                 //                                             SizedBox(
//                                 //                                           width: Responsive
//                                 //                                               .width(
//                                 //                                                   20,
//                                 //                                                   context),
//                                 //                                           child: Text(
//                                 //                                             "Variant"
//                                 //                                                 .tr,
//                                 //                                             style:
//                                 //                                                 TextStyle(
//                                 //                                               fontFamily:
//                                 //                                                   AppThemeData.medium,
//                                 //                                               fontSize:
//                                 //                                                   14,
//                                 //                                               color: themeChange.getThem()
//                                 //                                                   ? AppThemeData.grey300
//                                 //                                                   : AppThemeData.grey600,
//                                 //                                             ),
//                                 //                                           ),
//                                 //                                         ),
//                                 //                                       ),
//                                 //                                       DataColumn(
//                                 //                                         label:
//                                 //                                             SizedBox(
//                                 //                                           width: Responsive
//                                 //                                               .width(
//                                 //                                                   20,
//                                 //                                                   context),
//                                 //                                           child: Text(
//                                 //                                             "Price"
//                                 //                                                 .tr,
//                                 //                                             style:
//                                 //                                                 TextStyle(
//                                 //                                               fontFamily:
//                                 //                                                   AppThemeData.medium,
//                                 //                                               fontSize:
//                                 //                                                   14,
//                                 //                                               color: themeChange.getThem()
//                                 //                                                   ? AppThemeData.grey300
//                                 //                                                   : AppThemeData.grey600,
//                                 //                                             ),
//                                 //                                           ),
//                                 //                                         ),
//                                 //                                       ),
//                                 //                                       DataColumn(
//                                 //                                         label:
//                                 //                                             SizedBox(
//                                 //                                           width: Responsive
//                                 //                                               .width(
//                                 //                                                   20,
//                                 //                                                   context),
//                                 //                                           child: Text(
//                                 //                                             "Quantity"
//                                 //                                                 .tr,
//                                 //                                             style:
//                                 //                                                 TextStyle(
//                                 //                                               fontFamily:
//                                 //                                                   AppThemeData.medium,
//                                 //                                               fontSize:
//                                 //                                                   14,
//                                 //                                               color: themeChange.getThem()
//                                 //                                                   ? AppThemeData.grey300
//                                 //                                                   : AppThemeData.grey600,
//                                 //                                             ),
//                                 //                                           ),
//                                 //                                         ),
//                                 //                                       ),
//                                 //                                       DataColumn(
//                                 //                                         label:
//                                 //                                             SizedBox(
//                                 //                                           width: Responsive
//                                 //                                               .width(
//                                 //                                                   20,
//                                 //                                                   context),
//                                 //                                           child: Text(
//                                 //                                             "Image"
//                                 //                                                 .tr,
//                                 //                                             style:
//                                 //                                                 TextStyle(
//                                 //                                               fontFamily:
//                                 //                                                   AppThemeData.medium,
//                                 //                                               fontSize:
//                                 //                                                   14,
//                                 //                                               color: themeChange.getThem()
//                                 //                                                   ? AppThemeData.grey300
//                                 //                                                   : AppThemeData.grey600,
//                                 //                                             ),
//                                 //                                           ),
//                                 //                                         ),
//                                 //                                       ),
//                                 //                                     ],
//                                 //                                     rows: controller
//                                 //                                         .itemAttributes
//                                 //                                         .value!
//                                 //                                         .variants!
//                                 //                                         .map(
//                                 //                                           (e) =>
//                                 //                                               DataRow(
//                                 //                                             cells: [
//                                 //                                               DataCell(
//                                 //                                                 Text(
//                                 //                                                   e.variantSku.toString(),
//                                 //                                                   style:
//                                 //                                                       TextStyle(
//                                 //                                                     fontFamily: AppThemeData.semiBold,
//                                 //                                                     color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
//                                 //                                                   ),
//                                 //                                                 ),
//                                 //                                               ),
//                                 //                                               DataCell(
//                                 //                                                 TextFormField(
//                                 //                                                   initialValue:
//                                 //                                                       e.variantPrice,
//                                 //                                                   textCapitalization:
//                                 //                                                       TextCapitalization.sentences,
//                                 //                                                   textInputAction:
//                                 //                                                       TextInputAction.done,
//                                 //                                                   inputFormatters: [
//                                 //                                                     FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),
//                                 //                                                   ],
//                                 //                                                   keyboardType:
//                                 //                                                       TextInputType.text,
//                                 //                                                   onChanged:
//                                 //                                                       (value) {
//                                 //                                                     e.variantPrice = value;
//                                 //                                                   },
//                                 //                                                   style: TextStyle(
//                                 //                                                       fontSize: 14,
//                                 //                                                       color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                 //                                                       fontFamily: AppThemeData.medium),
//                                 //                                                   decoration:
//                                 //                                                       InputDecoration(
//                                 //                                                     errorStyle: const TextStyle(color: Colors.red),
//                                 //                                                     filled: true,
//                                 //                                                     enabled: true,
//                                 //                                                     contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                                 //                                                     fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
//                                 //                                                     disabledBorder: UnderlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     focusedBorder: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
//                                 //                                                     ),
//                                 //                                                     enabledBorder: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     errorBorder: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     border: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     hintText: "Price".tr,
//                                 //                                                     prefix: Padding(
//                                 //                                                       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
//                                 //                                                       child: Text(
//                                 //                                                         "${Constant.currencyModel!.symbol}".tr,
//                                 //                                                         style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400, fontFamily: AppThemeData.semiBold, fontSize: 18),
//                                 //                                                       ),
//                                 //                                                     ),
//                                 //                                                     hintStyle: TextStyle(
//                                 //                                                       fontSize: 14,
//                                 //                                                       color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
//                                 //                                                       fontFamily: AppThemeData.regular,
//                                 //                                                     ),
//                                 //                                                   ),
//                                 //                                                 ),
//                                 //                                               ),
//                                 //                                               DataCell(
//                                 //                                                 TextFormField(
//                                 //                                                   initialValue:
//                                 //                                                       e.variantQuantity,
//                                 //                                                   textInputAction:
//                                 //                                                       TextInputAction.done,
//                                 //                                                   inputFormatters: [
//                                 //                                                     FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),
//                                 //                                                   ],
//                                 //                                                   keyboardType:
//                                 //                                                       TextInputType.text,
//                                 //                                                   onChanged:
//                                 //                                                       (value) {
//                                 //                                                     e.variantQuantity = value;
//                                 //                                                   },
//                                 //                                                   style: TextStyle(
//                                 //                                                       fontSize: 14,
//                                 //                                                       color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                 //                                                       fontFamily: AppThemeData.medium),
//                                 //                                                   decoration:
//                                 //                                                       InputDecoration(
//                                 //                                                     errorStyle: const TextStyle(color: Colors.red),
//                                 //                                                     filled: true,
//                                 //                                                     enabled: true,
//                                 //                                                     contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
//                                 //                                                     fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
//                                 //                                                     disabledBorder: UnderlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     focusedBorder: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
//                                 //                                                     ),
//                                 //                                                     enabledBorder: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     errorBorder: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     border: OutlineInputBorder(
//                                 //                                                       borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                       borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
//                                 //                                                     ),
//                                 //                                                     hintText: "Quantity".tr,
//                                 //                                                     hintStyle: TextStyle(
//                                 //                                                       fontSize: 14,
//                                 //                                                       color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
//                                 //                                                       fontFamily: AppThemeData.regular,
//                                 //                                                     ),
//                                 //                                                   ),
//                                 //                                                 ),
//                                 //                                               ),
//                                 //                                               DataCell(e.variantImage != null &&
//                                 //                                                       e.variantImage!.isNotEmpty
//                                 //                                                   ? InkWell(
//                                 //                                                       onTap: () {
//                                 //                                                         int index = controller.itemAttributes.value!.variants!.indexWhere((element) => element.variantId == e.variantId);
//                                 //                                                         onCameraClick(context, index, controller);
//                                 //                                                       },
//                                 //                                                       child: ClipRRect(
//                                 //                                                         borderRadius: const BorderRadius.all(Radius.circular(10)),
//                                 //                                                         child: NetworkImageWidget(
//                                 //                                                           height: 50,
//                                 //                                                           width: 60,
//                                 //                                                           fit: BoxFit.cover,
//                                 //                                                           imageUrl: e.variantImage.toString(),
//                                 //                                                         ),
//                                 //                                                       ),
//                                 //                                                     )
//                                 //                                                   : InkWell(
//                                 //                                                       onTap: () {
//                                 //                                                         int index = controller.itemAttributes.value!.variants!.indexWhere((element) => element.variantId == e.variantId);
//                                 //                                                         onCameraClick(context, index, controller);
//                                 //                                                       },
//                                 //                                                       child: SvgPicture.asset("assets/icons/ic_folder_upload.svg"))),
//                                 //                                             ],
//                                 //                                           ),
//                                 //                                         )
//                                 //                                         .toList()),
//                                 //                               ),
//                                 //                   ),
//                                 //                 ],
//                                 //               ),
//                                 //             ),
//                                 //           ),
//                                 //   ],
//                                 // ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: TextFieldWidget(
//                                         title: 'Your Price'.tr,
//                                         controller:
//                                             controller.regularPriceController.value,
//                                         hintText: 'Enter Regular Price'.tr,
//                                         textInputAction: TextInputAction.done,
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.allow(
//                                               RegExp('[0-9]')),
//                                         ],
//                                         textInputType:
//                                             const TextInputType.numberWithOptions(
//                                                 signed: true, decimal: true),
//                                         prefix: Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 16, vertical: 14),
//                                           child: Text(
//                                             "${Constant.currencyModel!.symbol}".tr,
//                                             style: TextStyle(
//                                                 color: themeChange.getThem()
//                                                     ? AppThemeData.grey50
//                                                     : AppThemeData.grey900,
//                                                 fontFamily: AppThemeData.semiBold,
//                                                 fontSize: 18),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 10,
//                                     ),
//                                     // Expanded(
//                                     //   child: TextFieldWidget(
//                                     //     title: 'Discounted Price'.tr,
//                                     //     controller: controller
//                                     //         .discountedPriceController.value,
//                                     //     hintText: 'Enter Discounted Price'.tr,
//                                     //     textInputAction: TextInputAction.done,
//                                     //     inputFormatters: [
//                                     //       FilteringTextInputFormatter.allow(
//                                     //           RegExp('[0-9]')),
//                                     //     ],
//                                     //     textInputType:
//                                     //         const TextInputType.numberWithOptions(
//                                     //             signed: true, decimal: true),
//                                     //     prefix: Padding(
//                                     //       padding: const EdgeInsets.symmetric(
//                                     //           horizontal: 16, vertical: 14),
//                                     //       child: Text(
//                                     //         "${Constant.currencyModel!.symbol}".tr,
//                                     //         style: TextStyle(
//                                     //             color: themeChange.getThem()
//                                     //                 ? AppThemeData.grey50
//                                     //                 : AppThemeData.grey900,
//                                     //             fontFamily: AppThemeData.semiBold,
//                                     //             fontSize: 18),
//                                     //       ),
//                                     //     ),
//                                     //   ),
//                                     // ),
//                                   ],
//                                 ),
//                                 // Row(
//                                 //   children: [
//                                 //     Text(
//                                 //       "Your item Price will be display like this. "
//                                 //           .tr,
//                                 //       style: TextStyle(
//                                 //           color: themeChange.getThem()
//                                 //               ? AppThemeData.grey100
//                                 //               : AppThemeData.grey800,
//                                 //           fontFamily: AppThemeData.medium,
//                                 //           fontSize: 12),
//                                 //     ),
//                                 //     Row(
//                                 //       children: [
//                                 //         Text(
//                                 //           (controller.merchant_price.value == 0.0
//                                 //                   ? Constant.amountShow(amount: "0.0")
//                                 //                   : Constant.amountShow(
//                                 //                       amount: controller
//                                 //                           .merchant_price.value
//                                 //                           .toString()))
//                                 //               .tr,
//                                 //           style: TextStyle(
//                                 //               color: themeChange.getThem()
//                                 //                   ? AppThemeData.secondary300
//                                 //                   : AppThemeData.secondary300,
//                                 //               fontFamily: AppThemeData.medium,
//                                 //               fontSize: 12),
//                                 //         ),
//                                 //         const SizedBox(
//                                 //           width: 5,
//                                 //         ),
//                                 //         Text(
//                                 //           Constant.amountShow(
//                                 //               amount: controller.regularPrice.value
//                                 //                   .toString()),
//                                 //           style: TextStyle(
//                                 //               color: themeChange.getThem()
//                                 //                   ? AppThemeData.grey500
//                                 //                   : AppThemeData.grey400,
//                                 //               fontFamily: AppThemeData.medium,
//                                 //               decoration: TextDecoration.lineThrough),
//                                 //         ),
//                                 //       ],
//                                 //     ),
//                                 //   ],
//                                 // ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 TextFieldWidget(
//                                   title: 'Quantity'.tr,
//                                   controller:
//                                       controller.productQuantityController.value,
//                                   hintText: 'Enter Quantity'.tr,
//                                   textInputAction: TextInputAction.done,
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(
//                                         RegExp('[0-9-.]')),
//                                   ],
//                                   textInputType: TextInputType.text,
//                                 ),
//                                 Text(
//                                   "-1 to your product quantity is unlimited".tr,
//                                   style: TextStyle(
//                                       color: themeChange.getThem()
//                                           ? AppThemeData.danger300
//                                           : AppThemeData.danger300,
//                                       fontFamily: AppThemeData.medium,
//                                       fontSize: 14),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 _AvailabilitySection(controller: controller),
//                                 // const SizedBox(
//                                 //   height: 20,
//                                 // ),
//                                 Visibility(
//                                 visible: false,
//                                   child: Text(
//                                     "About Cal., Grams, prot.& Fats".tr,
//                                     style: TextStyle(
//                                         color: themeChange.getThem()
//                                             ? AppThemeData.grey50
//                                             : AppThemeData.grey900,
//                                         fontFamily: AppThemeData.medium,
//                                         fontSize: 18),
//                                   ),
//                                 ),
//                                 // const SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 Visibility(
//                                   visible: false,
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextFieldWidget(
//                                           title: 'Calories'.tr,
//                                           controller:
//                                               controller.caloriesController.value,
//                                           hintText: 'Enter Calories'.tr,
//                                           textInputAction: TextInputAction.done,
//                                           inputFormatters: [
//                                             FilteringTextInputFormatter.allow(
//                                                 RegExp('[0-9]')),
//                                           ],
//                                           textInputType:
//                                               const TextInputType.numberWithOptions(
//                                                   signed: true, decimal: true),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         width: 10,
//                                       ),
//                                       Expanded(
//                                         child: TextFieldWidget(
//                                           title: 'Grams'.tr,
//                                           controller: controller.gramsController.value,
//                                           hintText: 'Enter Grams'.tr,
//                                           textInputAction: TextInputAction.done,
//                                           inputFormatters: [
//                                             FilteringTextInputFormatter.allow(
//                                                 RegExp('[0-9]')),
//                                           ],
//                                           textInputType:
//                                               const TextInputType.numberWithOptions(
//                                                   signed: true, decimal: true),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // const SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 Visibility(
//                                   visible: false,
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: TextFieldWidget(
//                                           title: 'Protein'.tr,
//                                           controller:
//                                               controller.proteinController.value,
//                                           hintText: 'Enter Protein'.tr,
//                                           textInputAction: TextInputAction.done,
//                                           inputFormatters: [
//                                             FilteringTextInputFormatter.allow(
//                                                 RegExp('[0-9]')),
//                                           ],
//                                           textInputType:
//                                               const TextInputType.numberWithOptions(
//                                                   signed: true, decimal: true),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         width: 10,
//                                       ),
//                                       Expanded(
//                                         child: TextFieldWidget(
//                                           title: 'Fats'.tr,
//                                           controller: controller.fatsController.value,
//                                           hintText: 'Enter Fats'.tr,
//                                           textInputAction: TextInputAction.done,
//                                           inputFormatters: [
//                                             FilteringTextInputFormatter.allow(
//                                                 RegExp('[0-9]')),
//                                           ],
//                                           textInputType:
//                                               const TextInputType.numberWithOptions(
//                                                   signed: true, decimal: true),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 Text(
//                                   "Product Type".tr,
//                                   style: TextStyle(
//                                       color: themeChange.getThem()
//                                           ? AppThemeData.grey50
//                                           : AppThemeData.grey900,
//                                       fontFamily: AppThemeData.medium,
//                                       fontSize: 18),
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               "Pure veg.".tr,
//                                               style: TextStyle(
//                                                   color: themeChange.getThem()
//                                                       ? AppThemeData.grey50
//                                                       : AppThemeData.grey900,
//                                                   fontFamily: AppThemeData.medium,
//                                                   fontSize: 18),
//                                             ),
//                                           ),
//                                           Transform.scale(
//                                             scale: 0.8,
//                                             child: CupertinoSwitch(
//                                               value: controller.isPureVeg.value,
//                                               onChanged: (value) {
//                                                 if (controller.isNonVeg.value ==
//                                                     true) {
//                                                   controller.isPureVeg.value = value;
//                                                 }
//                                                 if (controller.isPureVeg.value ==
//                                                     true) {
//                                                   controller.isNonVeg.value = false;
//                                                 }
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     const SizedBox(
//                                       width: 20,
//                                     ),
//                                     Expanded(
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               "Non veg.".tr,
//                                               style: TextStyle(
//                                                   color: themeChange.getThem()
//                                                       ? AppThemeData.grey50
//                                                       : AppThemeData.grey900,
//                                                   fontFamily: AppThemeData.medium,
//                                                   fontSize: 18),
//                                             ),
//                                           ),
//                                           Transform.scale(
//                                             scale: 0.8,
//                                             child: CupertinoSwitch(
//                                               value: controller.isNonVeg.value,
//                                               onChanged: (value) {
//                                                 if (controller.isPureVeg.value ==
//                                                     true) {
//                                                   controller.isNonVeg.value = value;
//                                                 }
//
//                                                 if (controller.isNonVeg.value ==
//                                                     true) {
//                                                   controller.isPureVeg.value = false;
//                                                 }
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 // const SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 Visibility(
//                                   visible: false,
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           "Enable Takeaway option".tr,
//                                           style: TextStyle(
//                                               color: themeChange.getThem()
//                                                   ? AppThemeData.grey50
//                                                   : AppThemeData.grey900,
//                                               fontFamily: AppThemeData.medium,
//                                               fontSize: 18),
//                                         ),
//                                       ),
//                                       Transform.scale(
//                                         scale: 0.8,
//                                         child: CupertinoSwitch(
//                                           value: controller.takeAway.value,
//                                           onChanged: (value) {
//                                             controller.takeAway.value = value;
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // const SizedBox(
//                                 //   height: 20,
//                                 // ),
//                                 // Text(
//                                 //   "Specifications and Addons".tr,
//                                 //   style: TextStyle(
//                                 //       color: themeChange.getThem()
//                                 //           ? AppThemeData.grey50
//                                 //           : AppThemeData.grey900,
//                                 //       fontFamily: AppThemeData.medium,
//                                 //       fontSize: 18),
//                                 // ),
//                                 // const SizedBox(
//                                 //   height: 20,
//                                 // ),
//                                 // Row(
//                                 //   children: [
//                                 //     Expanded(
//                                 //       child: Text(
//                                 //         "Specifications".tr,
//                                 //         style: TextStyle(
//                                 //             color: themeChange.getThem()
//                                 //                 ? AppThemeData.grey50
//                                 //                 : AppThemeData.grey900,
//                                 //             fontFamily: AppThemeData.medium,
//                                 //             fontSize: 16),
//                                 //       ),
//                                 //     ),
//                                 //     InkWell(
//                                 //         onTap: () {
//                                 //           controller.specificationList.add(
//                                 //               ProductSpecificationModel(
//                                 //                   lable: '', value: ''));
//                                 //         },
//                                 //         child: SvgPicture.asset(
//                                 //             "assets/icons/ic_add_one.svg"))
//                                 //   ],
//                                 // ),
//                                 // const SizedBox(
//                                 //   height: 10,
//                                 // ),
//                                 // ListView.builder(
//                                 //   shrinkWrap: true,
//                                 //   padding: EdgeInsets.zero,
//                                 //   itemCount: controller.specificationList.length,
//                                 //   physics: const NeverScrollableScrollPhysics(),
//                                 //   itemBuilder: (context, index) {
//                                 //     return Padding(
//                                 //       padding: const EdgeInsets.all(8.0),
//                                 //       child: Row(
//                                 //         children: [
//                                 //           Expanded(
//                                 //             child: TextFieldWidget(
//                                 //               initialValue: controller
//                                 //                   .specificationList[index].lable,
//                                 //               title: 'Title'.tr,
//                                 //               hintText: 'Enter Title'.tr,
//                                 //               onchange: (value) {
//                                 //                 controller.specificationList[index]
//                                 //                     .lable = value;
//                                 //               },
//                                 //             ),
//                                 //           ),
//                                 //           const SizedBox(
//                                 //             width: 10,
//                                 //           ),
//                                 //           Expanded(
//                                 //             child: TextFieldWidget(
//                                 //               initialValue: controller
//                                 //                   .specificationList[index].value,
//                                 //               title: 'Value'.tr,
//                                 //               hintText: 'Enter Value'.tr,
//                                 //               onchange: (value) {
//                                 //                 controller.specificationList[index]
//                                 //                     .value = value;
//                                 //               },
//                                 //             ),
//                                 //           ),
//                                 //         ],
//                                 //       ),
//                                 //     );
//                                 //   },
//                                 // ),
//                                 if (controller.itemAttributes.value?.variants != null &&
//                                     controller.itemAttributes.value!.variants!.isNotEmpty) ...[
//                                   Text(
//                                     "Options / Variants".tr,
//                                     style: TextStyle(
//                                         color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                         fontFamily: AppThemeData.medium,
//                                         fontSize: 16),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   ListView.builder(
//                                     shrinkWrap: true,
//                                     physics: const NeverScrollableScrollPhysics(),
//                                     itemCount: controller.itemAttributes.value!.variants!.length,
//                                     itemBuilder: (context, index) {
//                                       final v = controller.itemAttributes.value!.variants![index];
//                                       return Padding(
//                                         padding: const EdgeInsets.only(bottom: 12),
//                                         child: Row(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Expanded(
//                                               child: TextFieldWidget(
//                                                 title: 'Option'.tr,
//                                                 hintText: 'Title'.tr,
//                                                 initialValue: v.variantSku ?? '',
//                                                 onchange: (value) {
//                                                   controller.updateVariantAt(index, variantSku: value);
//                                                 },
//                                               ),
//                                             ),
//                                             const SizedBox(width: 12),
//                                             Expanded(
//                                               child: TextFieldWidget(
//                                                 title: 'Price'.tr,
//                                                 hintText: '0',
//                                                 initialValue: v.variantPrice ?? '',
//                                                 prefix: Padding(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                                                   child: Text(
//                                                     '${Constant.currencyModel?.symbol ?? ''}',
//                                                     style: TextStyle(
//                                                       color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
//                                                       fontFamily: AppThemeData.semiBold,
//                                                       fontSize: 16,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
//                                                 inputFormatters: [
//                                                   FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
//                                                 ],
//                                                 onchange: (value) {
//                                                   controller.updateVariantAt(index, variantPrice: value);
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   const SizedBox(height: 16),
//                                 ],
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         "Addons".tr,
//                                         style: TextStyle(
//                                             color: themeChange.getThem()
//                                                 ? AppThemeData.grey50
//                                                 : AppThemeData.grey900,
//                                             fontFamily: AppThemeData.medium,
//                                             fontSize: 16),
//                                       ),
//                                     ),
//                                     InkWell(
//                                         onTap: () {
//                                           controller.addonsList.add(
//                                               ProductSpecificationModel(
//                                                   lable: '', value: ''));
//                                         },
//                                         child: SvgPicture.asset(
//                                             "assets/icons/ic_add_one.svg"))
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 10,
//                                 ),
//                                 ListView.builder(
//                                   shrinkWrap: true,
//                                   itemCount: controller.addonsList.length,
//                                   padding: EdgeInsets.zero,
//                                   physics: const NeverScrollableScrollPhysics(),
//                                   itemBuilder: (context, index) {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Row(
//                                         children: [
//                                           Expanded(
//                                             child: TextFieldWidget(
//                                               title: 'Title'.tr,
//                                               hintText: 'Enter Title'.tr,
//                                               initialValue:
//                                                   controller.addonsList[index].lable,
//                                               onchange: (value) {
//                                                 controller.addonsList[index].lable =
//                                                     value;
//                                               },
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             width: 10,
//                                           ),
//                                           Expanded(
//                                             child: TextFieldWidget(
//                                               title: 'Price'.tr,
//                                               hintText: 'Enter Price'.tr,
//                                               initialValue:
//                                                   controller.addonsList[index].value,
//                                               prefix: Padding(
//                                                 padding: const EdgeInsets.symmetric(
//                                                     horizontal: 16, vertical: 14),
//                                                 child: Text(
//                                                   "${Constant.currencyModel!.symbol}"
//                                                       .tr,
//                                                   style: TextStyle(
//                                                       color: themeChange.getThem()
//                                                           ? AppThemeData.grey50
//                                                           : AppThemeData.grey900,
//                                                       fontFamily:
//                                                           AppThemeData.semiBold,
//                                                       fontSize: 18),
//                                                 ),
//                                               ),
//                                               textInputAction: TextInputAction.done,
//                                               inputFormatters: [
//                                                 FilteringTextInputFormatter.allow(
//                                                     RegExp('[0-9]')),
//                                               ],
//                                               textInputType: const TextInputType
//                                                   .numberWithOptions(
//                                                   signed: true, decimal: true),
//                                               onchange: (value) {
//                                                 controller.addonsList[index].value =
//                                                     value;
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(
//                                   height: 40,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       bottomNavigationBar: SafeArea(
//                         child: Container(
//                           color: themeChange.getThem()
//                               ? AppThemeData.grey900
//                               : AppThemeData.grey50,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 20),
//                           child: Padding(
//                             padding: const EdgeInsets.only(bottom: 20),
//                             child: RoundedButtonFill(
//                               title: "Save Details".tr,
//                               height: 5.5,
//                               color: ColorConst.orange,
//                               textColor: AppThemeData.grey50,
//                               fontSizes: 16,
//                               onPress: () async {
//                                 // App is now 100% free - no subscription checks needed
//
//                                 if (controller.itemAttributes.value != null) {
//                                   if (controller.itemAttributes.value!.attributes !=
//                                           null &&
//                                       controller.itemAttributes.value!.attributes!
//                                           .isNotEmpty) {
//                                     for (var element in controller
//                                         .itemAttributes.value!.attributes!) {
//                                       if (element.attributeOptions!.isEmpty) {
//                                         ShowToastDialog.showToast(
//                                             "${"Please add a attribute".tr} (${controller.selectedAttributesList.where((p0) => p0.id == element.attributeId).first.title}) ${"value".tr}");
//                                         return;
//                                       }
//                                     }
//                                   }
//                                   if (controller.itemAttributes.value!.variants !=
//                                           null &&
//                                       controller.itemAttributes.value!.variants!
//                                           .isNotEmpty) {
//                                     for (var element in controller
//                                         .itemAttributes.value!.variants!) {
//                                       if (double.parse(
//                                               element.variantPrice!.toString()) ==
//                                           0) {
//                                         ShowToastDialog.showToast(
//                                             "Please enter a valid variant price".tr);
//                                         return;
//                                       }
//                                     }
//                                   }
//                                 }
//
//                                 await controller.saveDetails();
//                               },
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 );
//           }),
//     );
//   }
//
//   addAttributeValueDialog(AddProductController controller, themeChange,
//       int index, String attributeId) {
//     return SafeArea(
//       child: Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         insetPadding: const EdgeInsets.all(10),
//         clipBehavior: Clip.antiAliasWithSaveLayer,
//         backgroundColor: themeChange.getThem()
//             ? AppThemeData.surfaceDark
//             : AppThemeData.surface,
//         child: Padding(
//           padding: const EdgeInsets.all(30),
//           child: SizedBox(
//             width: 500,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFieldWidget(
//                   title: 'Add Attribute Value'.tr,
//                   controller: controller.attributesValueController.value,
//                   hintText: 'Add Attribute Value'.tr,
//                 ),
//                 RoundedButtonFill(
//                   title: "Add".tr,
//                   color: AppThemeData.secondary300,
//                   textColor: AppThemeData.grey50,
//                   onPress: () async {
//                     if (controller.attributesValueController.value.text.isEmpty) {
//                       ShowToastDialog.showToast(
//                           "Please enter attribute value".tr);
//                     } else {
//                       Get.back();
//                       controller.itemAttributes.value!.attributes![index]
//                           .attributeOptions!
//                           .add(controller.attributesValueController.value.text);
//
//                       List<List<dynamic>> listArary = [];
//                       for (int i = 0;
//                           i < controller.itemAttributes.value!.attributes!.length;
//                           i++) {
//                         if (controller.itemAttributes.value!.attributes![i]
//                             .attributeOptions!.isNotEmpty) {
//                           listArary.add(controller.itemAttributes.value!
//                               .attributes![i].attributeOptions!);
//                         }
//                       }
//
//                       List<dynamic> list = getCombination(listArary);
//
//                       for (var element in list) {
//                         bool productIsInList = controller
//                             .itemAttributes.value!.variants!
//                             .any((product) => product.variantSku == element);
//                         if (productIsInList) {
//                         } else {
//                           if (controller.itemAttributes.value!.attributes![index]
//                                   .attributeOptions!.length ==
//                               1) {
//                             controller.itemAttributes.value!.variants!.clear();
//                             Variants variantsModel = Variants(
//                                 variantSku: element,
//                                 variantId: Constant.getUuid(),
//                                 variantImage: "",
//                                 variantPrice: "0",
//                                 variantQuantity: "-1");
//                             controller.itemAttributes.value!.variants!
//                                 .add(variantsModel);
//                           } else {
//                             Variants variantsModel = Variants(
//                                 variantSku: element,
//                                 variantId: Constant.getUuid(),
//                                 variantImage: "",
//                                 variantPrice: "0",
//                                 variantQuantity: "-1");
//                             controller.itemAttributes.value!.variants!
//                                 .add(variantsModel);
//                           }
//                         }
//                       }
//                       setState(() {});
//                       controller.attributesValueController.value.clear();
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   buildBottomSheet(BuildContext context, AddProductController controller) {
//     bool showCameraOption = false; // Set to true to show Camera in the future
//     return showModalBottomSheet(
//         context: context,
//         builder: (context) {
//           final themeChange = Provider.of<DarkThemeProvider>(context);
//           return SafeArea(
//             child: StatefulBuilder(builder: (context, setState) {
//               return SizedBox(
//                 height: Responsive.height(showCameraOption ? 22 : 22, context),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(top: 15),
//                       child: Text(
//                         "Please Select".tr,
//                         style: TextStyle(
//                             color: themeChange.getThem()
//                                 ? AppThemeData.grey50
//                                 : AppThemeData.grey900,
//                             fontFamily: AppThemeData.bold,
//                             fontSize: 16),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         if (showCameraOption)
//                           Padding(
//                             padding: const EdgeInsets.all(18.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                     onPressed: () => controller.pickFile(
//                                         source: ImageSource.camera),
//                                     icon: const Icon(
//                                       Icons.camera_alt,
//                                       size: 32,
//                                     )),
//                                 Padding(
//                                   padding: const EdgeInsets.only(top: 3),
//                                   child: Text("Camera".tr),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         Padding(
//                           padding: const EdgeInsets.all(18.0),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               IconButton(
//                                   onPressed: () => controller.pickFile(
//                                       source: ImageSource.gallery),
//                                   icon: const Icon(
//                                     Icons.photo_library_sharp,
//                                     size: 32,
//                                   )),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 3),
//                                 child: Text("Gallery".tr),
//                               ),
//                             ],
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           );
//         });
//   }
//
//   Widget _buildChip(themeChange, String label, int attributesIndex,
//       int attributesOptionIndex) {
//     return Container(
//       decoration: ShapeDecoration(
//         color: themeChange.getThem()
//             ? AppThemeData.surfaceDark
//             : AppThemeData.surface,
//         shape: RoundedRectangleBorder(
//           side: BorderSide(
//               width: 1,
//               color: themeChange.getThem()
//                   ? AppThemeData.grey800
//                   : AppThemeData.grey100),
//           borderRadius: BorderRadius.circular(120),
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                   color: themeChange.getThem()
//                       ? AppThemeData.grey200
//                       : AppThemeData.grey700,
//                   fontFamily: AppThemeData.semiBold,
//                   fontSize: 14),
//             ),
//             const SizedBox(width: 10),
//             Icon(
//               Icons.clear,
//               color: themeChange.getThem()
//                   ? AppThemeData.grey200
//                   : AppThemeData.grey700,
//               size: 16,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   List<dynamic> getCombination(List<List<dynamic>> listArray) {
//     if (listArray.length == 1) {
//       return listArray[0];
//     } else {
//       List<dynamic> result = [];
//       var allCasesOfRest = getCombination(listArray.sublist(1));
//       for (var i = 0; i < allCasesOfRest.length; i++) {
//         for (var j = 0; j < listArray[0].length; j++) {
//           result.add(listArray[0][j] + '-' + allCasesOfRest[i]);
//         }
//       }
//       return result;
//     }
//   }
//
//   onCameraClick(
//       BuildContext context, int index, AddProductController controller) {
//     final action = CupertinoActionSheet(
//       message: Text(
//         'Upload image'.tr,
//         style: TextStyle(fontSize: 15.0),
//       ),
//       actions: <Widget>[
//         CupertinoActionSheetAction(
//           isDefaultAction: false,
//           onPressed: () async {
//             Get.back();
//             XFile? singleImage =
//                 await ImagePicker().pickImage(source: ImageSource.gallery);
//             if (singleImage != null) {
//               ShowToastDialog.showLoader("Image Upload...".tr);
//
//               String image = await FireStoreUtils.uploadUserImageToFireStorage(
//                   File(singleImage.path),
//                   controller.itemAttributes.value!.variants![index].variantId
//                       .toString());
//               ShowToastDialog.closeLoader();
//               controller.itemAttributes.value!.variants![index].variantImage =
//                   image;
//               setState(() {});
//             }
//           },
//           child: Text('Choose image from gallery'.tr),
//         ),
//         CupertinoActionSheetAction(
//           isDestructiveAction: false,
//           onPressed: () async {
//             Get.back();
//             final XFile? singleImage =
//                 await ImagePicker().pickImage(source: ImageSource.camera);
//             if (singleImage != null) {
//               ShowToastDialog.showLoader("Image Upload...".tr);
//
//               String image = await FireStoreUtils.uploadUserImageToFireStorage(
//                   File(singleImage.path),
//                   controller.itemAttributes.value!.variants![index].variantId
//                       .toString());
//               ShowToastDialog.closeLoader();
//               controller.itemAttributes.value!.variants![index].variantImage =
//                   image;
//               setState(() {});
//             }
//           },
//           child: Text('Take a picture'.tr),
//         ),
//       ],
//       cancelButton: CupertinoActionSheetAction(
//         child: Text(
//           'Cancel'.tr,
//         ),
//         onPressed: () {
//           Get.back();
//         },
//       ),
//     );
//     showCupertinoModalPopup(context: context, builder: (context) => action);
//   }
// }
//
// /// Compact section that lets the vendor edit per-day available time
// /// slots for this product.
// class _AvailabilitySection extends StatelessWidget {
//   final AddProductController controller;
//
//   const _AvailabilitySection({required this.controller});
//
//   static const _daysOfWeek = <String>[
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday',
//     'Saturday',
//     'Sunday',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Available times".tr,
//               style: TextStyle(
//                 color: themeChange.getThem()
//                     ? AppThemeData.grey50
//                     : AppThemeData.grey900,
//                 fontFamily: AppThemeData.medium,
//                 fontSize: 18,
//               ),
//             ),
//             TextButton(
//               onPressed: () => _openAvailabilityEditor(context),
//               child: Text(
//                 controller.availableDays.isEmpty
//                     ? "Set timings".tr
//                     : "Edit".tr,
//                 style: const TextStyle(
//                   fontFamily: AppThemeData.medium,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Obx(() {
//           if (controller.availableDays.isEmpty) {
//             return Text(
//               "No time restrictions. Product is available all day.".tr,
//               style: TextStyle(
//                   color: themeChange.getThem()
//                       ? AppThemeData.grey400
//                       : AppThemeData.grey600,
//                   fontFamily: AppThemeData.regular,
//                   fontSize: 14),
//             );
//           }
//
//           final chips = <Widget>[];
//           for (final day in controller.availableDays) {
//             final slots = controller.availableTimings[day] ?? [];
//             final label = slots.isEmpty
//                 ? day
//                 : '$day: ${slots.map((s) => '${s.from}-${s.to}').join(', ')}';
//             chips.add(Padding(
//               padding: const EdgeInsets.only(right: 6, bottom: 6),
//               child: Chip(
//                 label: Text(
//                   label,
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ),
//             ));
//           }
//
//           return Wrap(children: chips);
//         }),
//       ],
//     );
//   }
//
//   Future<void> _openAvailabilityEditor(BuildContext context) async {
//     final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
//
//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 16,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
//           ),
//           child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       "Edit available times".tr,
//                       style: TextStyle(
//                         fontFamily: AppThemeData.medium,
//                         fontSize: 16,
//                         color: themeChange.getThem()
//                             ? AppThemeData.grey50
//                             : AppThemeData.grey900,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () => Navigator.of(ctx).pop(),
//                       child: Text("Done".tr),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Expanded(
//                   child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: _daysOfWeek.length,
//                     itemBuilder: (context, index) {
//                       final day = _daysOfWeek[index];
//                       final isSelected =
//                           controller.availableDays.contains(day);
//                       final slots = controller.availableTimings[day] ?? [];
//                       final subtitle = slots.isEmpty
//                           ? "Tap to add time".tr
//                           : slots
//                               .map((s) => '${s.from} - ${s.to}')
//                               .join(', ');
//
//                       return Card(
//                         margin: const EdgeInsets.symmetric(
//                             vertical: 4, horizontal: 0),
//                         child: ListTile(
//                           leading: Checkbox(
//                             value: isSelected,
//                             onChanged: (value) {
//                               if (value == true) {
//                                 if (!controller.availableDays.contains(day)) {
//                                   controller.availableDays.add(day);
//                                 }
//                                 controller.availableTimings.putIfAbsent(
//                                     day, () => <TimeRangeItem>[]);
//                               } else {
//                                 controller.availableDays.remove(day);
//                                 controller.availableTimings.remove(day);
//                               }
//                             },
//                           ),
//                           title: Text(day.tr),
//                           subtitle: Text(subtitle),
//                           onTap: isSelected
//                               ? () => _pickTimeRange(context, day)
//                               : null,
//                           trailing: isSelected && slots.isNotEmpty
//                               ? IconButton(
//                                   icon: const Icon(Icons.delete_outline),
//                                   onPressed: () {
//                                     controller.availableTimings[day] = [];
//                                   },
//                                 )
//                               : null,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//         );
//       },
//     );
//   }
//
//   Future<void> _pickTimeRange(BuildContext context, String day) async {
//     final from = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 9, minute: 0),
//     );
//     if (from == null) return;
//
//     final to = await showTimePicker(
//       context: context,
//       initialTime: const TimeOfDay(hour: 22, minute: 0),
//     );
//     if (to == null) return;
//
//     String format(TimeOfDay t) =>
//         t.hour.toString().padLeft(2, '0') +
//         ':' +
//         t.minute.toString().padLeft(2, '0');
//
//     final range = TimeRangeItem(from: format(from), to: format(to));
//
//     final current = List<TimeRangeItem>.from(
//         controller.availableTimings[day] ?? <TimeRangeItem>[]);
//     if (current.isEmpty) {
//       current.add(range);
//     } else {
//       current[0] = range;
//     }
//     controller.availableTimings[day] = current;
//   }
// }



import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/utils/const/color_const.dart';
import 'package:provider/provider.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/add_product_controller.dart';
import 'package:jippymart_restaurant/models/product_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/themes/app_them_data.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:jippymart_restaurant/themes/round_button_fill.dart';
import 'package:jippymart_restaurant/themes/text_field_widget.dart';
import 'package:jippymart_restaurant/utils/dark_theme_provider.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/network_image_widget.dart';
import 'package:jippymart_restaurant/models/selected_product_model.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel? product;
  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required bool isDark,
    String? hint,
    Widget? prefix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
      ),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDark ? AppThemeData.grey500 : AppThemeData.grey400,
        fontFamily: AppThemeData.regular,
      ),
      prefixIcon: prefix,
      filled: true,
      fillColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:  BorderSide(
            color: AppThemeData.secondary300, width: 1.8),
      ),
      errorBorder: border,
      disabledBorder: border,
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.getThem();

    return GetX<AddProductController>(
      init: AddProductController(productToEdit: widget.product),
      builder: (controller) {
        if (controller.isLoading.value) {
          return Scaffold(
            backgroundColor:
            isDark ? const Color(0xFF0F0F10) : const Color(0xFFF6F6F8),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: AppThemeData.secondary300,
                    strokeWidth: 2.5,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading product…".tr,
                    style: TextStyle(
                      color: isDark
                          ? AppThemeData.grey400
                          : AppThemeData.grey600,
                      fontFamily: AppThemeData.regular,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isNew = controller.productModel.value.id == null;

        return Scaffold(
          backgroundColor:
          isDark ? const Color(0xFF0F0F10) : const Color(0xFFF6F6F8),

          // ── AppBar ───────────────────────────────────────────────────────
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            elevation: 0,
            centerTitle: false,
            iconTheme:
            const IconThemeData(color: Colors.white),
            title: Text(
              isNew ? "Add Product".tr : "Edit Product".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
                letterSpacing: 0.2,
              ),
            ),
            actions: [
              if (!isNew)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Editing".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ── Body ─────────────────────────────────────────────────────────
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── Section: Images ──────────────────────────────────
                      _SectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon: Icons.image_outlined,
                              label: "Product Images".tr,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _ImageUploadArea(
                              isDark: isDark,
                              onBrowse: () =>
                                  _buildBottomSheet(context, controller),
                            ),
                            if (controller.images.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _ImagePreviewStrip(
                                  controller: controller),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Section: Basic Info ──────────────────────────────
                      _SectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon: Icons.info_outline_rounded,
                              label: "Basic Information".tr,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            TextFieldWidget(
                              title: 'Product Title'.tr,
                              controller:
                              controller.productTitleController.value,
                              hintText: 'Enter product title'.tr,
                            ),
                            const SizedBox(height: 14),
                            _CategoryDropdown(
                              controller: controller,
                              isDark: isDark,
                              themeChange: themeChange,
                            ),
                            const SizedBox(height: 14),
                            TextFieldWidget(
                              title: 'Product Description'.tr,
                              controller: controller
                                  .productDescriptionController.value,
                              hintText:
                              'Enter short description here...'.tr,
                              maxLine: 4,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Section: Pricing & Stock ─────────────────────────
                      _SectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon: Icons.sell_outlined,
                              label: "Pricing & Stock".tr,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFieldWidget(
                                    title: 'Your Price'.tr,
                                    controller: controller
                                        .regularPriceController.value,
                                    hintText: '0'.tr,
                                    textInputAction:
                                    TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9]')),
                                    ],
                                    textInputType:
                                    const TextInputType
                                        .numberWithOptions(
                                        signed: true,
                                        decimal: true),
                                    prefix: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 14),
                                      child: Text(
                                        "${Constant.currencyModel!.symbol}",
                                        style: TextStyle(
                                          color: isDark
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily:
                                          AppThemeData.semiBold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFieldWidget(
                                    title: 'Quantity'.tr,
                                    controller: controller
                                        .productQuantityController
                                        .value,
                                    hintText: '-1 = unlimited'.tr,
                                    textInputAction:
                                    TextInputAction.done,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[0-9-.]')),
                                    ],
                                    textInputType:
                                    TextInputType.text,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: AppThemeData.danger300,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Use -1 for unlimited quantity".tr,
                                  style: const TextStyle(
                                    color: AppThemeData.danger300,
                                    fontFamily: AppThemeData.regular,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Section: Availability ────────────────────────────
                      _SectionCard(
                        isDark: isDark,
                        child: _AvailabilitySection(
                            controller: controller),
                      ),

                      const SizedBox(height: 14),

                      // ── Section: Product Type ────────────────────────────
                      _SectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(
                              icon: Icons.local_dining_outlined,
                              label: "Product Type".tr,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _TypeToggleTile(
                                    label: "Pure Veg".tr,
                                    value:
                                    controller.isPureVeg.value,
                                    isDark: isDark,
                                    dotColor:
                                    const Color(0xFF22C55E),
                                    onChanged: (v) {
                                      if (controller
                                          .isNonVeg.value) {
                                        controller.isPureVeg
                                            .value = v;
                                      }
                                      if (controller
                                          .isPureVeg.value) {
                                        controller.isNonVeg
                                            .value = false;
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _TypeToggleTile(
                                    label: "Non Veg".tr,
                                    value:
                                    controller.isNonVeg.value,
                                    isDark: isDark,
                                    dotColor:
                                    const Color(0xFFEF4444),
                                    onChanged: (v) {
                                      if (controller
                                          .isPureVeg.value) {
                                        controller.isNonVeg
                                            .value = v;
                                      }
                                      if (controller
                                          .isNonVeg.value) {
                                        controller.isPureVeg
                                            .value = false;
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Section: Options / Variants ──────────────────────
                      if (controller.itemAttributes.value?.variants !=
                          null &&
                          controller.itemAttributes.value!.variants!
                              .isNotEmpty) ...[
                        _SectionCard(
                          isDark: isDark,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                icon: Icons.tune_rounded,
                                label: "Options / Variants".tr,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              ListView.separated(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemCount: controller.itemAttributes
                                    .value!.variants!.length,
                                separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final v = controller
                                      .itemAttributes
                                      .value!
                                      .variants![index];
                                  return _VariantRow(
                                    v: v,
                                    index: index,
                                    isDark: isDark,
                                    controller: controller,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Section: Addons ──────────────────────────────────
                      _SectionCard(
                        isDark: isDark,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _SectionHeader(
                                    icon: Icons.add_circle_outline,
                                    label: "Addons".tr,
                                    isDark: isDark,
                                  ),
                                ),
                                _AddButton(
                                  onTap: () {
                                    controller.addonsList.add(
                                      ProductSpecificationModel(
                                          lable: '', value: ''),
                                    );
                                  },
                                  isDark: isDark,
                                ),
                              ],
                            ),
                            if (controller.addonsList.isNotEmpty)
                              const SizedBox(height: 14),
                            ListView.separated(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              itemCount:
                              controller.addonsList.length,
                              separatorBuilder: (_, __) =>
                                  Divider(
                                    height: 24,
                                    color: isDark
                                        ? AppThemeData.grey800
                                        : AppThemeData.grey100,
                                  ),
                              itemBuilder: (context, index) {
                                return _AddonRow(
                                  index: index,
                                  isDark: isDark,
                                  controller: controller,
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Save Bar ───────────────────────────────────────────────
          bottomNavigationBar: _SaveBar(
            isDark: isDark,
            onSave: () async {
              if (controller.itemAttributes.value != null) {
                if (controller.itemAttributes.value!.attributes !=
                    null &&
                    controller.itemAttributes.value!.attributes!
                        .isNotEmpty) {
                  for (var element in controller
                      .itemAttributes.value!.attributes!) {
                    if (element.attributeOptions!.isEmpty) {
                      ShowToastDialog.showToast(
                          "${"Please add a attribute".tr} (${controller.selectedAttributesList.where((p0) => p0.id == element.attributeId).first.title}) ${"value".tr}");
                      return;
                    }
                  }
                }
                if (controller.itemAttributes.value!.variants !=
                    null &&
                    controller
                        .itemAttributes.value!.variants!.isNotEmpty) {
                  for (var element in controller
                      .itemAttributes.value!.variants!) {
                    if (double.parse(
                        element.variantPrice!.toString()) ==
                        0) {
                      ShowToastDialog.showToast(
                          "Please enter a valid variant price".tr);
                      return;
                    }
                  }
                }
              }
              await controller.saveDetails();
            },
          ),
        );
      },
    );
  }

  void _buildBottomSheet(
      BuildContext context, AddProductController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final themeChange =
        Provider.of<DarkThemeProvider>(ctx, listen: false);
        final isDark = themeChange.getThem();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppThemeData.grey700
                        : AppThemeData.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Select Image Source".tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: AppThemeData.semiBold,
                    color: isDark
                        ? AppThemeData.grey50
                        : AppThemeData.grey900,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SourceOption(
                      icon: Icons.photo_library_rounded,
                      label: "Gallery".tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickFile(
                            source: ImageSource.gallery);
                      },
                    ),
                    const SizedBox(width: 24),
                    _SourceOption(
                      icon: Icons.camera_alt_rounded,
                      label: "Camera".tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(ctx);
                        controller.pickFile(
                            source: ImageSource.camera);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  List<dynamic> getCombination(List<List<dynamic>> listArray) {
    if (listArray.length == 1) return listArray[0];
    List<dynamic> result = [];
    var rest = getCombination(listArray.sublist(1));
    for (var i = 0; i < rest.length; i++) {
      for (var j = 0; j < listArray[0].length; j++) {
        result.add('${listArray[0][j]}-${rest[i]}');
      }
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sub-widgets
// ═══════════════════════════════════════════════════════════════════════════

/// Elevated card that wraps each form section.
class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SectionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// Section header row with icon + label.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppThemeData.secondary300.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 17, color: AppThemeData.secondary300),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontFamily: AppThemeData.semiBold,
            color: isDark
                ? AppThemeData.grey50
                : AppThemeData.grey900,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

/// Dotted upload zone.
class _ImageUploadArea extends StatelessWidget {
  final bool isDark;
  final VoidCallback onBrowse;

  const _ImageUploadArea(
      {required this.isDark, required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      dashPattern: const [6, 5],
      color: isDark
          ? AppThemeData.grey600
          : AppThemeData.grey300,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onBrowse,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppThemeData.secondary300
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:  Icon(
                    Icons.cloud_upload_outlined,
                    size: 26,
                    color: AppThemeData.secondary300,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Tap to upload images".tr,
                  style: TextStyle(
                    fontFamily: AppThemeData.medium,
                    fontSize: 14,
                    color: isDark
                        ? AppThemeData.grey200
                        : AppThemeData.grey700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "JPEG, PNG supported".tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppThemeData.regular,
                    color: isDark
                        ? AppThemeData.grey500
                        : AppThemeData.grey400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal strip of uploaded image thumbnails.
class _ImagePreviewStrip extends StatelessWidget {
  final AddProductController controller;
  const _ImagePreviewStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: controller.images[index].runtimeType ==
                      XFile
                      ? Image.file(
                    File(controller.images[index].path),
                    fit: BoxFit.cover,
                    width: 88,
                    height: 88,
                  )
                      : NetworkImageWidget(
                    imageUrl: controller.images[index],
                    fit: BoxFit.cover,
                    width: 88,
                    height: 88,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.images.removeAt(index),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Category dropdown wrapper.
class _CategoryDropdown extends StatelessWidget {
  final AddProductController controller;
  final bool isDark;
  final DarkThemeProvider themeChange;

  const _CategoryDropdown({
    required this.controller,
    required this.isDark,
    required this.themeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Category".tr,
          style: TextStyle(
            fontFamily: AppThemeData.semiBold,
            fontSize: 14,
            color: isDark
                ? AppThemeData.grey100
                : AppThemeData.grey800,
          ),
        ),
        const SizedBox(height: 6),
        DropdownSearch<VendorCategoryModel>(
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Search category".tr,
                prefixIcon: const Icon(Icons.search, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
            menuProps: MenuProps(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context, item, isSelected) => ListTile(
              selected: isSelected,
              selectedColor: AppThemeData.secondary300,
              title: Text(
                item.title ?? "",
                style: TextStyle(
                  fontFamily: AppThemeData.medium,
                  fontSize: 14,
                  color: isDark
                      ? AppThemeData.grey100
                      : AppThemeData.grey800,
                ),
              ),
            ),
          ),
          items: controller.vendorCategoryList,
          itemAsString: (item) => item.title ?? "",
          selectedItem:
          controller.selectedProductCategory.value.id == null
              ? null
              : controller.selectedProductCategory.value,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Select category".tr,
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1C1C1E)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? AppThemeData.grey700
                      : AppThemeData.grey200,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? AppThemeData.grey700
                      : AppThemeData.grey200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:  BorderSide(
                    color: AppThemeData.secondary300, width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              controller.selectedProductCategory.value = value;
              controller.update();
            }
          },
        ),
      ],
    );
  }
}

/// Pure-veg / Non-veg toggle tile.
class _TypeToggleTile extends StatelessWidget {
  final String label;
  final bool value;
  final bool isDark;
  final Color dotColor;
  final ValueChanged<bool> onChanged;

  const _TypeToggleTile({
    required this.label,
    required this.value,
    required this.isDark,
    required this.dotColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: value
            ? dotColor.withOpacity(0.08)
            : isDark
            ? const Color(0xFF2C2C2E)
            : const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? dotColor.withOpacity(0.5)
              : isDark
              ? AppThemeData.grey700
              : AppThemeData.grey200,
          width: 1.4,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? dotColor : Colors.transparent,
              border: Border.all(color: dotColor, width: 1.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 14,
                color: isDark
                    ? AppThemeData.grey100
                    : AppThemeData.grey800,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: CupertinoSwitch(
              value: value,
              activeColor: dotColor,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single variant row (option name + price).
class _VariantRow extends StatelessWidget {
  final Variants v;
  final int index;
  final bool isDark;
  final AddProductController controller;

  const _VariantRow({
    required this.v,
    required this.index,
    required this.isDark,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFieldWidget(
            title: 'Option'.tr,
            hintText: 'e.g. Large, Red…'.tr,
            initialValue: v.variantSku ?? '',
            onchange: (val) =>
                controller.updateVariantAt(index, variantSku: val),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFieldWidget(
            title: 'Price'.tr,
            hintText: '0',
            initialValue: v.variantPrice ?? '',
            textInputType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            prefix: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 14),
              child: Text(
                Constant.currencyModel?.symbol ?? '',
                style: TextStyle(
                  color: isDark
                      ? AppThemeData.grey50
                      : AppThemeData.grey900,
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 16,
                ),
              ),
            ),
            onchange: (val) => controller.updateVariantAt(index,
                variantPrice: val),
          ),
        ),
      ],
    );
  }
}

/// A single addon row (title + price).
class _AddonRow extends StatelessWidget {
  final int index;
  final bool isDark;
  final AddProductController controller;

  const _AddonRow({
    required this.index,
    required this.isDark,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: TextFieldWidget(
            title: 'Title'.tr,
            hintText: 'Enter title'.tr,
            initialValue: controller.addonsList[index].lable,
            onchange: (v) =>
            controller.addonsList[index].lable = v,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: TextFieldWidget(
            title: 'Price'.tr,
            hintText: '0',
            initialValue: controller.addonsList[index].value,
            prefix: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 14),
              child: Text(
                "${Constant.currencyModel!.symbol}",
                style: TextStyle(
                  color: isDark
                      ? AppThemeData.grey50
                      : AppThemeData.grey900,
                  fontFamily: AppThemeData.semiBold,
                  fontSize: 16,
                ),
              ),
            ),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
            ],
            textInputType: const TextInputType.numberWithOptions(
                signed: true, decimal: true),
            onchange: (v) =>
            controller.addonsList[index].value = v,
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(top: 28),
          child: IconButton(
            onPressed: () =>
                controller.addonsList.removeAt(index),
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppThemeData.danger300,
              size: 20,
            ),
            tooltip: "Remove".tr,
          ),
        ),
      ],
    );
  }
}

/// Small icon-button to add a new item to a list.
class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _AddButton({required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppThemeData.secondary300.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(Icons.add_rounded,
                size: 16, color: AppThemeData.secondary300),
            const SizedBox(width: 4),
            Text(
              "Add".tr,
              style:  TextStyle(
                fontSize: 13,
                fontFamily: AppThemeData.medium,
                color: AppThemeData.secondary300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom save bar.
class _SaveBar extends StatelessWidget {
  final bool isDark;
  final VoidCallback onSave;

  const _SaveBar({required this.isDark, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConst.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "Save Details".tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: AppThemeData.semiBold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Image source option button used in the bottom sheet.
class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppThemeData.grey700
                    : AppThemeData.grey200,
              ),
            ),
            child: Icon(icon,
                size: 30, color: AppThemeData.secondary300),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppThemeData.medium,
              color: isDark
                  ? AppThemeData.grey200
                  : AppThemeData.grey700,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Availability Section (unchanged logic, improved UI)
// ═══════════════════════════════════════════════════════════════════════════

class _AvailabilitySection extends StatelessWidget {
  final AddProductController controller;
  const _AvailabilitySection({required this.controller});

  static const _days = [
    'Monday', 'Tuesday', 'Wednesday',
    'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark =
    Provider.of<DarkThemeProvider>(context, listen: false).getThem();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SectionHeader(
                icon: Icons.access_time_rounded,
                label: "Available Times".tr,
                isDark: isDark,
              ),
            ),
            TextButton.icon(
              onPressed: () => _openEditor(context),
              icon: Icon(
                controller.availableDays.isEmpty
                    ? Icons.add_circle_outline
                    : Icons.edit_outlined,
                size: 16,
              ),
              label: Text(
                controller.availableDays.isEmpty
                    ? "Set timings".tr
                    : "Edit".tr,
                style: const TextStyle(
                    fontFamily: AppThemeData.medium),
              ),
              style: TextButton.styleFrom(
                  foregroundColor: AppThemeData.secondary300),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.availableDays.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.all_inclusive_rounded,
                      size: 16,
                      color: isDark
                          ? AppThemeData.grey400
                          : AppThemeData.grey500),
                  const SizedBox(width: 8),
                  Text(
                    "Available all day, every day".tr,
                    style: TextStyle(
                      color: isDark
                          ? AppThemeData.grey400
                          : AppThemeData.grey600,
                      fontFamily: AppThemeData.regular,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return Wrap(
            spacing: 6,
            runSpacing: 6,
            children: controller.availableDays.map((day) {
              final slots =
                  controller.availableTimings[day] ?? [];
              final label = slots.isEmpty
                  ? day
                  : '$day: ${slots.map((s) => '${s.from}–${s.to}').join(', ')}';
              return Chip(
                label: Text(label,
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: AppThemeData.secondary300
                    .withOpacity(0.1),
                side:  BorderSide(
                    color: AppThemeData.secondary300,
                    width: 0.8),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final isDark =
    Provider.of<DarkThemeProvider>(context, listen: false).getThem();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppThemeData.grey700
                          : AppThemeData.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Edit Available Times".tr,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          fontSize: 16,
                          color: isDark
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(),
                        child: Text("Done".tr,
                            style: const TextStyle(
                                fontFamily:
                                AppThemeData.semiBold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _days.length,
                      itemBuilder: (context, i) {
                        final day = _days[i];
                      return Obx(() {
                        final isSelected = controller.availableDays.contains(day);
                        final slots = controller.availableTimings[day] ?? [];
                        final sub = slots.isEmpty
                            ? (isSelected ? "Tap to add time".tr : "")
                            : slots.map((s) => '${s.from} – ${s.to}').join(', ');

                        return AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 180),
                          margin: const EdgeInsets.only(
                              bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppThemeData
                                .secondary300
                                .withOpacity(0.08)
                                : isDark
                                ? const Color(
                                0xFF2C2C2E)
                                : const Color(
                                0xFFF9FAFB),
                            borderRadius:
                            BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppThemeData
                                  .secondary300
                                  .withOpacity(0.4)
                                  : isDark
                                  ? AppThemeData
                                  .grey700
                                  : AppThemeData
                                  .grey200,
                              width: 1.2,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                            const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4),
                            leading: Checkbox(
                              value: isSelected,
                              activeColor:
                              AppThemeData.secondary300,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(4),
                              ),
                              onChanged: (v) {
                                if (v == true) {
                                  if (!controller
                                      .availableDays
                                      .contains(day)) {
                                    controller.availableDays
                                        .add(day);
                                  }
                                  controller
                                      .availableTimings
                                      .putIfAbsent(
                                      day,
                                          () => <
                                          TimeRangeItem>[]);
                                } else {
                                  controller.availableDays
                                      .remove(day);
                                  controller
                                      .availableTimings
                                      .remove(day);
                                }
                              },
                            ),
                            title: Text(
                              day.tr,
                              style: TextStyle(
                                fontFamily:
                                AppThemeData.medium,
                                fontSize: 14,
                                color: isDark
                                    ? AppThemeData.grey100
                                    : AppThemeData.grey800,
                              ),
                            ),
                            subtitle: sub.isNotEmpty
                                ? Text(
                              sub,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppThemeData
                                    .grey400
                                    : AppThemeData
                                    .grey500,
                              ),
                            )
                                : null,
                            onTap: isSelected
                                ? () => _pickTimeRange(
                                context, day)
                                : null,
                            trailing: isSelected &&
                                slots.isNotEmpty
                                ? IconButton(
                              icon: const Icon(
                                  Icons
                                      .delete_outline,
                                  size: 18),
                              onPressed: () {
                                controller
                                    .availableTimings[
                                day] = [];
                              },
                            )
                                : null,
                          ),
                        );
                      });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickTimeRange(
      BuildContext context, String day) async {
    final from = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (from == null) return;
    final to = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 22, minute: 0),
    );
    if (to == null) return;

    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final range = TimeRangeItem(from: fmt(from), to: fmt(to));
    final current = List<TimeRangeItem>.from(
        controller.availableTimings[day] ?? []);
    current.isEmpty ? current.add(range) : current[0] = range;
    controller.availableTimings[day] = current;
  }
}