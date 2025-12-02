import 'package:get/get.dart';
import '../models/order.dart';
import '../services/dashboard_service.dart';
import '../utils/api_helper.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  // Loading States
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Track if this is the first load attempt
  bool _isFirstLoad = true;

  // Sales Statistics
  final totalRevenue = 0.0.obs;
  final todaySales = 0.0.obs;
  final weekSales = 0.0.obs;
  final monthSales = 0.0.obs;
  final lastMonthSales = 0.0.obs;
  final revenueGrowth = 0.0.obs;

  // Orders Statistics
  final totalOrders = 0.obs;
  final pendingOrders = 0.obs;
  final confirmedOrders = 0.obs;
  final processingOrders = 0.obs;
  final shippedOrders = 0.obs;
  final deliveredOrders = 0.obs;
  final cancelledOrders = 0.obs;
  final todayOrders = 0.obs;
  final weekOrders = 0.obs;

  // Customers Statistics
  final totalCustomers = 0.obs;
  final activeCustomers = 0.obs;
  final newCustomersThisWeek = 0.obs;
  final newCustomersThisMonth = 0.obs;
  final avgCustomerValue = 0.0.obs;

  // Products Statistics
  final totalProducts = 0.obs;
  final activeProducts = 0.obs;
  final outOfStock = 0.obs;
  final lowStock = 0.obs;

  // Delivery Statistics
  final totalDeliveryMen = 0.obs;
  final availableDeliveryMen = 0.obs;
  final busyDeliveryMen = 0.obs;
  final avgDeliveryRating = 0.0.obs;
  final totalDeliveriesCompleted = 0.obs;

  // Stores Statistics
  final totalStores = 0.obs;
  final activeStores = 0.obs;

  // Recent Activity
  final recentOrders = <Order>[].obs;
  final topProducts = <Map<String, dynamic>>[].obs;
  final topCustomers = <Map<String, dynamic>>[].obs;
  final topDeliveryMen = <Map<String, dynamic>>[].obs;
  final topStores = <Map<String, dynamic>>[].obs;
  final topCategories = <Map<String, dynamic>>[].obs;
  final lowStockProducts = <Map<String, dynamic>>[].obs;

  // Charts Data
  final weeklyLabels = <String>[].obs;
  final weeklyOrderCounts = <int>[].obs;
  final weeklyRevenue = <double>[].obs;

  final monthlyLabels = <String>[].obs;
  final monthlyOrderCounts = <int>[].obs;
  final monthlyRevenue = <double>[].obs;

  // Order Distribution
  final orderStatusDistribution = <String, int>{}.obs;
  final paymentStatusDistribution = <String, int>{}.obs;

  // Quick Stats Cards
  final quickStats = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // CRITICAL FIX: Longer delay to ensure authentication is complete
    Future.delayed(const Duration(milliseconds: 1000), () {
      loadDashboardData();
    });
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // CRITICAL FIX: Verify we have a token before making the request
      final token = await ApiHelper.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Unauthorized access. Please login.');
      }

      final stats = await _dashboardService.getDashboardStats();

      if (stats.isNotEmpty) {
        _processDashboardStats(stats);
        _isFirstLoad = false; // Mark first load as complete
      }
    } catch (e) {
      hasError.value = true;

      // Clean error message
      String cleanError = e.toString().replaceAll('Exception:', '').trim();
      errorMessage.value = cleanError;

      // CRITICAL FIX: Don't show error on first load during login
      if (!_isFirstLoad) {
        // Check if it's an auth error
        if (cleanError.contains('Unauthorized') || cleanError.contains('Please login')) {
          // Auto-logout if unauthorized
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAllNamed('/login');
          });
        }
      }

      print('Dashboard error: $cleanError');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    try {
      isRefreshing.value = true;
      await loadDashboardData();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _processDashboardStats(Map<String, dynamic> stats) {
    // Sales Data
    if (stats['sales'] != null) {
      final sales = stats['sales'];
      totalRevenue.value = _toDouble(sales['total_revenue']);
      todaySales.value = _toDouble(sales['today_sales']);
      weekSales.value = _toDouble(sales['week_sales']);
      monthSales.value = _toDouble(sales['month_sales']);
      lastMonthSales.value = _toDouble(sales['last_month_sales']);
      revenueGrowth.value = _toDouble(sales['growth_percentage']);
    }

    // Orders Data
    if (stats['orders'] != null) {
      final orders = stats['orders'];
      totalOrders.value = _toInt(orders['total']);
      pendingOrders.value = _toInt(orders['pending']);
      confirmedOrders.value = _toInt(orders['confirmed']);
      processingOrders.value = _toInt(orders['processing']);
      shippedOrders.value = _toInt(orders['shipped']);
      deliveredOrders.value = _toInt(orders['delivered']);
      cancelledOrders.value = _toInt(orders['cancelled']);
      todayOrders.value = _toInt(orders['today']);
      weekOrders.value = _toInt(orders['this_week']);

      if (orders['status_distribution'] != null) {
        orderStatusDistribution.value = Map<String, int>.from(orders['status_distribution']);
      }
      if (orders['payment_distribution'] != null) {
        paymentStatusDistribution.value = Map<String, int>.from(orders['payment_distribution']);
      }
    }

    // Customers Data
    if (stats['customers'] != null) {
      final customers = stats['customers'];
      totalCustomers.value = _toInt(customers['total']);
      activeCustomers.value = _toInt(customers['active']);
      newCustomersThisWeek.value = _toInt(customers['new_this_week']);
      newCustomersThisMonth.value = _toInt(customers['new_this_month']);
      avgCustomerValue.value = _toDouble(customers['avg_customer_value']);
    }

    // Products Data
    if (stats['products'] != null) {
      final products = stats['products'];
      totalProducts.value = _toInt(products['total']);
      activeProducts.value = _toInt(products['active']);
      outOfStock.value = _toInt(products['out_of_stock']);
      lowStock.value = _toInt(products['low_stock']);

      if (products['low_stock_items'] != null) {
        lowStockProducts.value = List<Map<String, dynamic>>.from(products['low_stock_items']);
      }
    }

    // Delivery Data
    if (stats['delivery'] != null) {
      final delivery = stats['delivery'];
      totalDeliveryMen.value = _toInt(delivery['total_delivery_men']);
      availableDeliveryMen.value = _toInt(delivery['available']);
      busyDeliveryMen.value = _toInt(delivery['busy']);
      avgDeliveryRating.value = _toDouble(delivery['avg_rating']);
      totalDeliveriesCompleted.value = _toInt(delivery['total_deliveries_completed']);
    }

    // Stores Data
    if (stats['stores'] != null) {
      final stores = stats['stores'];
      totalStores.value = _toInt(stores['total']);
      activeStores.value = _toInt(stores['active']);
    }

    // Recent Orders
    if (stats['recent_orders'] != null) {
      recentOrders.value = (stats['recent_orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }

    // Top Products
    if (stats['top_products'] != null) {
      topProducts.value = List<Map<String, dynamic>>.from(stats['top_products']);
    }

    // Top Customers
    if (stats['top_customers'] != null) {
      topCustomers.value = List<Map<String, dynamic>>.from(stats['top_customers']);
    }

    // Top Delivery Men
    if (stats['top_delivery_men'] != null) {
      topDeliveryMen.value = List<Map<String, dynamic>>.from(stats['top_delivery_men']);
    }

    // Top Stores
    if (stats['top_stores'] != null) {
      topStores.value = List<Map<String, dynamic>>.from(stats['top_stores']);
    }

    // Top Categories
    if (stats['top_categories'] != null) {
      topCategories.value = List<Map<String, dynamic>>.from(stats['top_categories']);
    }

    // Weekly Sales Trend
    if (stats['weekly_sales'] != null) {
      final weekly = stats['weekly_sales'];
      weeklyLabels.value = List<String>.from(weekly['labels'] ?? []);
      weeklyOrderCounts.value = (weekly['orders'] as List?)?.map((v) => _toInt(v)).toList() ?? [];
      weeklyRevenue.value = (weekly['revenue'] as List?)?.map((v) => _toDouble(v)).toList() ?? [];
    }

    // Monthly Sales Trend
    if (stats['monthly_sales'] != null) {
      final monthly = stats['monthly_sales'];
      monthlyLabels.value = List<String>.from(monthly['labels'] ?? []);
      monthlyOrderCounts.value = (monthly['orders'] as List?)?.map((v) => _toInt(v)).toList() ?? [];
      monthlyRevenue.value = (monthly['revenue'] as List?)?.map((v) => _toDouble(v)).toList() ?? [];
    }

    // Quick Stats Cards
    if (stats['quick_stats'] != null) {
      quickStats.value = List<Map<String, dynamic>>.from(stats['quick_stats']);
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String formatPercentage(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return '#FF9800';
      case 'confirmed': return '#2196F3';
      case 'processing': return '#9C27B0';
      case 'shipped': return '#00BCD4';
      case 'delivered': return '#4CAF50';
      case 'cancelled': return '#F44336';
      default: return '#757575';
    }
  }
}