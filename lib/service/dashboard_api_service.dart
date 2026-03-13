import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/dashboard_model.dart';
import 'package:jippymart_restaurant/config/app_config.dart';

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

  static final Map<String, _CachedDashboard> _cache = {};
  static const Duration _ttl = Duration(seconds: 90);

  static String _makeKey({
    required String vendorId,
    required String endpoint,
    required DashboardFilter filter,
  }) {
    return '$endpoint|$vendorId|${filter.queryValue ?? 'none'}';
  }

  static DashboardModel? _getFromCache(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }
    return entry.data;
  }

  static void _saveToCache(String key, DashboardModel data) {
    _cache[key] = _CachedDashboard(
      data: data,
      expiresAt: DateTime.now().add(_ttl),
    );
    if (AppConfig.enableDebugLogs) {
      // ignore: avoid_print
      print('DashboardApiService cache saved for key=$key');
    }
  }

  /// GET vendor/dashboard?vendor_id=...&filter=...
  /// [vendorId] current vendor ID (e.g. Constant.userModel?.vendorID).
  /// [filter] optional: last_week, last_month; omit for all data.
  static Future<DashboardModel?> getDashboard({
    required String vendorId,
    DashboardFilter filter = DashboardFilter.none,
    bool forceRefresh = false,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty) return null;

    final cacheKey = _makeKey(
      vendorId: id,
      endpoint: 'dashboard',
      filter: filter,
    );
    if (!forceRefresh) {
      final cached = _getFromCache(cacheKey);
      if (cached != null) {
        if (AppConfig.enableDebugLogs) {
          // ignore: avoid_print
          print('DashboardApiService.getDashboard using cached data for $cacheKey');
        }
        return cached;
      }
    }

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
      final model = DashboardModel.fromJson(json);
      _saveToCache(cacheKey, model);
      return model;
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
    bool forceRefresh = false,
  }) async {
    final id = vendorId.trim();
    if (id.isEmpty) return null;

    final cacheKey = _makeKey(
      vendorId: id,
      endpoint: 'settled',
      filter: filter,
    );
    if (!forceRefresh) {
      final cached = _getFromCache(cacheKey);
      if (cached != null) {
        if (AppConfig.enableDebugLogs) {
          // ignore: avoid_print
          print('DashboardApiService.getSettledReport using cached data for $cacheKey');
        }
        return cached;
      }
    }

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
      final model = DashboardModel.fromJson(json);
      _saveToCache(cacheKey, model);
      return model;
    } catch (e, st) {
      print('DashboardApiService.getSettledReport error: $e $st');
      return null;
    }
  }
}

class _CachedDashboard {
  _CachedDashboard({
    required this.data,
    required this.expiresAt,
  });

  final DashboardModel data;
  final DateTime expiresAt;
}
