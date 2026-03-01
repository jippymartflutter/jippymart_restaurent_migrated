import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class EditProfileController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<UserModel> userModel = UserModel().obs;

  Rx<TextEditingController> firstNameController = TextEditingController().obs;
  Rx<TextEditingController> lastNameController = TextEditingController().obs;
  Rx<TextEditingController> emailController = TextEditingController().obs;
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeController =
      TextEditingController(text: "+91").obs;

  /// Cached for this screen session to avoid repeated getCurrentUid() calls.
  String? _userId;
  bool _isSaving = false;

  @override
  void onInit() {
    getData();
    super.onInit();
  }

  /// Load profile once: use Constant.userModel when already set for current user, else fetch (with cache).
  Future<void> getData() async {
    final userId = await FireStoreUtils.getCurrentUid();
    _userId = userId;

    UserModel? value;
    if (Constant.userModel != null && Constant.userModel!.id == userId) {
      value = Constant.userModel;
    } else {
      value = await FireStoreUtils.getUserProfile(userId, forceRefresh: false);
    }

    if (value != null) {
      userModel.value = value;
      firstNameController.value.text = value.firstName ?? '';
      lastNameController.value.text = value.lastName ?? '';
      emailController.value.text = value.email ?? '';
      phoneNumberController.value.text = value.phoneNumber ?? '';
      countryCodeController.value.text = value.countryCode ?? '+91';
      profileImage.value = value.profilePictureURL ?? '';
    }
    isLoading.value = false;
  }

  Future<void> saveData() async {
    if (_isSaving) return;
    _isSaving = true;
    ShowToastDialog.showLoader("Please wait...".tr);
    try {
      if (Constant().hasValidUrl(profileImage.value) == false &&
          profileImage.value.isNotEmpty) {
        final pathId = _userId ?? userModel.value.id ?? await FireStoreUtils.getCurrentUid();
        profileImage.value = await Constant.uploadUserImageToFireStorage(
          File(profileImage.value),
          "profileImage/$pathId",
          File(profileImage.value).path.split('/').last,
        );
      }
      userModel.value.firstName = firstNameController.value.text;
      userModel.value.lastName = lastNameController.value.text;
      userModel.value.profilePictureURL = profileImage.value;

      final success = await FireStoreUtils.updateUser(userModel.value);
      if (success) {
        Get.back(result: true);
      } else {
        ShowToastDialog.showToast('Failed to update profile. Please try again.'.tr);
      }
    } catch (e) {
      ShowToastDialog.showToast('${"Failed to save".tr}: $e');
    } finally {
      _isSaving = false;
      ShowToastDialog.closeLoader();
    }
  }

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
    } on PlatformException catch (e) {
      ShowToastDialog.showToast("${"failed_to_pick".tr} : \n $e");
    }
  }
}
