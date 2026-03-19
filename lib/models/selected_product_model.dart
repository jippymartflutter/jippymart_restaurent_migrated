// import 'dart:convert';
//
// /// In-memory model for a product selected in "Add from catalog" flow.
// /// Used to build the form body for POST /api/foods/store.
// class SelectedProductModel {
//   String masterProductId;
//   String? vendorProductId;
//   double merchantPrice;
//   double onlinePrice;
//   double discountPrice;
//   bool publish;
//   bool isAvailable;
//   List<AddonItem> addons;
//   List<String> availableDays;
//   Map<String, List<TimeRangeItem>> availableTimings;
//   List<OptionItem> options;
//
//   SelectedProductModel({
//     required this.masterProductId,
//     this.vendorProductId,
//     required this.merchantPrice,
//     required this.onlinePrice,
//     this.discountPrice = 0,
//     this.publish = true,
//     this.isAvailable = true,
//     List<AddonItem>? addons,
//     List<String>? availableDays,
//     Map<String, List<TimeRangeItem>>? availableTimings,
//     List<OptionItem>? options,
//   })  : addons = addons ?? [],
//         availableDays = availableDays ?? [],
//         availableTimings = availableTimings ?? {},
//         options = options ?? [];
//
//   void addAddon(String title, String price) {
//     addons.add(AddonItem(title: title, price: price));
//   }
//
//   void removeAddonAt(int index) {
//     if (index >= 0 && index < addons.length) addons.removeAt(index);
//   }
// }
//
// class AddonItem {
//   String title;
//   String price;
//   AddonItem({required this.title, required this.price});
// }
//
// class TimeRangeItem {
//   String from; // HH:MM
//   String to;
//   TimeRangeItem({required this.from, required this.to});
// }
//
// class OptionItem {
//   String id;
//   String title;
//   String price;
//   String? originalPrice;
//   bool isAvailable;
//
//   OptionItem({
//     required this.id,
//     required this.title,
//     required this.price,
//     this.originalPrice,
//     this.isAvailable = true,
//   });
//
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'title': title,
//         'price': price,
//         'original_price': originalPrice ?? price,
//         'is_available': isAvailable,
//       };
// }
//
// /// Builds the form-encoded body for POST /api/foods/store.
// /// Returns a list of key-value pairs (some keys repeat for arrays).
// List<MapEntry<String, String>> buildStoreFormBody(List<SelectedProductModel> selected) {
//   final pairs = <MapEntry<String, String>>[];
//   for (var i = 0; i < selected.length; i++) {
//     final p = selected[i];
//     final prefix = 'selected_products[$i]';
//     pairs.add(MapEntry('${prefix}[master_product_id]', p.masterProductId));
//     if (p.vendorProductId != null && p.vendorProductId!.isNotEmpty) {
//       pairs.add(MapEntry('${prefix}[vendor_product_id]', p.vendorProductId!));
//     }
//     pairs.add(MapEntry('${prefix}[merchant_price]', p.merchantPrice.toStringAsFixed(2)));
//     pairs.add(MapEntry('${prefix}[online_price]', p.onlinePrice.toStringAsFixed(2)));
//     pairs.add(MapEntry('${prefix}[discount_price]', p.discountPrice.toStringAsFixed(2)));
//     pairs.add(MapEntry('${prefix}[publish]', p.publish ? '1' : '0'));
//     pairs.add(MapEntry('${prefix}[isAvailable]', p.isAvailable ? '1' : '0'));
//
//     for (final a in p.addons) {
//       pairs.add(MapEntry('${prefix}[addons_title][]', a.title));
//       pairs.add(MapEntry('${prefix}[addons_price][]', a.price));
//     }
//     for (final d in p.availableDays) {
//       pairs.add(MapEntry('${prefix}[available_days][]', d));
//     }
//     for (final entry in p.availableTimings.entries) {
//       final day = entry.key;
//       for (var j = 0; j < entry.value.length; j++) {
//         pairs.add(MapEntry('${prefix}[available_timings][$day][$j][from]', entry.value[j].from));
//         pairs.add(MapEntry('${prefix}[available_timings][$day][$j][to]', entry.value[j].to));
//       }
//     }
//     for (var j = 0; j < p.options.length; j++) {
//       pairs.add(MapEntry('${prefix}[options][$j]', jsonEncode(p.options[j].toJson())));
//     }
//   }
//   return pairs;
// }
//
// /// Encode to application/x-www-form-urlencoded string.
// String encodeFormBody(List<MapEntry<String, String>> pairs) {
//   return pairs.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
// }



import 'dart:convert';

// ─────────────────────────────────────────────────────────────────────────────
// Supporting models
// ─────────────────────────────────────────────────────────────────────────────

class AddonItem {
  String title;
  String price;
  AddonItem({required this.title, required this.price});
}

/// One from/to slot inside a day.
/// Serializes to: {"from": "11:00", "to": "22:00"}
class TimeRangeItem {
  String from; // HH:MM
  String to;   // HH:MM
  TimeRangeItem({required this.from, required this.to});

  Map<String, dynamic> toJson() => {'from': from, 'to': to};
}

/// One product option / variant.
/// Serializes to:
///   {"id":"opt_xxx","title":"...","subtitle":"...","price":"329",
///    "original_price":"329","is_available":true,"is_featured":false}
class OptionItem {
  String id;
  String title;
  String? subtitle;
  String price;
  String? originalPrice;
  bool isAvailable;
  bool isFeatured;

  OptionItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.price,
    this.originalPrice,
    this.isAvailable = true,
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle ?? '',
    'price': price,
    'original_price': originalPrice ?? price,
    'is_available': isAvailable,
    'is_featured': isFeatured,
  };

  factory OptionItem.fromJson(Map<String, dynamic> json) => OptionItem(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    subtitle: json['subtitle']?.toString(),
    price: json['price']?.toString() ?? '0',
    originalPrice: json['original_price']?.toString(),
    isAvailable: json['is_available'] as bool? ?? true,
    isFeatured: json['is_featured'] as bool? ?? false,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Main selection model
// ─────────────────────────────────────────────────────────────────────────────

/// In-memory model for a product selected in the "Add from catalog" flow.
/// Used to build the form body for POST /api/foods/store.
class SelectedProductModel {
  String masterProductId;
  String? vendorProductId;

  double merchantPrice;
  double onlinePrice;
  double discountPrice;
  bool publish;
  bool isAvailable;

  List<AddonItem> addons;

  /// Ordered list of selected day names, e.g. ['Monday', 'Tuesday']
  List<String> availableDays;

  /// Timeslots keyed by day name.
  /// e.g. {'Monday': [TimeRangeItem(from:'09:00', to:'22:00')]}
  Map<String, List<TimeRangeItem>> availableTimings;

  List<OptionItem> options;

  SelectedProductModel({
    required this.masterProductId,
    this.vendorProductId,
    required this.merchantPrice,
    required this.onlinePrice,
    this.discountPrice = 0,
    this.publish = true,
    this.isAvailable = true,
    List<AddonItem>? addons,
    List<String>? availableDays,
    Map<String, List<TimeRangeItem>>? availableTimings,
    List<OptionItem>? options,
  })  : addons = addons ?? [],
        availableDays = availableDays ?? [],
        availableTimings = availableTimings ?? {},
        options = options ?? [];

  // ── Convenience mutators ──────────────────────────────────────────────────

  void addAddon(String title, String price) =>
      addons.add(AddonItem(title: title, price: price));

  void removeAddonAt(int index) {
    if (index >= 0 && index < addons.length) addons.removeAt(index);
  }

  // ── Serialization helpers (used by buildStoreFormBody) ────────────────────

  /// Availability serialized as JSON array:
  ///   [{"day":"Monday","timeslot":[{"from":"11:00","to":"22:00"}]}, ...]
  List<Map<String, dynamic>> get availabilityJson => availableDays
      .map((day) => {
    'day': day,
    'timeslot':
    (availableTimings[day] ?? []).map((t) => t.toJson()).toList(),
  })
      .toList();

  /// Options serialized as JSON array:
  ///   [{"id":"opt_xxx","title":"...","subtitle":"...","price":"329",
  ///     "original_price":"329","is_available":true,"is_featured":false}]
  ///
  /// Only options with `isAvailable == true` are sent to backend.
  List<Map<String, dynamic>> get optionsJson =>
      options.where((o) => o.isAvailable).map((o) => o.toJson()).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Form-body builder
// ─────────────────────────────────────────────────────────────────────────────

/// Builds the form-encoded body for POST /api/foods/store.
/// Returns a flat list of key-value pairs (some keys repeat for arrays).
///
/// Availability is sent as one JSON-encoded string per product:
///   selected_products[0][available_timings] = '[{"day":"Monday",...}]'
///
/// Options are sent as one JSON-encoded string per product:
///   selected_products[0][options] = '[{"id":"opt_xxx",...}]'
List<MapEntry<String, String>> buildStoreFormBody(
    List<SelectedProductModel> selected) {
  final pairs = <MapEntry<String, String>>[];

  for (var i = 0; i < selected.length; i++) {
    final p = selected[i];
    final pfx = 'selected_products[$i]';

    // ── Core fields ──────────────────────────────────────────────────────────
    pairs.add(MapEntry('${pfx}[master_product_id]', p.masterProductId));

    if (p.vendorProductId?.isNotEmpty == true) {
      pairs.add(MapEntry('${pfx}[vendor_product_id]', p.vendorProductId!));
    }

    pairs.add(MapEntry(
        '${pfx}[merchant_price]', p.merchantPrice.toStringAsFixed(2)));
    pairs.add(
        MapEntry('${pfx}[online_price]', p.onlinePrice.toStringAsFixed(2)));
    pairs.add(MapEntry(
        '${pfx}[discount_price]', p.discountPrice.toStringAsFixed(2)));
    pairs.add(MapEntry('${pfx}[publish]', p.publish ? '1' : '0'));
    pairs.add(MapEntry('${pfx}[isAvailable]', p.isAvailable ? '1' : '0'));

    // ── Add-ons (parallel arrays) ─────────────────────────────────────────
    for (final a in p.addons) {
      pairs.add(MapEntry('${pfx}[addons_title][]', a.title));
      pairs.add(MapEntry('${pfx}[addons_price][]', a.price));
    }

    // ── Availability — one JSON-encoded string per product ───────────────
    // Format: [{"day":"Monday","timeslot":[{"from":"11:00","to":"22:00"}]}]
    if (p.availableDays.isNotEmpty) {
      pairs.add(MapEntry(
        '${pfx}[available_timings]',
        jsonEncode(p.availabilityJson),
      ));
    }

    // ── Options — one JSON-encoded string per product ─────────────────────
    // Format: [{"id":"opt_xxx","title":"...","price":"329",...}]
    if (p.options.isNotEmpty) {
      pairs.add(MapEntry(
        '${pfx}[options]',
        jsonEncode(p.optionsJson),
      ));
    }
  }

  return pairs;
}

// ─────────────────────────────────────────────────────────────────────────────
// URL-encode helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Encode to application/x-www-form-urlencoded string.
String encodeFormBody(List<MapEntry<String, String>> pairs) {
  return pairs
      .map((e) =>
  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

/// Convenience: go straight from selected list to encoded string.
String encodeSelectedProducts(List<SelectedProductModel> selected) =>
    encodeFormBody(buildStoreFormBody(selected));