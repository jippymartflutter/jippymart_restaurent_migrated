/// Model for subscription plan from API: GET subscription-plans?zone_id=...
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String price;
  final String? image;
  final String description;
  final String itemLimit;
  final String orderLimit;
  final String expiryDay;
  final String planType;
  final String place;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    required this.description,
    required this.itemLimit,
    required this.orderLimit,
    required this.expiryDay,
    required this.planType,
    required this.place,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic v) {
      if (v == null) return '';
      final s = v.toString().trim();
      return (s == 'null' || s.isEmpty) ? '' : s;
    }

    return SubscriptionPlanModel(
      id: safeString(json['id']),
      name: safeString(json['name']),
      price: safeString(json['price']),
      image: json['image'] != null && json['image'].toString().trim().isNotEmpty && json['image'].toString() != 'null'
          ? json['image'].toString()
          : null,
      description: safeString(json['description']),
      itemLimit: safeString(json['itemLimit']),
      orderLimit: safeString(json['orderLimit']),
      expiryDay: safeString(json['expiryDay']),
      planType: safeString(json['plan_type']),
      place: safeString(json['place']),
    );
  }

  bool get isCommission => planType == 'commission';
  bool get isSubscription => planType == 'subscription';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'itemLimit': itemLimit,
      'orderLimit': orderLimit,
      'expiryDay': expiryDay,
      'plan_type': planType,
      'place': place,
    };
  }
}
