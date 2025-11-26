class AdminCommission {
  String? amount;
  bool? isEnabled;
  String? commissionType;

  AdminCommission({this.amount, this.isEnabled, this.commissionType});

  AdminCommission.fromJson(Map<String, dynamic> json) {
    amount = json['fix_commission'].toString();
    isEnabled = _parseBool(json['isEnabled']);
    commissionType = json['commissionType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fix_commission'] = amount;
    data['isEnabled'] = isEnabled;
    data['commissionType'] = commissionType;
    return data;
  }

  bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }
}
