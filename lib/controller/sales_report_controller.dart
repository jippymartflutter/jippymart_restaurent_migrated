import 'package:get/get.dart';

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/dashboard_model.dart';
import 'package:jippymart_restaurant/service/dashboard_api_service.dart';

enum ReportType { comingEarnings, settledEarnings }

class SalesReportController extends GetxController {
  final Rx<DashboardModel?> dashboard = Rx<DashboardModel?>(null);
  final RxBool loading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DashboardFilter> selectedFilter = DashboardFilter.none.obs;
  final Rx<ReportType> reportType = ReportType.comingEarnings.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReport();
  }

  void setReportType(ReportType type) {
    if (reportType.value == type) return;
    reportType.value = type;
    fetchReport();
  }

  void setFilter(DashboardFilter filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    fetchReport();
  }

  /// Refreshes data for current report type (coming vs settled) and filter.
  Future<void> fetchReport({bool forceRefresh = false}) async {
    final vendorId = Constant.userModel?.vendorID?.toString() ?? '';
    if (vendorId.isEmpty) {
      loading.value = false;
      errorMessage.value = 'Vendor not found. Please log in again.';
      return;
    }

    loading.value = true;
    errorMessage.value = '';
    dashboard.value = null;

    final DashboardModel? result;
    if (reportType.value == ReportType.settledEarnings) {
      result = await DashboardApiService.getSettledReport(
        vendorId: vendorId,
        filter: selectedFilter.value,
        forceRefresh: forceRefresh,
      );
    } else {
      result = await DashboardApiService.getDashboard(
        vendorId: vendorId,
        filter: selectedFilter.value,
        forceRefresh: forceRefresh,
      );
    }

    loading.value = false;

    if (result != null && result.success) {
      dashboard.value = result;
    } else {
      errorMessage.value = result == null
          ? 'Failed to load report. Check your connection.'
          : 'Could not load sales data.';
    }
  }
}
