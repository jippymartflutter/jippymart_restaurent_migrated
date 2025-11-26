import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionPlanModel {
  Timestamp? createdAt;
  String? description;
  String? expiryDay;
  Features? features;
  String? id;
  bool? isEnable;
  String? itemLimit;
  String? orderLimit;
  String? name;
  String? price;
  String? place;
  String? image;
  String? type;
  List<String>? planPoints;

  SubscriptionPlanModel({
    this.createdAt,
    this.description,
    this.expiryDay,
    this.features,
    this.id,
    this.isEnable,
    this.itemLimit,
    this.orderLimit,
    this.name,
    this.price,
    this.place,
    this.image,
    this.type,
    this.planPoints,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      createdAt: _parseTimestamp(json['createdAt']),
      description: json['description'],
      expiryDay: json['expiryDay'],
      features: json['features'] == null ? null : Features.fromJson(json['features']),
      id: json['id'],
      isEnable: _parseBool(json['isEnable']),
      itemLimit: json['itemLimit'],
      orderLimit: json['orderLimit'],
      name: json['name'],
      price: json['price'],
      place: json['place'],
      image: json['image'],
      type: json['type'],
      planPoints: _parsePlanPoints(json['plan_points']),
    );
  }

  static List<String>? _parsePlanPoints(dynamic planPoints) {
    if (planPoints == null) return null;
    if (planPoints is int) {
      return [planPoints.toString()];
    }
    if (planPoints is String) {
      return [planPoints];
    }
    if (planPoints is List) {
      return planPoints.map((item) => item.toString()).toList();
    }
    return null;
  }

  static Timestamp? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp;
    if (timestamp is String) {
      try {
        final dateTime = DateTime.parse(timestamp);
        return Timestamp.fromDate(dateTime);
      } catch (e) {
        return null;
      }
    }
    if (timestamp is Map && timestamp['_seconds'] != null && timestamp['_nanoseconds'] != null) {
      return Timestamp(timestamp['_seconds'], timestamp['_nanoseconds']);
    }
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'description': description,
      'expiryDay': expiryDay.toString(),
      'features': features?.toJson(),
      'id': id,
      'isEnable': isEnable,
      'itemLimit': itemLimit.toString(),
      'orderLimit': orderLimit.toString(),
      'name': name,
      'price': price.toString(),
      'place': place.toString(),
      'image': image.toString(),
      'type': type,
      'plan_points': planPoints,
    };
  }
}

class Features {
  bool? chat;
  bool? dineIn;
  bool? qrCodeGenerate;
  bool? restaurantMobileApp;

  Features({
    this.chat,
    this.dineIn,
    this.qrCodeGenerate,
    this.restaurantMobileApp,
  });

  factory Features.fromJson(Map<String, dynamic> json) {
    return Features(
      chat: SubscriptionPlanModel._parseBool(json['chat']),
      dineIn: SubscriptionPlanModel._parseBool(json['dineIn']),
      qrCodeGenerate: SubscriptionPlanModel._parseBool(json['qrCodeGenerate']),
      restaurantMobileApp: SubscriptionPlanModel._parseBool(json['restaurantMobileApp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat': chat,
      'dineIn': dineIn,
      'qrCodeGenerate': qrCodeGenerate,
      'restaurantMobileApp': restaurantMobileApp,
    };
  }
}