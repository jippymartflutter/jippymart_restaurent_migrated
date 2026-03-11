import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/models/subscription_plan_model.dart';

/// Fetches subscription plans for the current zone.
/// API: GET {{baseURL}}subscription-plans?zone_id=...
class SubscriptionApiService {
  static String get _baseUrl => Constant.baseUrl;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// GET subscription-plans?zone_id=...
  /// [zoneId] should be resolved by the caller from restaurant/vendor details or user/preferences.
  /// Returns list of plans or null on failure.
  static Future<SubscriptionPlansResponse?> getSubscriptionPlans({
    required String zoneId,
  }) async {
    final zoneIdValue = zoneId.trim();
    if (zoneIdValue.isEmpty) {
      return SubscriptionPlansResponse(
        success: false,
        message: 'Zone not set',
        data: [],
      );
    }

    try {
      final url = '${_baseUrl}subscription-plans?zone_id=${Uri.encodeComponent(zoneIdValue)}';
      final response = await http.get(Uri.parse(url), headers: _headers);

      final bodyStr = response.body.replaceFirst(RegExp(r'^\uFEFF'), '').trim();
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

      return SubscriptionPlansResponse(
        success: success,
        message: message,
        data: data,
      );
    } catch (e, st) {
      print('SubscriptionApiService.getSubscriptionPlans error: $e $st');
      return null;
    }
  }
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
