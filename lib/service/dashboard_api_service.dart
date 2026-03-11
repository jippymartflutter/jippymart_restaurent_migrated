import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/dashboard_model.dart';

/// Dashboard filter values supported by the API.
enum DashboardFilter {
  none,
  lastWeek,
  lastMonth,
}

extension DashboardFilterExt on DashboardFilter {
  String? get queryValue {
    switch (this) {
      case DashboardFilter.none:
        return null;
      case DashboardFilter.lastWeek:
        return 'last_week';
      case DashboardFilter.lastMonth:
        return 'last_month';
    }
  }
}

/// Fetches vendor dashboard data.
/// API: GET {{baseURL}}vendor/dashboard?vendor_id=...&filter=last_week|last_month
class DashboardApiService {
  static String get _baseUrl => Constant.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET vendor/dashboard?vendor_id=...&filter=...
  /// [vendorId] current vendor ID (e.g. Constant.userModel?.vendorID).
  /// [filter] optional: last_week, last_month; omit for all data.
  static Future<DashboardModel?> getDashboard({
    required String vendorId,
    DashboardFilter filter = DashboardFilter.none,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty) return null;

    try {
      final queryParams = <String>['vendor_id=${Uri.encodeComponent(id)}'];
      final filterValue = filter.queryValue;
      if (filterValue != null && filterValue.isNotEmpty) {
        queryParams.add('filter=${Uri.encodeComponent(filterValue)}');
      }
      final url = '${_baseUrl}vendor/dashboard?${queryParams.join('&')}';
      final response = await http.get(Uri.parse(url), headers: _headers);

      final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (bodyStr.isEmpty) return null;

      final json = jsonDecode(bodyStr) as Map<String, dynamic>;
      return DashboardModel.fromJson(json);
    } catch (e, st) {
      print('DashboardApiService.getDashboard error: $e $st');
      return null;
    }
  }

  /// GET vendor/SettledReport?vendor_id=...&filter=...
  /// Same response shape as dashboard. Use for "Settled earnings" report.
  static Future<DashboardModel?> getSettledReport({
    required String vendorId,
    DashboardFilter filter = DashboardFilter.none,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty) return null;

    try {
      final queryParams = <String>['vendor_id=${Uri.encodeComponent(id)}'];
      final filterValue = filter.queryValue;
      if (filterValue != null && filterValue.isNotEmpty) {
        queryParams.add('filter=${Uri.encodeComponent(filterValue)}');
      }
      final url = '${_baseUrl}vendor/SettledReport?${queryParams.join('&')}';
      final response = await http.get(Uri.parse(url), headers: _headers);

      final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (bodyStr.isEmpty) return null;

      final json = jsonDecode(bodyStr) as Map<String, dynamic>;
      return DashboardModel.fromJson(json);
    } catch (e, st) {
      print('DashboardApiService.getSettledReport error: $e $st');
      return null;
    }
  }
}
