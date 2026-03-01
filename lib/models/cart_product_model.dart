import 'dart:convert';

class CartProductModel {
  String? id;
  String? categoryId;
  String? name;
  String? photo;
  String? price;
  String? discountPrice;
  String? merchant_price;
  String? vendorID;
  int? quantity;
  String? extrasPrice;
  List<dynamic>? extras;
  VariantInfo? variantInfo;

  CartProductModel({
    this.id,
    this.categoryId,
    this.name,
    this.photo,
    this.price,
    this.discountPrice,
    this.merchant_price,
    this.vendorID,
    this.quantity,
    this.extrasPrice,
    this.variantInfo,
    this.extras,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return CartProductModel(
        id: json['id']?.toString(),
        categoryId: json['category_id']?.toString(),
        name: json['name']?.toString(),
        photo: json['photo']?.toString(),
        price: json['price']?.toString() ?? '0.0',
        discountPrice: json['discountPrice']?.toString() ?? '0.0',
        merchant_price: _parseMerchantPrice(json['merchant_price'], json['price']),
        vendorID: json['vendorID']?.toString(),
        quantity: _parseInt(json['quantity']),
        extrasPrice: json['extras_price']?.toString() ?? '0.0',
        extras: json['extras'] is List ? json['extras'] : [],
        variantInfo: _parseVariantInfo(json['variant_info']),
      );
    } catch (e) {
      print('❌ Error parsing CartProductModel: $e');
      print('Problematic product data: $json');
      // Return a default product instead of failing completely
      return CartProductModel(
        id: json['id']?.toString() ?? 'unknown',
        name: json['name']?.toString() ?? 'Unknown Product',
        price: '0.0',
        discountPrice: '0.0',
        merchant_price: '0.0',
        quantity: 1,
        extrasPrice: '0.0',
        extras: [],
      );
    }
  }

  /// Use merchant_price from JSON; if missing or zero, fall back to price so vendor total is preserved.
  static String _parseMerchantPrice(dynamic merchantPrice, dynamic price) {
    final String p = price?.toString() ?? '0.0';
    final String mp = merchantPrice?.toString() ?? '0.0';
    if (mp.isEmpty || mp == '0' || mp == '0.0') return p;
    return mp;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    if (value is num) return value.toInt();
    return 1;
  }

  static VariantInfo? _parseVariantInfo(dynamic variantData) {
    if (variantData == null) return null;

    try {
      if (variantData is Map<String, dynamic>) {
        return VariantInfo.fromJson(variantData);
      } else if (variantData is String) {
        // Try to parse as JSON string
        final decoded = jsonDecode(variantData);
        if (decoded is Map<String, dynamic>) {
          return VariantInfo.fromJson(decoded);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error parsing variant info: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['name'] = name;
    data['photo'] = photo;
    data['price'] = price;
    data['discountPrice'] = discountPrice;
    data['merchant_price'] = merchant_price;
    data['vendorID'] = vendorID;
    data['quantity'] = quantity;
    data['extras_price'] = extrasPrice;
    data['extras'] = extras;
    if (variantInfo != null) {
      data['variant_info'] = variantInfo!.toJson();
    }
    return data;
  }
}

class VariantInfo {
  String? variantId;
  String? variantPrice;
  String? variantSku;
  String? variantImage;
  Map<String, dynamic>? variantOptions;

  VariantInfo({
    this.variantId,
    this.variantPrice,
    this.variantSku,
    this.variantImage,
    this.variantOptions,
  });

  factory VariantInfo.fromJson(Map<String, dynamic> json) {
    try {
      return VariantInfo(
        variantId: json['variant_id']?.toString() ?? '',
        variantPrice: json['variant_price']?.toString() ?? '',
        variantSku: json['variant_sku']?.toString() ?? '',
        variantImage: json['variant_image']?.toString() ?? '',
        variantOptions: json['variant_options'] is Map ? Map<String, dynamic>.from(json['variant_options']) : {},
      );
    } catch (e) {
      print('❌ Error parsing VariantInfo: $e');
      return VariantInfo();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['variant_id'] = variantId;
    data['variant_price'] = variantPrice;
    data['variant_sku'] = variantSku;
    data['variant_image'] = variantImage;
    data['variant_options'] = variantOptions ?? {};
    return data;
  }
}