import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/currency_model.dart';
import 'package:jippymart_restaurant/models/user_model.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';
import 'package:jippymart_restaurant/utils/notification/notification_service.dart';
import 'package:get/get.dart';
import '../constant/collection_name.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();

    super.onInit();
  }

  getCurrentCurrency() async {
    try {
      final response = await http.get(
        Uri.parse('${Constant.baseUrl}settings/getActiveCurrency'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          Constant.currencyModel = CurrencyModel.fromJson(jsonResponse['data']);
        } else {
          _setDefaultCurrency();
        }
      } else {
        _setDefaultCurrency();
      }
    } catch (e) {
      _setDefaultCurrency();
    }
    await FireStoreUtils().getSettings();
  }
  _setDefaultCurrency() {
    Constant.currencyModel = CurrencyModel(
      id: "664d8fc37be19",
      code: "INR",
      decimalDigits: 2,
      enable: true,
      name: "Indian Rupee",
      symbol: "₹",
      symbolAtRight: false,
    );
  }

  NotificationService notificationService = NotificationService();

  notificationInit() {
    notificationService.initInfo().then((value) async {
      String userId = await FireStoreUtils.getCurrentUid();
      String token = await NotificationService.getToken();
      await FireStoreUtils.getUserProfile(userId)
          .then((value) {
        if (value != null) {
          UserModel driverUserModel = value;
          driverUserModel.fcmToken = token;
          FireStoreUtils.updateUser(driverUserModel);
        }
      });
        });
  }
}
