/// Response model for GET /api/vendor/dashboard?vendor_id=...&filter=...
class DashboardModel {
  final bool success;
  final String? vendorId;
  final String? lastSettlementDate;
  final int totalOrders;
  final num totalEarnings;
  final List<DailyChartItem> dailyChart;

  DashboardModel({
    required this.success,
    this.vendorId,
    this.lastSettlementDate,
    this.totalOrders = 0,
    this.totalEarnings = 0,
    this.dailyChart = const [],
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final dailyList = json['daily_chart'] as List<dynamic>? ?? [];
    return DashboardModel(
      success: json['success'] == true,
      vendorId: json['vendor_id']?.toString(),
      lastSettlementDate: json['last_settlement_date']?.toString(),
      totalOrders: (json['total_orders'] is int)
          ? json['total_orders'] as int
          : int.tryParse(json['total_orders']?.toString() ?? '0') ?? 0,
      totalEarnings: (json['total_earnings'] is num)
          ? (json['total_earnings'] as num).toDouble()
          : double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0,
      dailyChart: dailyList
          .map((e) => DailyChartItem.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class DailyChartItem {
  final String date;
  final int orders;
  final num earnings;

  DailyChartItem({
    required this.date,
    this.orders = 0,
    this.earnings = 0,
  });

  factory DailyChartItem.fromJson(Map<String, dynamic> json) {
    return DailyChartItem(
      date: json['date']?.toString() ?? '',
      orders: (json['orders'] is int)
          ? json['orders'] as int
          : int.tryParse(json['orders']?.toString() ?? '0') ?? 0,
      earnings: (json['earnings'] is num)
          ? (json['earnings'] as num).toDouble()
          : double.tryParse(json['earnings']?.toString() ?? '0') ?? 0,
    );
  }
}
