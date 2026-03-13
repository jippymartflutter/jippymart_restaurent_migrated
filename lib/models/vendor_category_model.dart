import 'dart:convert';

class VendorCategoryModel {
  List<dynamic>? reviewAttributes;
  String? photo;
  String? description;
  String? id;
  String? title;
  bool? isActive;
  VendorCategoryModel({
    this.reviewAttributes,
    this.photo,
    this.description,
    this.id,
    this.title,
    this.isActive,
  });
  VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['review_attributes'];
    if (raw is List) {
      reviewAttributes = raw;
    } else if (raw is String) {
      try {
        reviewAttributes = jsonDecode(raw) as List<dynamic>? ?? [];
      } catch (_) {
        reviewAttributes = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }
    } else {
      reviewAttributes = [];
    }
    photo = json['photo'] ?? "";
    description = json['description'] ?? '';
    final rawId = json['id'] ?? json['category_id'];
    id = rawId?.toString() ?? "";
    final rawTitle = json['title'] ?? json['Title'] ?? json['name'] ?? json['category_name'] ?? json['categoryName'] ?? json['label'];
    title = (rawTitle ?? '').toString().trim();
    isActive = _parseBool(json['isActive']);
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final n = value.toLowerCase();
      if (n == 'true' || n == '1') return true;
      if (n == 'false' || n == '0') return false;
    }
    return null;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_attributes'] = reviewAttributes;
    data['photo'] = photo;
    data['description'] = description;
    data['id'] = id;
    data['title'] = title;
    data['isActive'] = isActive;
    return data;
  }
}