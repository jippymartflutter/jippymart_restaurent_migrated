import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/controller/home_controller.dart';
import 'package:jippymart_restaurant/controller/product_list_controller.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/models/vendor_category_model.dart';
import 'package:jippymart_restaurant/models/vendor_model.dart';
import 'package:jippymart_restaurant/models/zone_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/widget/geoflutterfire/src/geoflutterfire.dart';

class AddRestaurantController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isAddressEnable = false.obs;
  RxBool isEnableDeliverySettings = true.obs;
  final myKey1 = GlobalKey<DropdownSearchState<VendorCategoryModel>>();

  Rx<TextEditingController> restaurantNameController =
      TextEditingController().obs;
  Rx<TextEditingController> restaurantDescriptionController =
      TextEditingController().obs;
  Rx<TextEditingController> mobileNumberController =
      TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController =
      TextEditingController().obs;
  Rx<TextEditingController> addressController = TextEditingController().obs;

  Rx<TextEditingController> chargePerKmController = TextEditingController().obs;
  Rx<TextEditingController> minDeliveryChargesController =
      TextEditingController().obs;
  Rx<TextEditingController> minDeliveryChargesWithinKMController =
      TextEditingController().obs;

  LatLng? selectedLocation;

  RxList images = <dynamic>[].obs;

  RxList<VendorCategoryModel> vendorCategoryList = <VendorCategoryModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  Rx<ZoneModel> selectedZone = ZoneModel().obs;

  // Rx<VendorCategoryModel> selectedCategory = VendorCategoryModel().obs;
  RxList selectedService = [].obs;

  RxList<VendorCategoryModel> selectedCategories = <VendorCategoryModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getRestaurant();
    super.onInit();
  }

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;
  Rx<DeliveryCharge> deliveryChargeModel = DeliveryCharge().obs;
  RxBool isSelfDelivery = false.obs;
  getRestaurant() async {
    try {
      String userId = await FireStoreUtils.getCurrentUid();
      await FireStoreUtils.getUserProfile(userId).then((model) {
        if (model != null) {
          userModel.value = model;
        }
      });

      await FireStoreUtils.getVendorCategoryById().then((value) {
        if (value != null) {
          vendorCategoryList.value = value;
        }
      });

      await FireStoreUtils.getZone().then((value) {
        if (value != null) {
          zoneList.value = value;
        }
      });
      if (Constant.userModel?.vendorID != null &&
          Constant.userModel?.vendorID?.isNotEmpty == true) {
        await FireStoreUtils.getVendorById(
            Constant.userModel!.vendorID.toString())
            .then(
              (value) {
            if (value != null) {
              vendorModel.value = value;

              restaurantNameController.value.text =
                  vendorModel.value.title.toString();
              restaurantDescriptionController.value.text =
                  vendorModel.value.description.toString();
              mobileNumberController.value.text =
                  vendorModel.value.phonenumber.toString();
              addressController.value.text =
                  vendorModel.value.location.toString();
              isSelfDelivery.value = vendorModel.value.isSelfDelivery ?? false;
              if (addressController.value.text.isNotEmpty) {
                isAddressEnable.value = true;
              }
              selectedLocation = LatLng(
                  vendorModel.value.latitude!, vendorModel.value.longitude!);
              for (var element in vendorModel.value.photos!) {
                images.add(element);
              }

              for (var element in zoneList) {
                if (element.id == vendorModel.value.zoneId) {
                  selectedZone.value = element;
                }
              }

              if (vendorModel.value.categoryID!.isNotEmpty) {
                selectedCategories.value = vendorCategoryList
                    .where((category) =>
                    vendorModel.value.categoryID!.contains(category.id))
                    .toList();
              }

              vendorModel.value.filters!.toJson().forEach((key, value) {
                if (value.contains("Yes")) {
                  selectedService.add(key);
                }
              });
            }
          },
        );
      }

      await FireStoreUtils.getDelivery().then((value) {
        if (value != null) {
          deliveryChargeModel.value = value;
          isEnableDeliverySettings.value =
              deliveryChargeModel.value.vendorCanModify ?? false;
          if (value.vendorCanModify == true) {
            if (vendorModel.value.deliveryCharge != null) {
              chargePerKmController.value.text = vendorModel
                  .value.deliveryCharge!.deliveryChargesPerKm
                  .toString();
              minDeliveryChargesController.value.text = vendorModel
                  .value.deliveryCharge!.minimumDeliveryCharges
                  .toString();
              minDeliveryChargesWithinKMController.value.text = vendorModel
                  .value.deliveryCharge!.minimumDeliveryChargesWithinKm
                  .toString();
            }
          } else {
            chargePerKmController.value.text =
                deliveryChargeModel.value.deliveryChargesPerKm.toString();
            minDeliveryChargesController.value.text =
                deliveryChargeModel.value.minimumDeliveryCharges.toString();
            minDeliveryChargesWithinKMController.value.text =
                deliveryChargeModel.value.minimumDeliveryChargesWithinKm
                    .toString();
          }
        }
      });
    } catch (e) {
      print(e);
    }

    isLoading.value = false;
  }

  saveDetails() async {
    try {
      if (restaurantNameController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter restaurant name".tr);
      } else if (restaurantDescriptionController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter Description".tr);
      } else if (mobileNumberController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter phone number".tr);
      } else if (addressController.value.text.isEmpty) {
        ShowToastDialog.showToast("Please enter address".tr);
      } else if (selectedZone.value.id == null) {
        ShowToastDialog.showToast("Please select zone".tr);
      } else if (selectedCategories.isEmpty) {
        ShowToastDialog.showToast("Please select category".tr);
      } else if (isEnableDeliverySettings.value &&
          (chargePerKmController.value.text.isEmpty ||
              minDeliveryChargesController.value.text.isEmpty ||
              minDeliveryChargesWithinKMController.value.text.isEmpty)) {
        ShowToastDialog.showToast(
            "Please enter all delivery charge details".tr);
        return;
      } else {
        if (Constant.isPointInPolygon(
            selectedLocation!, selectedZone.value.area!)) {
          ShowToastDialog.showLoader("Please wait".tr);
          try {
            filter();
          // Safe number parsing with default values
          DeliveryCharge deliveryChargeModel = DeliveryCharge(
            vendorCanModify: true,
            deliveryChargesPerKm: _parseNumber(
                chargePerKmController.value.text) ?? 0.0,
            minimumDeliveryCharges: _parseNumber(
                minDeliveryChargesController.value.text) ?? 0.0,
            minimumDeliveryChargesWithinKm: _parseNumber(
                minDeliveryChargesWithinKMController.value.text) ?? 0.0,
          );
          if (vendorModel.value.id == null) {
            vendorModel.value = VendorModel();
            vendorModel.value.createdAt = Timestamp.now();
          }
          List<Future<String>> uploadFutures = [];
          List<int> uploadIndices = [];
          String userId = await FireStoreUtils.getCurrentUid();
          for (int i = 0; i < images.length; i++) {
            if (images[i].runtimeType == XFile) {
              uploadIndices.add(i);
              uploadFutures.add(
                Constant.uploadUserImageToFireStorage(
                  File(images[i].path),
                  "vendor/${userId}/restaurant",
                  "${DateTime.now().millisecondsSinceEpoch}_${File(images[i].path).path.split('/').last}",
                ).timeout(
                  const Duration(seconds: 30),
                  onTimeout: () {
                    throw TimeoutException('Image upload timed out after 30 seconds');
                  },
                ),
              );
            }
          }
          // Wait for all uploads to complete in parallel with error handling
          if (uploadFutures.isNotEmpty) {
            try {
              print("📤 Uploading ${uploadFutures.length} image(s)...");
              List<String> uploadedUrls = await Future.wait(uploadFutures, eagerError: false)
                  .timeout(
                    const Duration(seconds: 60),
                    onTimeout: () {
                      throw TimeoutException('Image uploads timed out after 60 seconds');
                    },
                  );
              print("✅ Successfully uploaded ${uploadedUrls.length} image(s)");
              for (int i = 0; i < uploadIndices.length; i++) {
                if (i < uploadedUrls.length && uploadedUrls[i].isNotEmpty) {
                  images[uploadIndices[i]] = uploadedUrls[i];
                }
              }
            } catch (uploadError) {
              print("❌ Error uploading images: $uploadError");
              // Don't block the save process - just show a warning
              String errorMessage = "Some images failed to upload. Saving restaurant details without images.";
              if (uploadError is TimeoutException) {
                errorMessage = "Image upload timed out. Saving restaurant details without images.";
              } else if (uploadError.toString().contains("auth") || uploadError.toString().contains("403")) {
                errorMessage = "Image upload failed due to authentication error. Saving restaurant details without images.";
              }
              ShowToastDialog.showToast(errorMessage.tr);
              for (int i = uploadIndices.length - 1; i >= 0; i--) {
                if (images[uploadIndices[i]].runtimeType == XFile) {
                  images.removeAt(uploadIndices[i]);
                }
              }
            }
          }
          if (Constant.userModel?.vendorID?.isNotEmpty == true) {
            vendorModel.value.id = Constant.userModel?.vendorID;
          }
          vendorModel.value.author = Constant.userModel!.id;
          vendorModel.value.authorName = Constant.userModel!.firstName;
          vendorModel.value.authorProfilePic =
              Constant.userModel!.profilePictureURL;

          vendorModel.value.categoryID =
              selectedCategories.map((e) => e.id ?? '').toList();
          vendorModel.value.categoryTitle =
              selectedCategories.map((e) => e.title ?? '').toList();
          vendorModel.value.g = G(
              geohash: Geoflutterfire()
                  .point(
                  latitude: selectedLocation!.latitude,
                  longitude: selectedLocation!.longitude)
                  .hash,
              geopoint: GeoPoint(
                  selectedLocation!.latitude, selectedLocation!.longitude));
          vendorModel.value.description =
              restaurantDescriptionController.value.text;
          vendorModel.value.phonenumber = mobileNumberController.value.text;
          vendorModel.value.filters = Filters.fromJson(filters);
          vendorModel.value.location = addressController.value.text;
          vendorModel.value.latitude = selectedLocation!.latitude;
          vendorModel.value.longitude = selectedLocation!.longitude;
          vendorModel.value.photos = images;
          if (images.isNotEmpty) {
            vendorModel.value.photo = images.first;
          } else {
            vendorModel.value.photo = null;
          }
          vendorModel.value.deliveryCharge = deliveryChargeModel;
          vendorModel.value.title = restaurantNameController.value.text;
          vendorModel.value.zoneId = selectedZone.value.id;
          vendorModel.value.isSelfDelivery = isSelfDelivery.value;
          if (Constant.adminCommission!.isEnabled == true ||
              Constant.isSubscriptionModelApplied == true) {
            vendorModel.value.subscriptionPlanId =
                userModel.value.subscriptionPlanId;
            vendorModel.value.subscriptionPlan =
                userModel.value.subscriptionPlan;
            vendorModel.value.subscriptionExpiryDate =
                userModel.value.subscriptionExpiryDate;
            vendorModel.value.subscriptionTotalOrders =
                userModel.value.subscriptionPlan?.orderLimit;
          }
          if (Constant.userModel?.vendorID?.isNotEmpty == true) {
            try {
              print("🔄 Updating existing vendor: ${vendorModel.value.id}");
              final updatedVendor = await FireStoreUtils.updateVendor(vendorModel.value)
                  .timeout(
                    const Duration(seconds: 30),
                    onTimeout: () {
                      throw TimeoutException('Vendor update timed out after 30 seconds');
                    },
                  );
              if (updatedVendor != null) {
                print("✅ Vendor updated successfully");
                ShowToastDialog.showToast(
                    "Restaurant details save successfully".tr);
                await _handleSuccessfulSave(updatedVendor);
                Get.back(result: true);
              } else {
                print("❌ Vendor update returned null");
                ShowToastDialog.showToast(
                    "Failed to save restaurant details".tr);
              }
            } catch (error) {
              print("❌ Error updating vendor: $error");
              ShowToastDialog.showToast(
                  "Failed to save restaurant details: ${error.toString()}".tr);
              rethrow;
            }
          } else {
            vendorModel.value.adminCommission = Constant.adminCommission;
            vendorModel.value.workingHours = [
              WorkingHours(
                  day: 'Monday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')]),
              WorkingHours(
                  day: 'Tuesday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')]),
              WorkingHours(
                  day: 'Wednesday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')]),
              WorkingHours(
                  day: 'Thursday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')]),
              WorkingHours(
                  day: 'Friday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')]),
              WorkingHours(
                  day: 'Saturday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')]),
              WorkingHours(
                  day: 'Sunday'.tr,
                  timeslot: [Timeslot(from: '00:00', to: '23:59')])
            ];
            try {
              print("🔄 Creating new vendor...");
              final createdVendor = await FireStoreUtils.firebaseCreateNewVendor(vendorModel.value)
                  .timeout(
                    const Duration(seconds: 30),
                    onTimeout: () {
                      throw TimeoutException('Vendor creation timed out after 30 seconds');
                    },
                  );
              print("✅ Vendor created successfully with ID: ${createdVendor.id}");
              ShowToastDialog.showToast(
                  "Restaurant details save successfully".tr);
              await _handleSuccessfulSave(createdVendor);
              if (Get.isRegistered<HomeController>()) {
                final homeController = Get.find<HomeController>();
                homeController.resumeOrderPolling();
              }
              Get.back(result: true);
            } catch (error) {
              print("❌ Error creating vendor: $error");
              ShowToastDialog.showToast(
                  "Failed to save restaurant details: ${error.toString()}".tr);
              rethrow;
            }
          }
          } finally {
            // Always close loader regardless of success or failure
            ShowToastDialog.closeLoader();
          }
        } else {
          ShowToastDialog.showToast(
              "The chosen area is outside the selected zone.".tr);
        }
      }
    }catch(e){
      ShowToastDialog.closeLoader();
      print("saveDetails $e ");
    }
  }

  // Helper method for safe number parsing
  num? _parseNumber(String value) {
    if (value.isEmpty) return null;
    try {
      return num.parse(value);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> filters = {};

  filter() {
    if (selectedService.contains('Good for Breakfast')) {
      filters['Good for Breakfast'] = 'Yes';
    } else {
      filters['Good for Breakfast'] = 'No';
    }
    if (selectedService.contains('Good for Lunch')) {
      filters['Good for Lunch'] = 'Yes';
    } else {
      filters['Good for Lunch'] = 'No';
    }

    if (selectedService.contains('Good for Dinner')) {
      filters['Good for Dinner'] = 'Yes';
    } else {
      filters['Good for Dinner'] = 'No';
    }

    if (selectedService.contains('Takes Reservations')) {
      filters['Takes Reservations'] = 'Yes';
    } else {
      filters['Takes Reservations'] = 'No';
    }

    if (selectedService.contains('Vegetarian Friendly')) {
      filters['Vegetarian Friendly'] = 'Yes';
    } else {
      filters['Vegetarian Friendly'] = 'No';
    }

    if (selectedService.contains('Live Music')) {
      filters['Live Music'] = 'Yes';
    } else {
      filters['Live Music'] = 'No';
    }

    if (selectedService.contains('Outdoor Seating')) {
      filters['Outdoor Seating'] = 'Yes';
    } else {
      filters['Outdoor Seating'] = 'No';
    }

    if (selectedService.contains('Free Wi-Fi')) {
      filters['Free Wi-Fi'] = 'Yes';
    } else {
      filters['Free Wi-Fi'] = 'No';
    }
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      images.add(image);
      Get.back();
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"Failed to Pick :".tr} \n $e");
    }
  }

  Future<void> _handleSuccessfulSave(VendorModel updatedVendor) async {
    try {
      print("🔄 Handling successful save, vendor ID: ${updatedVendor.id}");
      vendorModel.value = updatedVendor;
      Constant.vendorAdminCommission =
          updatedVendor.adminCommission ?? Constant.vendorAdminCommission;
      
      // Refresh user profile to get the latest vendor ID
      final userId = await FireStoreUtils.getCurrentUid();
      final refreshedUser = await FireStoreUtils.getUserProfile(userId);
      if (refreshedUser != null) {
        Constant.userModel = refreshedUser;
        userModel.value = refreshedUser;
        print("✅ User profile refreshed, vendor ID: ${refreshedUser.vendorID}");
      } else {
        print("⚠️ Warning: User profile refresh returned null");
      }

      // Update HomeController if registered
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        if (refreshedUser != null) {
          homeController.userModel.value = refreshedUser;
        }
        homeController.vendermodel.value = updatedVendor;
        // Start fetching orders if vendor ID is now available
        if (refreshedUser?.vendorID != null && refreshedUser!.vendorID!.isNotEmpty) {
          print("🔄 Starting order fetch for vendor: ${refreshedUser.vendorID}");
          homeController.resumeOrderPolling();
        }
        homeController.update();
      }

      // Update ProductListController if registered
      if (Get.isRegistered<ProductListController>()) {
        final productListController = Get.find<ProductListController>();
        await productListController.getUserProfile();
      }
    } catch (e) {
      print("❌ _handleSuccessfulSave error: $e");
    }
  }
}