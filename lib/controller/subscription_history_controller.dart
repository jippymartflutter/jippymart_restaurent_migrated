import 'package:get/get.dart';
import 'package:jippymart_restaurant/models/subscription_history.dart';
import 'package:jippymart_restaurant/utils/fire_store_utils.dart';

class SubscriptionHistoryController extends GetxController {
  RxBool isLoading = true.obs;
  RxList<SubscriptionHistoryModel> subscriptionHistoryList =
      <SubscriptionHistoryModel>[].obs;

  @override
  void onInit() {
    getAllSubscriptionList();
    super.onInit();
  }

  getAllSubscriptionList() async {
    subscriptionHistoryList.value =
        await FireStoreUtils.getSubscriptionHistory();
    isLoading.value = false;
  }
}
