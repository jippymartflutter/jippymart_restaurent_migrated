import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';
import 'package:jippymart_restaurant/config/app_config.dart';

/// Fetches subscription plans for the current zone.
/// API: GET {{baseURL}}subscription-plans?zone_id=...
class SubscriptionApiService {
  static String get _baseUrl => Constant.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static final Map<String, _CachedPlans> _cache = {};
  static const Duration _ttl = Duration(minutes: 2);

  static SubscriptionPlansResponse? _getFromCache(String zoneId) {
    final entry = _cache[zoneId];
    if (entry == null) return null;
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(zoneId);
      return null;
    }
    return entry.data;
  }

  static void _saveToCache(String zoneId, SubscriptionPlansResponse data) {
    _cache[zoneId] = _CachedPlans(
      data: data,
      expiresAt: DateTime.now().add(_ttl),
    );
    if (AppConfig.enableDebugLogs) {
      // ignore: avoid_print
      print('SubscriptionApiService cache saved for zone=$zoneId');
    }
  }

  /// GET subscription-plans?zone_id=...
  /// [zoneId] should be resolved by the caller from restaurant/vendor details or user/preferences.
  /// Returns list of plans or null on failure.
  static Future<SubscriptionPlansResponse?> getSubscriptionPlans({
    required String zoneId,
    bool forceRefresh = false,
  }) async {
    final zoneIdValue = zoneId.trim();
    if (zoneIdValue.isEmpty) {
      return SubscriptionPlansResponse(
        success: false,
        message: 'Zone not set',
        data: [],
      );
    }

    if (!forceRefresh) {
      final cached = _getFromCache(zoneIdValue);
      if (cached != null) {
        if (AppConfig.enableDebugLogs) {
          // ignore: avoid_print
          print('SubscriptionApiService.getSubscriptionPlans using cached data for zone=$zoneIdValue');
        }
        return cached;
      }
    }

    try {
      final url = '${_baseUrl}subscription-plans?zone_id=${Uri.encodeComponent(zoneIdValue)}';
      final httpResponse = await http.get(Uri.parse(url), headers: _headers);

      final bodyStr = httpResponse.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
      if (bodyStr.isEmpty) {
        return SubscriptionPlansResponse(
          success: false,
          message: 'Empty response',
          data: [],
        );
      }

      final json = jsonDecode(bodyStr) as Map<String, dynamic>;
      final success = json['success'] == true;
      final message = json['message']?.toString() ?? '';

      final dataList = json['data'] as List<dynamic>? ?? [];
      final data = dataList
          .map((e) => SubscriptionPlanModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();

      final response = SubscriptionPlansResponse(
        success: success,
        message: message,
        data: data,
      );
      _saveToCache(zoneIdValue, response);
      return response;
    } catch (e, st) {
      print('SubscriptionApiService.getSubscriptionPlans error: $e $st');
      return null;
    }
  }
}

class _CachedPlans {
  _CachedPlans({
    required this.data,
    required this.expiresAt,
  });

  final SubscriptionPlansResponse data;
  final DateTime expiresAt;
}

class SubscriptionPlansResponse {
  final bool success;
  final String message;
  final List<SubscriptionPlanModel> data;

  SubscriptionPlansResponse({
    required this.success,
    required this.message,
    required this.data,
  });
}
