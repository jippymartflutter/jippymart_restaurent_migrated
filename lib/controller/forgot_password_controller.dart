import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/constant/show_toast_dialog.dart';

class ForgotPasswordController extends GetxController {
  Rx<TextEditingController> emailEditingController =
      TextEditingController().obs;
  forgotPassword() async {
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final body = {
        "email": emailEditingController.value.text.trim(),
      };
      final response = await http.post(
        Uri.parse("${Constant.baseUrl}restaurant/forgot-password"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      ShowToastDialog.closeLoader();
      if (response.statusCode == 200) {
        ShowToastDialog.showToast(
          "Reset password link sent to ${emailEditingController.value.text}",
        );
        Get.back();
      } else {
        ShowToastDialog.showToast(
          "Failed: ${response.body}",
        );
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Something went wrong: $e");
    }
  }
}
