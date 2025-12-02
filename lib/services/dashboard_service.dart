import 'package:get/get.dart';
import '../models/order.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _apiService = Get.find<ApiService>();

  // Get ALL dashboard statistics in ONE API call
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('/dashboard/get_stats.php');

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }

      throw Exception(response['message'] ?? 'Failed to load dashboard stats');
    } catch (e) {
      print('Dashboard stats error: $e');
      throw Exception('Failed to load dashboard: ${e.toString()}');
    }
  }

  // Get recent orders (separate call if needed)
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    try {
      final response = await _apiService.get('/dashboard/get_recent_orders.php?limit=$limit');

      if (response['status'] == 'success' && response['data'] != null) {
        final ordersData = response['data']['orders'] as List;
        return ordersData.map((json) => Order.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Recent orders error: $e');
      return [];
    }
  }

  // Get weekly sales data
  Future<Map<String, dynamic>> getWeeklySalesData() async {
    try {
      final response = await _apiService.get('/dashboard/get_weekly_sales.php');

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }

      return {'labels': [], 'values': [], 'order_counts': []};
    } catch (e) {
      print('Weekly sales error: $e');
      return {'labels': [], 'values': [], 'order_counts': []};
    }
  }

  // Get monthly sales data
  Future<Map<String, dynamic>> getMonthlySalesData({int months = 12}) async {
    try {
      final response = await _apiService.get('/dashboard/get_monthly_sales.php?months=$months');

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }

      return {'labels': [], 'values': [], 'order_counts': []};
    } catch (e) {
      print('Monthly sales error: $e');
      return {'labels': [], 'values': [], 'order_counts': []};
    }
  }

  // Get order status distribution
  Future<Map<String, dynamic>> getOrderStatusDistribution() async {
    try {
      final response = await _apiService.get('/dashboard/get_order_distribution.php');

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }

      return {};
    } catch (e) {
      print('Order distribution error: $e');
      return {};
    }
  }

  // Get top selling products
  Future<List<Map<String, dynamic>>> getTopSellingProducts({int limit = 5, int period = 30}) async {
    try {
      final response = await _apiService.get('/dashboard/get_top_products.php?limit=$limit&period=$period');

      if (response['status'] == 'success' && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']['products'] ?? []);
      }

      return [];
    } catch (e) {
      print('Top products error: $e');
      return [];
    }
  }

  // Get revenue growth
  Future<Map<String, dynamic>> getRevenueGrowth() async {
    try {
      final response = await _apiService.get('/dashboard/get_revenue_growth.php');

      if (response['status'] == 'success' && response['data'] != null) {
        return response['data'];
      }

      return {};
    } catch (e) {
      print('Revenue growth error: $e');
      return {};
    }
  }
}