class VendorDashboardSummaryModel {
  final int totalProducts;
  final int activeProducts;
  final int outOfStockProducts;
  final int lowStockProducts;
  final int totalOrders;
  final int pendingOrders;
  final int ordersToDispatch;
  final int completedOrders;
  final double totalRevenue;
  final double currentMonthRevenue;
  final double todayRevenue;
  final int todayOrders;
  final String kycStatus;
  final bool hasProfile;
  final String? storeName;

  VendorDashboardSummaryModel({
    required this.totalProducts,
    required this.activeProducts,
    required this.outOfStockProducts,
    required this.lowStockProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.ordersToDispatch,
    required this.completedOrders,
    required this.totalRevenue,
    required this.currentMonthRevenue,
    required this.todayRevenue,
    required this.todayOrders,
    required this.kycStatus,
    required this.hasProfile,
    this.storeName,
  });

  factory VendorDashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return VendorDashboardSummaryModel(
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      activeProducts: (json['activeProducts'] as num?)?.toInt() ?? 0,
      outOfStockProducts: (json['outOfStockProducts'] as num?)?.toInt() ?? 0,
      lowStockProducts: (json['lowStockProducts'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pendingOrders'] as num?)?.toInt() ?? 0,
      ordersToDispatch: (json['ordersToDispatch'] as num?)?.toInt() ?? 0,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      currentMonthRevenue: (json['currentMonthRevenue'] as num?)?.toDouble() ?? 0.0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      todayOrders: (json['todayOrders'] as num?)?.toInt() ?? 0,
      kycStatus: json['kycStatus'] as String? ?? 'NOT_SUBMITTED',
      hasProfile: json['hasProfile'] as bool? ?? false,
      storeName: json['storeName'] as String?,
    );
  }

  factory VendorDashboardSummaryModel.empty() {
    return VendorDashboardSummaryModel(
      totalProducts: 0,
      activeProducts: 0,
      outOfStockProducts: 0,
      lowStockProducts: 0,
      totalOrders: 0,
      pendingOrders: 0,
      ordersToDispatch: 0,
      completedOrders: 0,
      totalRevenue: 0.0,
      currentMonthRevenue: 0.0,
      todayRevenue: 0.0,
      todayOrders: 0,
      kycStatus: 'NOT_SUBMITTED',
      hasProfile: false,
      storeName: null,
    );
  }
}
