class LanguageModel {
  bool? isActive;
  String? slug;
  String? title;
  String? image;
  bool? isRtl;

  LanguageModel({this.isActive, this.slug, this.title, this.isRtl,this.image});

  LanguageModel.fromJson(Map<String, dynamic> json) {
    isActive = _parseBool(json['isActive']);
    slug = json['slug'];
    title = json['title'];
    isRtl = _parseBool(json['is_rtl']);
    image = json['image'];
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
    data['isActive'] = isActive;
    data['slug'] = slug;
    data['title'] = title;
    data['is_rtl'] = isRtl;
    data['image'] = image;
    return data;
  }
}
